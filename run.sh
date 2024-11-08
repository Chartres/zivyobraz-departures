#!/bin/bash
while true; do
    python ./departures.py -c ./config/departures.yml
    sleep 60
done

# Extract the cron schedule from departures.yml
CRON_SCHEDULE=$(grep cron_schedule ./config/departures.yml | awk -F': ' '{print $2}' | tr -d "'")

# Debugging output
echo "Extracted CRON_SCHEDULE: $CRON_SCHEDULE"

# Split and write each cron job to the cron file
IFS=';' read -ra SCHEDULES <<< "$CRON_SCHEDULE"
for SCHEDULE in "${SCHEDULES[@]}"; do
  echo "Adding cron job: $SCHEDULE python ./departures.py -c ./config/departures.yml"
  echo "$SCHEDULE python ./departures.py -c ./config/departures.yml" >> /tmp/cron_schedule
done

# Install the new cron jobs from the file
crontab /tmp/cron_schedule

# Start the cron service
cron

# Run any other original commands that might be needed
exec "$@"
