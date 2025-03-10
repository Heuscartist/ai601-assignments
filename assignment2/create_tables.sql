CREATE EXTERNAL TABLE IF NOT EXISTS raw_user_logs (
    user_id INT,
    content_id INT,
    action STRING,
    event_time STRING,
    device STRING,
    region STRING,
    session_id STRING
)
PARTITIONED BY (year INT, month INT, day INT)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE
LOCATION '/raw/logs/'
TBLPROPERTIES ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE IF NOT EXISTS raw_content_metadata (
    content_id INT,
    title STRING,
    category STRING,
    length INT,
    artist STRING
)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE
LOCATION '/raw/metadata/'
TBLPROPERTIES ('skip.header.line.count'='1');


ALTER TABLE raw_user_logs ADD PARTITION (year=2023, month=9, day=1) LOCATION '/raw/logs/2023/09/01/';


DROP TABLE IF EXISTS dim_content;
CREATE EXTERNAL TABLE dim_content (
    content_id INT,
    title STRING,
    category STRING,
    length INT,
    artist STRING
)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/dim_content/';

INSERT OVERWRITE TABLE dim_content
SELECT * FROM raw_content_metadata;

DROP TABLE IF EXISTS fact_user_actions;
CREATE TABLE fact_user_actions (
    user_id INT,
    content_id INT,
    action STRING,
    event_time TIMESTAMP,
    device STRING,
    region STRING,
    session_id STRING
)
PARTITIONED BY (year INT, month INT, day INT)
STORED AS TEXTFILE;

SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.mapred.mode=nonstrict;
SET mapreduce.job.reduces=5;

INSERT OVERWRITE TABLE fact_user_actions PARTITION (year, month, day)
SELECT 
    user_id, 
    content_id, 
    action, 
    CAST(event_time AS TIMESTAMP), 
    device, 
    region, 
    session_id, 
    year(event_time), 
    month(event_time), 
    day(event_time)
FROM raw_user_logs;
