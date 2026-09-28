/*
1. Ranking de Pilotos por Número de Victorias en Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se ha utilizado la columna 'wins' de la tabla 'driver_standings'.
*/

-- En primer lugar, obtenemos el número de Grandes Premios disputados en cada temporada del Campeonato del Mundo de Fórmula 1.
WITH f1_races_distribution AS (
    SELECT
        year,
        MAX(round) AS season_races
    FROM
        races
    -- Solución temporal, ya que la Temporada 2024 del Campeonato del Mundo de Fórmula 1 no ha terminado.
    WHERE
        race_id IN (
            SELECT
                DISTINCT race_id
            FROM driver_standings
        )
    GROUP BY
        year
),
-- Después, sumamos el número de victorias obtenidas por cada piloto al finalizar cada temporada del Campeonato del Mundo.
f1_gp_wins_distribution AS (
    SELECT
        driver_id,
        SUM(wins) AS f1_career_wins
    FROM
        driver_standings
    WHERE
        race_id IN (
            SELECT
                race_id
            FROM races
            INNER JOIN f1_races_distribution ON races.year = f1_races_distribution.year AND races.round = f1_races_distribution.season_races
        )
    GROUP BY
        driver_id
    HAVING
        SUM(wins) > 0
)
-- Ordenamos los resultados de la CTE (Common Table Expression) anterior, comparando el número de victorias con los Grandes Premios
-- corridos por cada piloto.
SELECT
    forename || ' ' || surname AS driver,
    nationality,
    f1_grand_prix_races,
    f1_career_wins,
    ROUND(f1_career_wins / f1_grand_prix_races * 100, 2) AS f1_win_rate_percent
FROM
    drivers
INNER JOIN f1_gp_wins_distribution ON drivers.driver_id = f1_gp_wins_distribution.driver_id
INNER JOIN (
    SELECT
        driver_id,
        COUNT(race_id) AS f1_grand_prix_races
    FROM
        results
    GROUP BY
        driver_id
) f1_driver_races ON f1_gp_wins_distribution.driver_id = f1_driver_races.driver_id
ORDER BY
    f1_career_wins DESC,
    f1_win_rate_percent DESC;

/*
2. Ranking de Nacionalidades por Número de Victorias en Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se ha utilizado un enfoque similar al reflejado por la Consulta 1.
*/

-- En primer lugar, obtenemos el número de Grandes Premios disputados en cada temporada del Campeonato del Mundo de Fórmula 1.
WITH f1_races_distribution AS (
    SELECT
        year,
        MAX(round) AS season_races
    FROM
        races
    -- Solución temporal, ya que la Temporada 2024 del Campeonato del Mundo de Fórmula 1 no ha terminado.
    WHERE
        race_id IN (
            SELECT
                DISTINCT race_id
            FROM driver_standings
        )
    GROUP BY
        year
)
-- Por último, agrupamos los resultados de la consulta anterior por nacionalidad y los ordenamos de mayor a menor número de victorias.
SELECT
    nationality,
    SUM(wins) AS f1_grand_prix_wins
FROM
    drivers
INNER JOIN driver_standings ON drivers.driver_id = driver_standings.driver_id
WHERE
    race_id IN (
        SELECT
            race_id
        FROM races
        INNER JOIN f1_races_distribution ON races.year = f1_races_distribution.year AND races.round = f1_races_distribution.season_races
    )
GROUP BY
    nationality
HAVING
    SUM(wins) > 0
ORDER BY
    f1_grand_prix_wins DESC,
    nationality;

/*
3. Ranking de Constructores por Número de Victorias en Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se ha utilizado la tabla 'results', obteniendo resultados más precisos que al recurrir a la columna
  'wins' de la tabla 'constructor_standings' (el Campeonato del Mundo de Constructores fue instaurado a partir de la Temporada 1958 del
  Campeonato del Mundo de Fórmula 1).
*/

-- En primer lugar, contamos el número de victorias obtenidas por cada constructor en el Campeonato del Mundo de Fórmula 1.
WITH f1_gp_wins_distribution AS (
    SELECT
        constructor_id,
        COUNT(DISTINCT race_id) AS f1_grand_prix_races,
        SUM(CASE WHEN position_order = 1 THEN 1 ELSE 0 END) AS f1_grand_prix_wins
    FROM
        results
    GROUP BY
        constructor_id
)
-- Finalmente, ordenamos los resultados de la CTE anterior, comparando el número de victorias con los Grandes Premios disputados por
-- cada constructor.
SELECT
    name AS constructor,
    nationality,
    f1_grand_prix_races,
    f1_grand_prix_wins,
    ROUND(f1_grand_prix_wins / f1_grand_prix_races * 100, 2) AS f1_win_rate_percent
FROM
    constructors
INNER JOIN f1_gp_wins_distribution ON constructors.constructor_id = f1_gp_wins_distribution.constructor_id
WHERE
    f1_grand_prix_wins > 0
ORDER BY
    f1_grand_prix_wins DESC,
    f1_win_rate_percent DESC;

/*
4. Ranking de Pilotos por Número de 'Pole Positions' en Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se ha utilizado la columna 'grid_position' de la tabla 'results', ya que es posible que en un fin de
  semana de Gran Premio de Fórmula 1, un piloto logre la 'Pole Position' en la Clasificación y, sin embargo, no parta desde la primera
  posición de la parrilla de salida en la Carrera (por ejemplo, Fernando Alonso en el Gran Premio de Hungría de la Temporada 2007).
*/

-- En primer lugar, contamos el número de 'Pole Positions' obtenidas por cada piloto en el Campeonato del Mundo de Fórmula 1.
WITH f1_pole_positions_distribution AS (
    SELECT
        driver_id,
        COUNT(race_id) AS f1_grand_prix_races,
        SUM(CASE WHEN grid_position = 1 THEN 1 ELSE 0 END) AS f1_career_pole_positions
    FROM
        results
    GROUP BY
        driver_id
)
-- Finalmente, ordenamos los resultados de la CTE anterior, comparando el número de 'Pole Positions' con los Grandes Premios disputados
-- por cada piloto.
SELECT
    forename || ' ' || surname AS driver,
    nationality,
    f1_grand_prix_races,
    f1_career_pole_positions,
    ROUND(f1_career_pole_positions / f1_grand_prix_races * 100, 2) AS f1_pole_position_rate_percent
FROM
    drivers
INNER JOIN f1_pole_positions_distribution ON drivers.driver_id = f1_pole_positions_distribution.driver_id
WHERE
    f1_career_pole_positions > 0
ORDER BY
    f1_career_pole_positions DESC,
    f1_pole_position_rate_percent DESC;

/*
5. Ranking de Constructores por Número de 'Pole Positions' en Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se ha utilizado un enfoque similar al reflejado por la Consulta 4.
*/

-- En primer lugar, contamos el número de 'Pole Positions' obtenidas por cada constructor en el Campeonato del Mundo de Fórmula 1.
WITH f1_pole_positions_distribution AS (
    SELECT
        constructor_id,
        COUNT(DISTINCT race_id) AS f1_grand_prix_races,
        SUM(CASE WHEN grid_position = 1 THEN 1 ELSE 0 END) AS f1_pole_positions
    FROM
        results
    GROUP BY
        constructor_id
)
-- Finalmente, ordenamos los resultados de la CTE anterior, comparando el número de 'Pole Positions' con los Grandes Premios disputados
-- por cada constructor.
SELECT
    name AS constructor,
    nationality,
    f1_grand_prix_races,
    f1_pole_positions,
    ROUND(f1_pole_positions / f1_grand_prix_races * 100, 2) AS f1_pole_position_rate_percent
FROM
    constructors
INNER JOIN f1_pole_positions_distribution ON constructors.constructor_id = f1_pole_positions_distribution.constructor_id
WHERE
    f1_pole_positions > 0
ORDER BY
    f1_pole_positions DESC,
    f1_pole_position_rate_percent DESC;

/*
6. Ranking de Pilotos por Número de Campeonatos del Mundo de Fórmula 1.
- Para realizar esta consulta, se ha utilizado la columna 'position' de la tabla 'driver_standings'.
*/

-- En primer lugar, obtenemos el número de Grandes Premios disputados en cada temporada del Campeonato del Mundo de Fórmula 1.
WITH season_finale_races AS (
    SELECT
        races_distribution.year AS season,
        season_final_race,
        race_id
    FROM
        races
    INNER JOIN (
        SELECT
            year,
            MAX(round) AS season_final_race
        FROM
            races
        -- Solución temporal, ya que la Temporada 2024 del Campeonato del Mundo de Fórmula 1 no ha terminado.
        WHERE
            year <> 2024
        GROUP BY
            year
    ) races_distribution ON races.year = races_distribution.year AND races.round = races_distribution.season_final_race
),
-- Después, encontramos la mejor clasificación final de cada piloto a lo largo de su trayectoria en el Campeonato del Mundo de Fórmula
-- 1.
best_final_standings AS (
    SELECT
        driver_id,
        MIN(position) AS best_final_standing
    FROM
        driver_standings
    INNER JOIN season_finale_races ON driver_standings.race_id = season_finale_races.race_id
    GROUP BY
        driver_id
),
-- A continuación, obtenemos el número de ocasiones y la última temporada en las cuales cada piloto logró su mejor clasificación final
-- en el Campeonato del Mundo de Fórmula 1.
best_final_standings_summary AS (
    SELECT
        driver_standings.driver_id,
        best_final_standing,
        COUNT(*) AS total_times,
        MAX(season) AS last_time
    FROM
        driver_standings
    INNER JOIN season_finale_races ON driver_standings.race_id = season_finale_races.race_id
    INNER JOIN best_final_standings ON driver_standings.driver_id = best_final_standings.driver_id AND driver_standings.position = best_final_standings.best_final_standing
    GROUP BY
        driver_standings.driver_id,
        best_final_standing
)
-- Finalmente, ordenamos los resultados de la CTE anterior en función de la mejor clasificación final de cada piloto.
SELECT
    forename || ' ' || surname AS driver_name,
    CASE
        WHEN best_final_standing = 1 THEN 'World Champion'
        ELSE best_final_standing ||
            CASE
                WHEN best_final_standing NOT BETWEEN 10 AND 20 THEN
                    CASE MOD(best_final_standing, 10)
                        WHEN 1 THEN 'st'
                        WHEN 2 THEN 'nd'
                        WHEN 3 THEN 'rd'
                        ELSE 'th'
                    END
                ELSE 'th'
            END
    END AS best_standing,
    total_times,
    last_time
FROM
    drivers
INNER JOIN best_final_standings_summary ON drivers.driver_id = best_final_standings_summary.driver_id
ORDER BY
    best_final_standing,
    total_times DESC,
    last_time DESC;

/*
7. Ranking de Constructores por Número de Campeonatos del Mundo de Fórmula 1.
- Para realizar esta consulta, se ha utilizado un enfoque similar al reflejado por la Consulta 6.
*/

-- En primer lugar, obtenemos el número de Grandes Premios disputados en cada temporada del Campeonato del Mundo de Fórmula 1.
WITH season_finale_races AS (
    SELECT
        races_distribution.year AS season,
        season_final_race,
        race_id
    FROM
        races
    INNER JOIN (
        SELECT
            year,
            MAX(round) AS season_final_race
        FROM
            races
        -- Solución temporal, ya que la Temporada 2024 del Campeonato del Mundo de Fórmula 1 no ha terminado.
        WHERE
            year <> 2024
        GROUP BY
            year
    ) races_distribution ON races.year = races_distribution.year AND races.round = races_distribution.season_final_race
),
-- Después, encontramos la mejor clasificación final de cada constructor a lo largo de su trayectoria en el Campeonato del Mundo de Fór-
-- mula 1.
best_final_standings AS (
    SELECT
        constructor_id,
        MIN(position) AS best_final_standing
    FROM
        constructor_standings
    INNER JOIN season_finale_races ON constructor_standings.race_id = season_finale_races.race_id
    GROUP BY
        constructor_id
),
-- A continuación, obtenemos el número de ocasiones y la última temporada en las cuales cada constructor logró su mejor clasificación
-- final en el Campeonato del Mundo de Fórmula 1.
best_final_standings_summary AS (
    SELECT
        constructor_standings.constructor_id,
        best_final_standing,
        COUNT(*) AS total_times,
        MAX(season) AS last_time
    FROM
        constructor_standings
    INNER JOIN season_finale_races ON constructor_standings.race_id = season_finale_races.race_id
    INNER JOIN best_final_standings ON constructor_standings.constructor_id = best_final_standings.constructor_id AND constructor_standings.position = best_final_standings.best_final_standing
    GROUP BY
        constructor_standings.constructor_id,
        best_final_standing
)
-- Finalmente, ordenamos los resultados de la CTE anterior en función de la mejor clasificación final de cada constructor.
SELECT
    name AS constructor_name,
    CASE
        WHEN best_final_standing = 1 THEN 'World Champion'
        ELSE best_final_standing ||
            CASE
                WHEN best_final_standing NOT BETWEEN 10 AND 20 THEN
                    CASE MOD(best_final_standing, 10)
                        WHEN 1 THEN 'st'
                        WHEN 2 THEN 'nd'
                        WHEN 3 THEN 'rd'
                        ELSE 'th'
                    END
                ELSE 'th'
            END
    END AS best_standing,
    total_times,
    last_time
FROM
    constructors
INNER JOIN best_final_standings_summary ON constructors.constructor_id = best_final_standings_summary.constructor_id
ORDER BY
    best_final_standing,
    total_times DESC,
    last_time DESC;

/*
8. Vueltas Rápidas de Carrera desde que marcar la Vuelta Rápida de Carrera en Grandes Premios de Fórmula 1 es puntuable.

- Para realizar esta consulta, se ha utilizado la columna 'fastest_lap_rank' de la tabla 'results'.
- Se han obtenido todas las Vueltas Rápidas de Carrera a partir de la Temporada 2019 del Campeonato del Mundo de Fórmula 1, puntuables
  si el piloto autor de la Vuelta Rápida de Carrera finalizó el Gran Premio entre los 10 primeros clasificados (posiciones que actual-
  mente otorgan puntuación).
*/

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    forename || ' ' || surname AS driver,
    constructors.name AS constructor,
    TO_NUMBER(fastest_lap) AS lap,
    fastest_lap_time AS lap_time,
    fastest_lap_speed || ' km/h' AS avg_speed,
    position_order ||
    CASE position_order
        WHEN 1 THEN 'st'
        WHEN 2 THEN 'nd'
        WHEN 3 THEN 'rd'
        ELSE 'th'
    END AS result,
    CASE
        WHEN position_order <= 10 THEN '+1 point'
        ELSE 'No extra point'
    END AS extra_point
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
WHERE
    fastest_lap_rank = '1'
    AND year BETWEEN 2019 AND 2024
ORDER BY
    season,
    race;

/*
9. Victorias en 'Sprint Races' de Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se ha utilizado la columna 'position_order' de la tabla 'sprint_results', mostrando la puntuación otor-
  gada al ganador de una 'Sprint Race' de un Gran Premio de Fórmula 1.
*/

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    forename || ' ' || surname AS winner_driver,
    constructors.name AS winner_constructor,
    sprint_results.time AS race_time,
    points || ' points' AS max_points
FROM
    sprint_results
INNER JOIN races ON sprint_results.race_id = races.race_id
INNER JOIN drivers ON sprint_results.driver_id = drivers.driver_id
INNER JOIN constructors ON sprint_results.constructor_id = constructors.constructor_id
WHERE
    position_order = 1
ORDER BY
    season,
    race;

/*
10. Trayectoria de Pilotos Españoles en el Campeonato del Mundo de Fórmula 1.
- Para realizar las siguientes consultas, se han utilizado las tablas 'results' y 'driver_standings'.
*/

-- Esta consulta obtiene la trayectoria de los pilotos españoles que han participado en el Campeonato del Mundo de Fórmula 1 a lo largo
-- de su historia.
WITH season_finale_races AS (
    SELECT
        races_distribution.year AS season,
        season_final_race,
        race_id
    FROM
        races
    INNER JOIN (
        SELECT
            year,
            MAX(round) AS season_final_race
        FROM
            races
        -- Solución temporal, ya que la Temporada 2024 del Campeonato del Mundo de Fórmula 1 no ha terminado.
        WHERE
            year <> 2024
        GROUP BY
            year
    ) races_distribution ON races.year = races_distribution.year AND races.round = races_distribution.season_final_race
)

SELECT
    season,
    CASE
        WHEN position = 1 THEN 'World Champion'
        ELSE position ||
            CASE
                WHEN position NOT BETWEEN 10 AND 20 THEN
                    CASE MOD(position, 10)
                        WHEN 1 THEN 'st'
                        WHEN 2 THEN 'nd'
                        WHEN 3 THEN 'rd'
                        ELSE 'th'
                    END
                ELSE 'th'
            END
    END AS final_standing,
    forename || ' ' || surname AS driver,
    points ||
    CASE
        WHEN points = 1 THEN ' point'
        ELSE ' points'
    END AS total_season_points
FROM
    driver_standings
INNER JOIN drivers ON driver_standings.driver_id = drivers.driver_id
INNER JOIN season_finale_races ON driver_standings.race_id = season_finale_races.race_id
WHERE
    nationality = 'Spanish'
ORDER BY
    season,
    position;
-- Esta consulta obtiene las estadísticas de los pilotos españoles que han participado en el Campeonato del Mundo de Fórmula 1 a lo lar-
-- go de su historia, por temporada y constructor con el cual cosecharon dichas estadísticas.
WITH driver_statistics AS (
    SELECT
        driver_id,
        constructor_id,
        year,
        COUNT(*) AS grand_prix_races,
        SUM(CASE WHEN position_order = 1 THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN position_order BETWEEN 1 AND 3 THEN 1 ELSE 0 END) AS podiums,
        SUM(CASE WHEN grid_position = 1 THEN 1 ELSE 0 END) AS pole_positions,
        SUM(CASE WHEN fastest_lap_rank = '1' THEN 1 ELSE 0 END) AS fastest_laps
    FROM
        results
    INNER JOIN races ON results.race_id = races.race_id
    GROUP BY
        driver_id,
        constructor_id,
        year
)

SELECT
    forename || ' ' || surname AS driver,
    year AS season,
    name AS constructor,
    grand_prix_races,
    wins,
    podiums,
    pole_positions,
    fastest_laps
FROM
    driver_statistics
INNER JOIN drivers ON driver_statistics.driver_id = drivers.driver_id
INNER JOIN constructors ON driver_statistics.constructor_id = constructors.constructor_id
WHERE
    drivers.nationality = 'Spanish'
ORDER BY
    drivers.driver_id,
    season,
    constructors.constructor_id DESC;

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    location || ', ' || country AS grand_prix_location,
    circuits.name AS circuit,
    forename || ' ' || surname AS driver,
    TRUNC(MONTHS_BETWEEN(race_date, birth_date) / 12) || ' years, ' ||
    TRUNC(MOD(MONTHS_BETWEEN(race_date, birth_date), 12)) || ' month(s) and ' ||
    race_date - ADD_MONTHS(birth_date, TRUNC(MONTHS_BETWEEN(race_date, birth_date))) || ' day(s) old' AS driver_age,
    constructors.name AS constructor,
    constructors.nationality AS constructor_nationality,
    position_order || CASE
        WHEN position_order BETWEEN 11 AND 13 THEN 'th'
        ELSE
            CASE MOD(position_order, 10)
                WHEN 1 THEN 'st'
                WHEN 2 THEN 'nd'
                WHEN 3 THEN 'rd'
                ELSE 'th'
            END
    END AS result,
    grid_position,
    CASE
        WHEN results.position = '\N' THEN 'Out of the Race: ' || status
        WHEN position_order = 1 THEN results.time
        ELSE 'Gap to Winner: ' ||
            CASE
                WHEN results.time = '\N' THEN status
                ELSE results.time
            END
    END AS race_time,
    NVL2(total_stops, total_stops || ' stop(s)', 'Pit stop(s) not registered') AS pit_stop_strategy,
    CASE
        WHEN fastest_lap_time = '\N' THEN 'Fastest lap not registered'
        ELSE fastest_lap_time ||
            CASE
                WHEN fastest_lap_rank <> '1' THEN ' (Not the fastest lap of the race)'
                ELSE ' (Fastest lap of the race,' ||
                    CASE
                        WHEN (year BETWEEN 1950 AND 1959) OR ((year BETWEEN 2019 AND 2024) AND (position_order <= 10)) THEN ' +1 point)'
                        ELSE ' No extra point)'
                    END
            END
    END AS fastest_lap,
    results.points || ' point(s)' AS points_awarded,
    driver_standings.position_text || CASE
        WHEN driver_standings.position BETWEEN 11 AND 13 THEN 'th'
        ELSE
            CASE MOD(driver_standings.position, 10)
                WHEN 1 THEN 'st'
                WHEN 2 THEN 'nd'
                WHEN 3 THEN 'rd'
                ELSE 'th'
            END
    END AS championship_standing,
    driver_standings.points || ' point(s)' AS championship_points


/*
11. Victorias de Pilotos Españoles en Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se han utilizado la columna 'position_order' de la tabla 'results' y la columna 'nationality' de la ta-
  bla 'drivers', mostrando la puntuación otorgada al ganador de un Gran Premio de Fórmula 1.
*/

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    forename || ' ' || surname AS winner_driver,
    constructors.name AS winner_constructor,
    results.time AS race_time,
    points || ' points' AS max_points
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
WHERE
    position_order = 1
    AND drivers.nationality = 'Spanish'
ORDER BY
    season,
    race;

/*
12. Podios de Pilotos Españoles en Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se ha utilizado un enfoque similar al reflejado por la Consulta 11.
*/

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    forename || ' ' || surname AS driver,
    constructors.name AS constructor,
    CASE position_order
        WHEN 3 THEN position_order || 'rd'
        WHEN 2 THEN position_order || 'nd'
        ELSE 'Winner'
    END AS result,
    CASE
        WHEN position_order = 1 THEN results.time
        ELSE 'Gap to Winner: ' || results.time
    END AS race_time,
    points || ' points' AS points_awarded
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
WHERE
    position_order BETWEEN 1 AND 3
    AND drivers.nationality = 'Spanish'
ORDER BY
    season,
    race;

/*
13. 'Pole Positions' de Pilotos Españoles en Grandes Premios de Fórmula 1.
- Para realizar esta consulta, se han utilizado la columna 'grid_position' de la tabla 'results' y la columna 'nationality' de la tabla
  'drivers', mostrando el tiempo de clasificación marcado para lograr cada 'Pole Position'.
*/

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    forename || ' ' || surname AS driver,
    constructors.name AS constructor,
    CASE
        WHEN year < 2006 THEN q1
        ELSE q3
    END AS qualifying_time
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN qualifying ON results.race_id = qualifying.race_id AND results.driver_id = qualifying.driver_id
WHERE
    grid_position = 1
    AND drivers.nationality = 'Spanish'
ORDER BY
    season,
    race;

/*
14. Trayectoria de Constructores Españoles en el Campeonato del Mundo de Fórmula 1.
- Para realizar las siguientes consultas, se han utilizado las tablas 'results' y 'constructor_standings'.
*/

-- Esta consulta obtiene la trayectoria de los constructores españoles que han participado en el Campeonato del Mundo de Fórmula 1 a lo
-- largo de su historia.
WITH season_finale_races AS (
    SELECT
        races_distribution.year AS season,
        season_final_race,
        race_id
    FROM
        races
    INNER JOIN (
        SELECT
            year,
            MAX(round) AS season_final_race
        FROM
            races
        -- Solución temporal, ya que la Temporada 2024 del Campeonato del Mundo de Fórmula 1 no ha terminado.
        WHERE
            year <> 2024
        GROUP BY
            year
    ) races_distribution ON races.year = races_distribution.year AND races.round = races_distribution.season_final_race
)

SELECT
    season,
    CASE
        WHEN position = 1 THEN 'World Champion'
        ELSE position ||
            CASE
                WHEN position NOT BETWEEN 10 AND 20 THEN
                    CASE MOD(position, 10)
                        WHEN 1 THEN 'st'
                        WHEN 2 THEN 'nd'
                        WHEN 3 THEN 'rd'
                        ELSE 'th'
                    END
                ELSE 'th'
            END
    END AS final_standing,
    name AS constructor,
    points ||
    CASE
        WHEN points = 1 THEN ' point'
        ELSE ' points'
    END AS total_season_points
FROM
    constructor_standings
INNER JOIN constructors ON constructor_standings.constructor_id = constructors.constructor_id
INNER JOIN season_finale_races ON constructor_standings.race_id = season_finale_races.race_id
WHERE
    nationality = 'Spanish'
ORDER BY
    season,
    position;
-- Esta consulta obtiene las estadísticas por temporada de los constructores españoles que han participado en el Campeonato del Mundo
-- de Fórmula 1 a lo largo de su historia.
WITH constructors_statistics AS (
    SELECT
        constructor_id,
        COUNT(DISTINCT race_id) AS grand_prix_races,
        SUM(CASE WHEN position_order = 1 THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN position_order BETWEEN 1 AND 3 THEN 1 ELSE 0 END) AS podiums,
        SUM(CASE WHEN grid_position = 1 THEN 1 ELSE 0 END) AS pole_positions,
        SUM(CASE WHEN fastest_lap_rank = '1' THEN 1 ELSE 0 END) AS fastest_laps
    FROM
        results
    GROUP BY
        constructor_id
)

SELECT
    name AS constructor,
    grand_prix_races,
    wins,
    podiums,
    pole_positions,
    fastest_laps
FROM
    constructors
INNER JOIN constructors_statistics ON constructors.constructor_id = constructors_statistics.constructor_id
WHERE
    nationality = 'Spanish'
ORDER BY
    grand_prix_races DESC;

/*
15. Circuitos en España que han albergado un Gran Premio de Fórmula 1.
- Para realizar esta consulta, se ha utilizado la columna 'country' de la tabla 'circuits', mostrando la ubicación y el tiempo de vuel-
  ta en carrera más rápido marcado en cada circuito.
*/

-- En primer lugar, obtenemos el tiempo de vuelta en carrera más rápido marcado en cada circuito ubicado en España donde se ha celebra-
-- do un Gran Premio de Fórmula 1.
WITH circuits_race_fastest_laps AS (
    SELECT
        circuit_id,
        MIN(fastest_lap_time) AS record_race_lap
    FROM
        results
    INNER JOIN races ON results.race_id = races.race_id
    GROUP BY
        circuit_id
)
-- Finalmente, mostramos la información relativa a cada circuito y su vuelta de carrera más rápida registrada.
SELECT
    circuits.name AS circuit,
    location,
    CASE
        WHEN record_race_lap = '\N' THEN 'No fastest lap registered'
        ELSE record_race_lap
    END AS race_record_lap_time,
    CASE
        WHEN record_race_lap = '\N' THEN 'No fastest lap registered'
        ELSE forename || ' ' || surname
    END AS driver,
    CASE
        WHEN record_race_lap = '\N' THEN 'No fastest lap registered'
        ELSE drivers.nationality
    END AS nationality,
    CASE
        WHEN record_race_lap = '\N' THEN 'No fastest lap registered'
        ELSE constructors.name
    END AS constructor,
    CASE
        WHEN record_race_lap = '\N' THEN 'No fastest lap registered'
        ELSE year || ' ' || races.name
    END AS grand_prix
FROM
    circuits_race_fastest_laps
INNER JOIN circuits ON circuits_race_fastest_laps.circuit_id = circuits.circuit_id
LEFT JOIN results ON circuits_race_fastest_laps.record_race_lap = results.fastest_lap_time AND record_race_lap <> '\N'
LEFT JOIN races ON results.race_id = races.race_id AND circuits.circuit_id = races.circuit_id
LEFT JOIN drivers ON results.driver_id = drivers.driver_id
LEFT JOIN constructors ON results.constructor_id = constructors.constructor_id
WHERE
    country = 'Spain'
ORDER BY
    circuits.circuit_id;

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    circuits.name AS circuit,
    CASE position_order
        WHEN 3 THEN position_order || 'rd'
        WHEN 2 THEN position_order || 'nd'
        ELSE 'Winner'
    END AS result,
    forename || ' ' || surname AS driver,
    drivers.nationality AS driver_nationality,
    constructors.name AS constructor,
    constructors.nationality AS constructor_nationality,
    CASE
        WHEN position_order = 1 THEN results.time
        ELSE 'Gap to Winner: ' ||
            CASE
                WHEN results.time = '\N' THEN status
                ELSE results.time
            END
    END AS race_time,
    points || ' points' AS points_awarded
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN status ON results.status_id = status.status_id
INNER JOIN circuits ON races.circuit_id = circuits.circuit_id
WHERE
    races.name = 'Spanish Grand Prix'
    AND position_order BETWEEN 1 AND 3
ORDER BY
    season,
    race,
    position_order;

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    circuits.name AS circuit,
    forename || ' ' || surname AS driver,
    constructors.name AS constructor,
    CASE
        WHEN year < 2005 THEN COALESCE(q1, 'Pole position lap time not registered')
        WHEN year = 2005 THEN FLOOR(
            (TO_NUMBER(SUBSTR(q1, 1, 1)) * 60000 + TO_NUMBER(SUBSTR(q1, 3, 2)) * 1000 + TO_NUMBER(SUBSTR(q1, -3)) +
            TO_NUMBER(SUBSTR(q2, 1, 1)) * 60000 + TO_NUMBER(SUBSTR(q2, 3, 2)) * 1000 + TO_NUMBER(SUBSTR(q2, -3))) / 1000 / 60
        ) || ':' || MOD(
            TO_NUMBER(SUBSTR(q1, 1, 1)) * 60000 + TO_NUMBER(SUBSTR(q1, 3, 2)) * 1000 + TO_NUMBER(SUBSTR(q1, -3)) +
            TO_NUMBER(SUBSTR(q2, 1, 1)) * 60000 + TO_NUMBER(SUBSTR(q2, 3, 2)) * 1000 + TO_NUMBER(SUBSTR(q2, -3)), 60000
        ) / 1000
        ELSE q3
    END AS qualifying_time
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN circuits ON races.circuit_id = circuits.circuit_id
LEFT JOIN qualifying ON results.race_id = qualifying.race_id AND results.driver_id = qualifying.driver_id
WHERE
    races.name = 'Spanish Grand Prix'
    AND grid_position = 1
ORDER BY
    season,
    race;

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    circuits.name AS circuit,
    forename || ' ' || surname AS driver,
    constructors.name AS constructor,
    TO_NUMBER(fastest_lap) AS lap,
    fastest_lap_time AS lap_time,
    fastest_lap_speed || ' km/h' AS avg_speed,
    position_order ||
    CASE position_order
        WHEN 1 THEN 'st'
        WHEN 2 THEN 'nd'
        WHEN 3 THEN 'rd'
        ELSE 'th'
    END AS result,
    CASE
        WHEN (year BETWEEN 2019 AND 2024) AND (position_order <= 10) THEN '+1 point'
        ELSE 'No extra point'
    END AS extra_point
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN circuits ON races.circuit_id = circuits.circuit_id
WHERE
    races.name = 'Spanish Grand Prix'
    AND fastest_lap_rank = '1'
ORDER BY
    season,
    race;

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    circuits.name AS circuit,
    country AS location,
    CASE position_order
        WHEN 3 THEN position_order || 'rd'
        WHEN 2 THEN position_order || 'nd'
        ELSE 'Winner'
    END AS result,
    forename || ' ' || surname AS driver,
    drivers.nationality AS driver_nationality,
    constructors.name AS constructor,
    constructors.nationality AS constructor_nationality,
    CASE
        WHEN position_order = 1 THEN results.time
        ELSE 'Gap to Winner: ' ||
            CASE
                WHEN results.time = '\N' THEN status
                ELSE results.time
            END
    END AS race_time,
    points || ' points' AS points_awarded
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN status ON results.status_id = status.status_id
INNER JOIN circuits ON races.circuit_id = circuits.circuit_id
WHERE
    races.name = 'European Grand Prix'
    AND position_order BETWEEN 1 AND 3
ORDER BY
    season,
    race,
    position_order;

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    circuits.name AS circuit,
    country AS location,
    forename || ' ' || surname AS driver,
    constructors.name AS constructor,
    CASE
        WHEN year < 2006 THEN COALESCE(q1, 'Pole position lap time not registered')
        ELSE q3
    END AS qualifying_time
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN circuits ON races.circuit_id = circuits.circuit_id
LEFT JOIN qualifying ON results.race_id = qualifying.race_id AND results.driver_id = qualifying.driver_id
WHERE
    races.name = 'European Grand Prix'
    AND grid_position = 1
ORDER BY
    season,
    race;

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    circuits.name AS circuit,
    country AS location,
    forename || ' ' || surname AS driver,
    constructors.name AS constructor,
    TO_NUMBER(fastest_lap) AS lap,
    fastest_lap_time AS lap_time,
    fastest_lap_speed || ' km/h' AS avg_speed,
    position_order ||
    CASE position_order
        WHEN 1 THEN 'st'
        WHEN 2 THEN 'nd'
        WHEN 3 THEN 'rd'
        ELSE 'th'
    END AS result,
    CASE
        WHEN (year BETWEEN 2019 AND 2024) AND (position_order <= 10) THEN '+1 point'
        ELSE 'No extra point'
    END AS extra_point
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN circuits ON races.circuit_id = circuits.circuit_id
WHERE
    races.name = 'European Grand Prix'
    AND fastest_lap_rank = '1'
ORDER BY
    season,
    race;

SELECT
    CASE
        WHEN position_text = 'W' THEN 'Withdraw'
        ELSE position_order ||
            CASE position_order
                WHEN 1 THEN 'st'
                WHEN 2 THEN 'nd'
                WHEN 3 THEN 'rd'
                ELSE 'th'
            END
    END AS result,
    forename || ' ' || surname AS driver,
    drivers.nationality AS driver_nationality,
    constructors.name AS constructor,
    grid_position,
    CASE
        WHEN position_text = 'W' THEN 'Out of the Race: ' || status
        WHEN results.time = '\N' THEN status
        ELSE results.time
    END AS race_time,
    points || ' points' AS points_awarded,
    RANK() OVER (ORDER BY result_id) AS final_position_order
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN status ON results.status_id = status.status_id
WHERE
    year = 2005
    AND races.name = 'United States Grand Prix';

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    winner_drivers.forename || ' ' || winner_drivers.surname AS winner_driver,
    winner_drivers.nationality AS winner_nationality,
    runner_up_drivers.forename || ' ' || runner_up_drivers.surname AS runner_up_driver,
    runner_up_drivers.nationality AS runner_up_nationality,
    constructors.name AS constructor
FROM
    results winner_results
INNER JOIN drivers winner_drivers ON winner_results.driver_id = winner_drivers.driver_id
INNER JOIN results runner_up_results ON winner_results.race_id = runner_up_results.race_id AND winner_results.constructor_id = runner_up_results.constructor_id AND runner_up_results.position_order = 2
INNER JOIN drivers runner_up_drivers ON runner_up_results.driver_id = runner_up_drivers.driver_id
INNER JOIN races ON winner_results.race_id = races.race_id
INNER JOIN constructors ON winner_results.constructor_id = constructors.constructor_id
WHERE
    winner_results.position_order = 1
    AND year >= 1985
ORDER BY
    season,
    race;

SELECT
    year AS season,
    round AS race,
    races.name AS grand_prix,
    location || ', ' || country AS grand_prix_location,
    circuits.name AS circuit,
    forename || ' ' || surname AS driver,
    drivers.nationality AS driver_nationality,
    constructors.name AS constructor,
    constructors.nationality AS constructor_nationality,
    CASE
        WHEN year < 2006 THEN q1
        ELSE q3
    END AS pole_position_lap_time,
    results.time AS race_time,
    fastest_lap_time AS race_fastest_lap_time,
    laps_in_lead
FROM
    results
INNER JOIN races ON results.race_id = races.race_id
INNER JOIN drivers ON results.driver_id = drivers.driver_id
INNER JOIN constructors ON results.constructor_id = constructors.constructor_id
INNER JOIN qualifying ON results.race_id = qualifying.race_id AND results.driver_id = qualifying.driver_id
INNER JOIN circuits ON races.circuit_id = circuits.circuit_id
INNER JOIN (
    SELECT
        race_id,
        driver_id,
        COUNT(lap) AS laps_in_lead
    FROM
        lap_times
    WHERE
        position = 1
    GROUP BY
        race_id,
        driver_id
) driver_laps_in_lead ON results.race_id = driver_laps_in_lead.race_id AND results.driver_id = driver_laps_in_lead.driver_id AND results.laps = driver_laps_in_lead.laps_in_lead
WHERE
    grid_position = 1
    AND position_order = 1
    AND fastest_lap_rank = '1'
ORDER BY
    season,
    race;
