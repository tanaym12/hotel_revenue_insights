-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Drop tables if they exist
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_hotels;
DROP TABLE IF EXISTS dim_rooms;
DROP TABLE IF EXISTS fact_aggregated_bookings;
DROP TABLE IF EXISTS fact_bookings;
DROP TABLE IF EXISTS summary_statistics;

-- Create tables
CREATE TABLE dim_date (
    date TEXT PRIMARY KEY,
    mmm_yy TEXT,
    week_no INTEGER,
    day_type TEXT
);

CREATE TABLE dim_hotels (
    property_id INTEGER PRIMARY KEY,
    property_name TEXT,
    category TEXT,
    city TEXT
);

CREATE TABLE dim_rooms (
    room_id TEXT PRIMARY KEY,
    room_class TEXT
);

CREATE TABLE fact_aggregated_bookings (
    property_id INTEGER,
    check_in_date TEXT,
    room_category TEXT,
    successful_bookings INTEGER,
    capacity INTEGER,
    FOREIGN KEY (property_id) REFERENCES dim_hotels(property_id)
);

CREATE TABLE fact_bookings (
    booking_id INTEGER PRIMARY KEY,
    property_id INTEGER,
    booking_date TEXT,
    check_in_date TEXT,
    check_out_date TEXT,
    no_guests INTEGER,
    room_category TEXT,
    booking_platform TEXT,
    ratings_given REAL,
    booking_status TEXT,
    revenue_generated REAL,
    revenue_realized REAL,
    FOREIGN KEY (property_id) REFERENCES dim_hotels(property_id)
);

-- Create summary statistics table
CREATE TABLE summary_statistics (
    metric TEXT PRIMARY KEY,
    value REAL
);

-- Insert Summary Statistics
INSERT INTO summary_statistics (metric, value)
SELECT 'Total Bookings', COUNT(*) FROM fact_bookings;

INSERT INTO summary_statistics (metric, value)
SELECT 'Total Revenue Generated', SUM(revenue_generated) FROM fact_bookings;

INSERT INTO summary_statistics (metric, value)
SELECT 'Total Revenue Realized', SUM(revenue_realized) FROM fact_bookings;

INSERT INTO summary_statistics (metric, value)
SELECT 'Average Rating', AVG(ratings_given) FROM fact_bookings WHERE ratings_given IS NOT NULL;

INSERT INTO summary_statistics (metric, value)
SELECT 'Total Successful Bookings', SUM(successful_bookings) FROM fact_aggregated_bookings;

INSERT INTO summary_statistics (metric, value)
SELECT 'Overall Occupancy Rate', 
       (SUM(successful_bookings) * 100.0) / SUM(capacity) 
FROM fact_aggregated_bookings WHERE capacity > 0;

-- Display the summary statistics
SELECT * FROM summary_statistics;