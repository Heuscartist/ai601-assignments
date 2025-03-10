    #!/bin/bash

    # Ensure a date argument is provided
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 YYYY-MM-DD"
        exit 1
    fi

    # Extract year, month, and day from the provided date
    DATE="$1"
    YEAR=$(date -d "$DATE" '+%Y')
    MONTH=$(date -d "$DATE" '+%m')
    DAY=$(date -d "$DATE" '+%d')

    # Define HDFS directories
    HDFS_LOGS_DIR="/raw/logs/$YEAR/$MONTH/$DAY/"
    HDFS_METADATA_DIR="/raw/metadata/"  # Metadata stored in a global directory

    # Define local directories where the data is stored
    LOCAL_LOGS_DIR="./raw_data/$DATE/"
    GLOBAL_METADATA_DIR="./raw_data/metadata/"  # Metadata is taken from a single place

    # Create directories in HDFS if they don't exist
    hdfs dfs -mkdir -p "$HDFS_LOGS_DIR"
    hdfs dfs -mkdir -p "$HDFS_METADATA_DIR"

    # Move log files into HDFS
    if ls "$LOCAL_LOGS_DIR"*.csv 1> /dev/null 2>&1; then
        hdfs dfs -put -f "$LOCAL_LOGS_DIR"*.csv "$HDFS_LOGS_DIR"
        echo "Uploaded log CSV files from $LOCAL_LOGS_DIR to HDFS: $HDFS_LOGS_DIR"
    else
        echo "No log CSV files found in $LOCAL_LOGS_DIR. Skipping..."
    fi

    # Move metadata files into HDFS (from global metadata location)
    if ls "$GLOBAL_METADATA_DIR"*.csv 1> /dev/null 2>&1; then
        hdfs dfs -put -f "$GLOBAL_METADATA_DIR"*.csv "$HDFS_METADATA_DIR"
        echo "Uploaded metadata CSV files from $GLOBAL_METADATA_DIR to HDFS: $HDFS_METADATA_DIR"
    else
        echo "No metadata CSV files found in $GLOBAL_METADATA_DIR. Skipping..."
    fi

    echo "Data ingestion complete for date: $DATE"
