#!/bin/bash

# Create directories for logs and errors if they don't already exist
mkdir -p log error

# Define array
rng_ga_array=(0 1 2 3 4)

# Loop through all combinations of two distinct elements
for ((i=0; i<${#rng_ga_array[@]}; i++)); do
    for ((j=i+1; j<${#rng_ga_array[@]}; j++)); do
        rng_ga_1=${rng_ga_array[i]}
        rng_ga_2=${rng_ga_array[j]}
        
        log_file="./log/basin_rng_${rng_ga_1}_${rng_ga_2}.log"
        err_file="./error/basin_rng_${rng_ga_1}_${rng_ga_2}.err"

        echo "Launching MATLAB job for (${rng_ga_1}, ${rng_ga_2})"

        nohup matlab -nodisplay -nosplash -r "figS7_1_run_basin(${rng_ga_1}, ${rng_ga_2}); exit;" > "$log_file" 2> "$err_file" &
    done
done

# Wait for all background jobs to complete
wait

echo "All MATLAB tasks completed."
