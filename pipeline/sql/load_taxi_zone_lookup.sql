CREATE TABLE IF NOT EXISTS taxi_zone_lookup (
    locationid INTEGER PRIMARY KEY,
    borough TEXT,
    zone TEXT,
    service_zone TEXT
);

TRUNCATE TABLE taxi_zone_lookup;

COPY taxi_zone_lookup (locationid, borough, zone, service_zone)
FROM '/data/taxi_zone_lookup.csv'
WITH (
    FORMAT csv,
    HEADER true
);

SELECT COUNT(*) AS rows_loaded FROM taxi_zone_lookup;
