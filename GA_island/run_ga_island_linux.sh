#!/bin/bash

# Make directories for logs and errors
mkdir -p log error

# Define parameters
num_rng_w_values=($(seq 0 99))
num_rng_ga_values=(0 1 2 3 4)
batch_size=5

popSize=200
numGen=200
numIslands=4
case_type="slow"

total_rngs=${#num_rng_w_values[@]}
for ((i=10; i<total_rngs; i+=batch_size)); do
    echo "Starting batch from index $i to $(($i+batch_size-1))"
    for ((j=i; j<i+batch_size && j<total_rngs; j++)); do
        num_rng_w=${num_rng_w_values[$j]}
        for num_rng_ga in "${num_rng_ga_values[@]}"; do      
            # Generate unique log and error file names
            log_file="./log/ga_rngw_${num_rng_w}_rng_${num_rng_ga}_${case_type}_pop_${numGen}.log"
            err_file="./error/ga_rngw_${num_rng_w}_rng_${num_rng_ga}_${case_type}_pop_${numGen}.err"
            # Run MATLAB function with parameters
            nohup matlab -nodisplay -nosplash -nojvm -r "GA_island('gaussian', ${num_rng_w}, ${num_rng_ga}, ${popSize}, ${numGen}, ${numIslands}, '${case_type}'); exit;" > "$log_file" 2> "$err_file" & 
         done
    done
    # Wait for this batch to finish before starting the next one
    wait
    echo "Completed batch from index $i to $(($i + batch_size - 1))"
done

echo "All MATLAB tasks completed."
