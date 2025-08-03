#!/bin/bash

# Read the config values from YAML
SLEEP_SECONDS=$(awk -F": " '/sleep_seconds:/ {print $2}' ./config/departures.yml)
NO_RUN=$(awk -F": " '/no_run_hours:/ {print $2}' ./config/departures.yml | tr "," " ")

while true; do
  # Get current hour in 24-hour format
  HOUR=$(date +%H)
  SKIP=false

  # Iterate over each no-run range
  for RANGE in $NO_RUN; do
    START=${RANGE%-*}
    END=${RANGE#*-}
    # Check normal range (e.g. 13-14) or midnight-crossing range (e.g. 23-06)
    if (( (START < END && HOUR >= START && HOUR < END) || (START > END && (HOUR >= START || HOUR < END)) )); then
      echo "$(date) - Skipping execution (range $START-$END)"
      SKIP=true
      break
    fi
  done

  if [ "$SKIP" = false ]; then
    echo "$(date) - Running departures.py"
    python ./departures.py -c ./config/departures.yml
  fi

  sleep "$SLEEP_SECONDS"
done
