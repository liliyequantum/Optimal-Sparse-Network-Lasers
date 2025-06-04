#!/bin/bash

# Make directories for logs and errors
mkdir -p log error

# Define parameters
num_rng_w=0
num_rng_ga=0
popSize=4
numGenerations=2
numIslands=2
case_type="fast"

# Generate unique log and error file names
log_file="./log/ga_num_rng_ga_${num_rng_ga}_casetype_${case_type}.log"
err_file="./error/ga_num_rng_ga_${num_rng_ga}_casetype_${case_type}.err"

# Run MATLAB function with parameters
#nohup matlab -nodisplay -nosplash -nojvm -r "GA_island('gaussian', ${num_rng_w}, ${num_rng_ga}, ${popSize}, ${numGenerations}, ${numIslands}, '${case_type}'); exit;" > "$log_file" 2> "$err_file" &
matlab -batch "GA_island('gaussian', ${num_rng_w}, ${num_rng_ga}, ${popSize}, ${numGenerations}, ${numIslands}, '${case_type}'); exit;" > "$log_file" 2> "$err_file" &

# Wait for all background tasks to complete
wait

echo "All MATLAB tasks completed."
