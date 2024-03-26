#!/bin/bash

# Check if the correct number of arguments is given
if [ "$#" -ne 2 ]; then
   echo "Usage: $0 <number of threads> <number of runs>"
   exit 1
fi

num_threads=$1
num_runs=$2
segFault=false
con_time=()

# Create the output file & write the header
output_file="timings_knapsackPT1_local.csv"
echo "Threads, Time (ms)" > $output_file


for (( i=1; i<=num_threads; i=(i*2) )); do
  total_real_time=0
  #total_user_time=0
  #total_sys_time=0


  for (( j=1; j<=num_runs; j++ )); do
    # Capture the real, user, and sys time for each run
    # read -r real_time user_time sys_time <<< $(/usr/bin/time -p ./knapsackpar input "$i" 2>&1 | awk '/real/ {r=$2} /user/ {u=$2} /sys/ {s=$2} END {print r, u, s}')
    output=$(/usr/bin/time -p ./knapsackpar input "$i" 2>&1)
    exit_status=$?

    if [ $exit_status -eq 139 ]; then
      echo "Segmentation fault encountered for $i threads on run $j."
      real_time=0
      break
    else
      # No Segmentation Fault, parse the time measurements
      read -r real_time user_time sys_time <<< $(echo "$output" | awk '/real/ {r=$2} /user/ {u=$2} /sys/ {s=$2} END {print r, u, s}')
    fi

    # Use bc for floating-point addition
    total_real_time=$(echo "$total_real_time + $real_time" | bc)

    echo "Threads: $i, Run $j : real $total_real_time"
  done

  # Calculate the average real time
  # add the average real time to the array
  average_real_time=$(echo "scale=2; $total_real_time / $num_runs" | bc)
  echo "Average Real Time for $i threads: $average_real_time"
  con_time+=($average_real_time)
done

for (( i=0; i<${#con_time[@]}; i++ )); do
  echo "$((i + 1)), ${con_time[$i]}" >> "$output_file"
done

echo "Good bye!"


