#!/bin/bash

# Make directories for logs and errors
mkdir -p log error

# Define parameters
coupling_connectivity_values=($(seq 0 0.05 1))
num_rng_w_values=($(seq 60 99))  # 90 values total
batch_size=10

# Compute total number of rng_w batches
total_rngs=${#num_rng_w_values[@]}
for ((i = 0; i < total_rngs; i += batch_size)); do
    echo "Starting batch from index $i to $(($i + batch_size - 1))"
    for coupling_connectivity in "${coupling_connectivity_values[@]}"; do   
        for ((j = i; j < i + batch_size && j < total_rngs; j++)); do
            num_rng_w=${num_rng_w_values[$j]}

            log_file="./log/freq_connectivity_${coupling_connectivity}_rng_${num_rng_w}.log"
            err_file="./error/freq_connectivity_${coupling_connectivity}_rng_${num_rng_w}.err"

            nohup matlab -nodisplay -nosplash -nojvm -r "rescale_connectivity_scan_run('dde23', ${coupling_connectivity}, ${num_rng_w}); exit;" \
    > "$log_file" 2> "$err_file" &

        done

    done
  # Wait for this batch to finish before starting the next one
    wait
    echo "Completed batch from index $i to $(($i + batch_size - 1))"
done

echo "All MATLAB tasks completed."
