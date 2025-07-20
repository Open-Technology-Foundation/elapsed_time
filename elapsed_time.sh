#!/bin/bash
# elapsed_time: Format time duration as human-readable string
# 
# Usage: elapsed_time start_time [end_time]
#   start_time=$(date +%s.%N)
#   elapsed_time "$start_time"  # Output: "[Nd] [NNh] [NNm] NN.NNNs"

elapsed_time() {
  set -euo pipefail

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

Examples:
  start=\$(date +%s.%N)   # capture start time
  # do something...
  elapsed_time "\$start"  # automatic end time
  
  # explicit start/end times:
  elapsed_time 0 3661.123  # Output: "01h 01m 01.123s"
EOT
    (($#)) && exit 0
    exit 1
  }

  elapsed_time "$@"
fi

#fin
