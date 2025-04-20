#!/bin/bash
set -euo pipefail

# Usage: 
#   start=$(date +%s.%N) # or start=$SECONDS
#   sleep 3661.123  # 1 hour, 1 minute, 1.123 seconds
#   elapsed_time "$start"  # Output: "01h 01m 01.123s"

elapsed_time() {
  local -- end_time=${2:-"$(date +%s.%N)"} start_time="${1:-0}"
  
  # Calculate total seconds
  local -- days='0' hours='0' minutes='0'
  local -- elapsed='0'
  elapsed=$(echo "$end_time - $start_time" | bc --mathlib)
  # Calculate days
  days=$(echo "$elapsed / 86400" | bc)
  if (( days > 0 )); then
    printf "%dd " "$days"
    elapsed=$(echo "$elapsed - (86400 * $days)" | bc)
  fi
  
  # Calculate hours
  hours=$(echo "$elapsed / 3600" | bc)
  if (( hours > 0 || days > 0 )); then
    printf "%02dh " "$hours"
    elapsed=$(echo "$elapsed - (3600 * $hours)" | bc)
  fi
  
  # Calculate minutes
  minutes=$(echo "$elapsed / 60" | bc)
  if (( minutes > 0 || hours > 0 || days > 0 )); then
    printf "%02dm " "$minutes"
    elapsed=$(echo "$elapsed - (60 * $minutes)" | bc)
  fi
  
  # Always show seconds
  printf "%.3fs" "$elapsed"
  echo
}

# If script is called directly (not sourced), execute with provided arguments
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  (($#==0)) || [[ $1 == '-h' || $1 == '--help' ]] && {
    cat >&2 <<-EOT
usage: $(basename -- "$0") start_time [end_time]

start=\$(date +%s.%N)   # or start=\$SECONDS
sleep 3661.123          # 1 hour, 1 minute, 1.123 seconds
elapsed_time "\$start"  # Output: "01h 01m 01.123s

elapsed_time 420.42678823 422.8223233

elapsed_time 0 3601.238

EOT
    (($#)) && exit 0
    exit 1
  }

  elapsed_time "$@"
fi

#fin
