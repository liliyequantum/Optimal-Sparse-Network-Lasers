#!/bin/bash

# Make directories for logs and errors
mkdir -p log error

# Define parameters
num_rng_ga_values=(0 1 2 3 4)

for num_rng_ga in "${num_rng_ga_values[@]}"; do      
    # Generate unique log and error file names
    log_file="./log/ga_rng_${num_rng_ga}.log"
    err_file="./error/ga_rng_${num_rng_ga}.err"
    # Run MATLAB function with parameters
    nohup matlab -nodisplay -nosplash -nojvm -r "GA_island(${num_rng_ga}); exit;" > "$log_file" 2> "$err_file" & 
done
     
wait 
echo "All MATLAB tasks completed."
