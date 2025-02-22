CREATE DATABASE IF NOT EXISTS STOCK_STREAMING;

USE STOCK_STREAMING;

CREATE TABLE IF NOT EXISTS IBM_STOCK (
    time DATETIME NOT NULL,
    open FLOAT NOT NULL,
    high FLOAT NOT NULL,
    low FLOAT NOT NULL,
    close FLOAT NOT NULL,
    volume FLOAT NOT NULL,
    symbol VARCHAR(40),
    event_time DATETIME DEFAULT NOW(),
    PRIMARY KEY (time)
);

SELECT * FROM IBM_STOCK;