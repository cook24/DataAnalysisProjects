

-- DATA CLEANING QUERIES


SELECT *
FROM nyc_traffic_accidents

-- Add County column and populate

ALTER TABLE nyc_traffic_accidents
ADD county varchar(20)

UPDATE nyc_traffic_accidents
SET county = 
	CASE
		WHEN borough = 'BRONX' THEN 'Bronx County'
		WHEN borough = 'MANHATTAN' THEN 'New York County'
		WHEN borough = 'QUEENS' THEN 'Queens County'
		WHEN borough = 'BROOKLYN' THEN 'Kings County'
		WHEN borough = 'STATEN ISLAND' THEN 'Richmond County'
		ELSE NULL
	END





-- Add time_range column and populate

ALTER TABLE nyc_traffic_accidents
ADD collision_time_range varchar(20)

/* 
the below is used to check column type
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH AS MAX_LENGTH, 
    CHARACTER_OCTET_LENGTH AS OCTET_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'nyc_practice_table'
*/

UPDATE nyc_traffic_accidents
SET collision_time_range =
	CASE
		WHEN crash_time >= '0:00' AND crash_time < '5:00' THEN 'Early Morning'
		WHEN crash_time >= '5:00' AND crash_time < '10:00' THEN 'Rush Hour AM'
		WHEN crash_time >= '10:00' AND crash_time < '15:00' THEN 'Mid-Day'
		WHEN crash_time >= '15:00' AND crash_time < '20:00' THEN 'Rush Hour PM'
		ELSE 'Late Night'
	END




-- Remove unused columns

ALTER TABLE nyc_traffic_accidents
DROP COLUMN
	location_,
	on_street_name,
	cross_street_name,
	off_street_name,
	number_of_pedestrians_injured,
	number_of_pedestrians_killed,
	number_of_cyclists_injured,
	number_of_cyclists_killed,
	number_of_motorists_injured,
	number_of_motorists_killed,
	contributing_factor_vehicle_4,
	contributing_factor_vehicle_5,
	vehicle_type_code_3,
	vehicle_type_code_4,
	vehicle_type_code_5




-- DATA ANALYSIS QUERIES


-- Most common contributing factors for vehicles involved in collisions

SELECT 
	DISTINCT(contributing_factor_vehicle_1),
	COUNT(*) AS count_factor
FROM nyc_traffic_accidents
WHERE contributing_factor_vehicle_1 NOT LIKE 'Unspecified'
GROUP BY contributing_factor_vehicle_1
ORDER BY count_factor DESC


SELECT 
	DISTINCT(contributing_factor_vehicle_2),
	COUNT(*) AS count_factor
FROM nyc_traffic_accidents
WHERE contributing_factor_vehicle_2 NOT LIKE 'Unspecified'
GROUP BY contributing_factor_vehicle_2
ORDER BY count_factor DESC


SELECT 
	DISTINCT(contributing_factor_vehicle_3),
	COUNT(*) AS count_factor
FROM nyc_traffic_accidents
WHERE contributing_factor_vehicle_3 IS NOT NULL
	AND contributing_factor_vehicle_3 NOT LIKE 'Unspecified'
GROUP BY contributing_factor_vehicle_3
ORDER BY count_factor DESC

/*
Note:
Most common contributing factor for the first and second vehicles was inattention/distraction
Most common for third was following too closely
*/




-- Contributing factors of collisions that most commonly result in injuries

SELECT
	contributing_factor_vehicle_1,
	COUNT(*) AS accidents_resulting_in_injury,
	SUM(number_of_persons_injured) AS total_injured
FROM nyc_traffic_accidents
WHERE contributing_factor_vehicle_1 IS NOT NULL
	AND contributing_factor_vehicle_1 NOT LIKE 'Unspecified'
GROUP BY contributing_factor_vehicle_1
ORDER BY
	accidents_resulting_in_injury DESC,
	total_injured

/*
Among the highest ratios of 'total_injured' to 'accidents_resulting_in_injury' are:
'Unsafe Speed' 
'Traffic Control Disregarded'
'Alcohol Involvement'
'Aggression/Road Rage'
'Fell Asleep'
'Lost Consciousness'

Note that being involved in a road rage incident entails a higher chance of injury than a crash from someone falling asleep at the wheel.

*/




-- Accidents by type of vehicle

SELECT
	top 20 vehicle_type_code_1,
	COUNT(*)
FROM nyc_traffic_accidents
GROUP BY vehicle_type_code_1
ORDER BY COUNT(*) DESC




-- Injuries and deaths by time of day

SELECT
	collision_time_range,
	COUNT(*) AS total_accidents,
	SUM(number_of_persons_injured) AS total_injuries,
	SUM(number_of_persons_killed) AS total_deaths
FROM nyc_traffic_accidents
GROUP BY collision_time_range




-- Percent of total accidents for a given borough

WITH total_accidents AS (
SELECT COUNT(*) AS total_crashes
FROM nyc_traffic_accidents
WHERE borough IS NOT NULL
),
borough_accidents AS (
SELECT
	borough,
	COUNT(*) AS borough_total
FROM nyc_traffic_accidents
GROUP BY borough
HAVING borough IS NOT NULL
),
percent_total_crashes AS (
SELECT
	borough_accidents.borough AS borough,
	borough_accidents.borough_total AS borough_total,
	total_accidents.total_crashes AS total_crashes
FROM borough_accidents, total_accidents
)
SELECT
	percent_total_crashes.borough,
	percent_total_crashes.borough_total,
	percent_total_crashes.total_crashes,
	CAST(CAST(percent_total_crashes.borough_total AS float) / CAST(percent_total_crashes.total_crashes AS float) AS DECIMAL(4, 2)) * 100 AS percent_total
FROM percent_total_crashes









