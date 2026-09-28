CREATE TABLE circuits (
    circuit_id INTEGER NOT NULL,
    circuit_ref VARCHAR2(15) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    location VARCHAR2(30) NOT NULL,
    country VARCHAR2(20) NOT NULL,
    latitude NUMBER(7, 5) NOT NULL,
    longitude NUMBER(9, 6) NOT NULL,
    altitude NUMBER(4) NOT NULL,
    url VARCHAR2(75) NOT NULL,
    CONSTRAINT circuit_pk PRIMARY KEY (circuit_id)
);

ALTER TABLE circuits
ADD CONSTRAINT circuit_uq UNIQUE (circuit_ref, name, url);

CREATE TABLE constructors (
    constructor_id INTEGER NOT NULL,
    constructor_ref VARCHAR2(20) NOT NULL,
    name VARCHAR2(25) NOT NULL,
    nationality VARCHAR2(15) NOT NULL,
    url VARCHAR2(75) NOT NULL,
    CONSTRAINT constructor_pk PRIMARY KEY (constructor_id)
);

ALTER TABLE constructors
ADD CONSTRAINT constructor_uq UNIQUE (constructor_ref, name);

CREATE TABLE drivers (
    driver_id INTEGER NOT NULL,
    driver_ref VARCHAR2(20) NOT NULL,
    numb VARCHAR2(2) NOT NULL,
    code VARCHAR2(3) NOT NULL,
    forename VARCHAR2(20) NOT NULL,
    surname VARCHAR2(25) NOT NULL,
    birth_date DATE NOT NULL,
    nationality VARCHAR2(20) NOT NULL,
    url VARCHAR2(100) NOT NULL,
    CONSTRAINT driver_pk PRIMARY KEY (driver_id)
);

ALTER TABLE drivers
ADD CONSTRAINT driver_uq UNIQUE (driver_ref, url);

CREATE TABLE seasons (
    year INTEGER NOT NULL,
    url VARCHAR2(75) NOT NULL,
    CONSTRAINT season_pk PRIMARY KEY (year)
);

ALTER TABLE seasons
ADD CONSTRAINT season_uq UNIQUE (url);

CREATE TABLE status (
    status_id INTEGER NOT NULL,
    status VARCHAR2(20) NOT NULL,
    CONSTRAINT status_pk PRIMARY KEY (status_id)
);

ALTER TABLE status
ADD CONSTRAINT status_uq UNIQUE (status);

CREATE TABLE races (
    race_id INTEGER NOT NULL,
    year INTEGER NOT NULL,
    round NUMBER(2) NOT NULL,
    circuit_id INTEGER NOT NULL,
    name VARCHAR2(30) NOT NULL,
    race_date DATE NOT NULL,
    time VARCHAR2(8) NOT NULL,
    url VARCHAR2(75) NOT NULL,
    fp1_date VARCHAR2(10) NOT NULL,
    fp1_time VARCHAR2(8) NOT NULL,
    fp2_date VARCHAR2(10) NOT NULL,
    fp2_time VARCHAR2(8) NOT NULL,
    fp3_date VARCHAR2(10) NOT NULL,
    fp3_time VARCHAR2(8) NOT NULL,
    qualifying_date VARCHAR2(10) NOT NULL,
    qualifying_time VARCHAR2(8) NOT NULL,
    sprint_date VARCHAR2(10) NOT NULL,
    sprint_time VARCHAR2(8) NOT NULL,
    CONSTRAINT race_pk PRIMARY KEY (race_id),
    CONSTRAINT race_season_fk FOREIGN KEY (year) REFERENCES seasons(year),
    CONSTRAINT race_circuit_fk FOREIGN KEY (circuit_id) REFERENCES circuits(circuit_id)
);

ALTER TABLE races
ADD CONSTRAINT race_uq UNIQUE (race_date, url);

CREATE TABLE qualifying (
    qualifying_id INTEGER NOT NULL,
    race_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    constructor_id INTEGER NOT NULL,
    numb NUMBER(2) NOT NULL,
    position NUMBER(2) NOT NULL,
    q1 VARCHAR2(9) NOT NULL,
    q2 VARCHAR2(8),
    q3 VARCHAR2(8),
    CONSTRAINT qualifying_pk PRIMARY KEY (qualifying_id),
    CONSTRAINT qualifying_race_fk FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT qualifying_driver_fk FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CONSTRAINT qualifying_constructor_fk FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id)
);

CREATE TABLE lap_times (
    race_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    lap NUMBER(2) NOT NULL,
    position NUMBER(2) NOT NULL,
    time VARCHAR2(11) NOT NULL,
    time_ms NUMBER(7) NOT NULL,
    CONSTRAINT lap_time_pk PRIMARY KEY (race_id, driver_id, lap),
    CONSTRAINT lap_time_race_fk FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT lap_time_driver_fk FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE pit_stops (
    race_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    stop NUMBER(2) NOT NULL,
    lap NUMBER(2) NOT NULL,
    time VARCHAR2(8) NOT NULL,
    duration VARCHAR2(9) NOT NULL,
    duration_ms NUMBER(7) NOT NULL,
    CONSTRAINT pit_stop_pk PRIMARY KEY (race_id, driver_id, stop),
    CONSTRAINT pit_stop_race_fk FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT pit_stop_driver_fk FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE results (
    result_id INTEGER NOT NULL,
    race_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    constructor_id INTEGER NOT NULL,
    numb VARCHAR2(3) NOT NULL,
    grid_position NUMBER(2) NOT NULL,
    position VARCHAR2(2) NOT NULL,
    position_text VARCHAR2(2) NOT NULL,
    position_order NUMBER(2) NOT NULL,
    points NUMBER(3, 1) NOT NULL,
    laps NUMBER(3) NOT NULL,
    time VARCHAR2(11) NOT NULL,
    time_ms VARCHAR2(8) NOT NULL,
    fastest_lap VARCHAR2(2) NOT NULL,
    fastest_lap_rank VARCHAR2(2) NOT NULL,
    fastest_lap_time VARCHAR2(8) NOT NULL,
    fastest_lap_speed VARCHAR2(7) NOT NULL,
    status_id INTEGER NOT NULL,
    CONSTRAINT results_pk PRIMARY KEY (result_id),
    CONSTRAINT results_race_fk FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT results_driver_fk FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CONSTRAINT results_constructor_fk FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id),
    CONSTRAINT results_status_fk FOREIGN KEY (status_id) REFERENCES status(status_id)
);

CREATE TABLE driver_standings (
    standing_id INTEGER NOT NULL,
    race_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    points NUMBER(4, 1) NOT NULL,
    position NUMBER(3) NOT NULL,
    position_text VARCHAR2(3) NOT NULL,
    wins NUMBER(2) NOT NULL,
    CONSTRAINT driver_standings_pk PRIMARY KEY (standing_id),
    CONSTRAINT driver_standings_race_fk FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT driver_standings_driver_fk FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE constructor_results (
    result_id INTEGER NOT NULL,
    race_id INTEGER NOT NULL,
    constructor_id INTEGER NOT NULL,
    points NUMBER(3, 1) NOT NULL,
    status VARCHAR2(2) NOT NULL,
    CONSTRAINT constructor_results_pk PRIMARY KEY (result_id),
    CONSTRAINT constr_results_race_fk FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT constr_results_constructor_fk FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id)
);

CREATE TABLE constructor_standings (
    standing_id INTEGER NOT NULL,
    race_id INTEGER NOT NULL,
    constructor_id INTEGER NOT NULL,
    points NUMBER(4, 1) NOT NULL,
    position NUMBER(2) NOT NULL,
    position_text VARCHAR2(2) NOT NULL,
    wins NUMBER(2) NOT NULL,
    CONSTRAINT constructor_standings_pk PRIMARY KEY (standing_id),
    CONSTRAINT constr_stands_race_fk FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT constr_stands_constructor_fk FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id)
);

CREATE TABLE sprint_results (
    sprint_result_id INTEGER NOT NULL,
    race_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    constructor_id INTEGER NOT NULL,
    numb NUMBER(2) NOT NULL,
    grid_position NUMBER(2) NOT NULL,
    position VARCHAR2(2) NOT NULL,
    position_text VARCHAR2(2) NOT NULL,
    position_order NUMBER(2) NOT NULL,
    points NUMBER(1) NOT NULL,
    laps NUMBER(2) NOT NULL,
    time VARCHAR2(9) NOT NULL,
    time_ms VARCHAR2(7) NOT NULL,
    fastest_lap VARCHAR2(2) NOT NULL,
    fastest_lap_time VARCHAR2(8) NOT NULL,
    status_id INTEGER NOT NULL,
    CONSTRAINT sprint_results_pk PRIMARY KEY (sprint_result_id),
    CONSTRAINT sprint_results_race_fk FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT sprint_results_driver_fk FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CONSTRAINT sprint_results_constructor_fk FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id),
    CONSTRAINT sprint_results_status_fk FOREIGN KEY (status_id) REFERENCES status(status_id)
);
