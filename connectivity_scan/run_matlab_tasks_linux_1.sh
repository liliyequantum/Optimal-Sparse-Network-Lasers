#!/bin/bash

# Make directories for logs and errors
mkdir -p log error

# Define parameters
coupling_connectivity_values=($(seq 0 0.01 0.25))
M_values=(42 46 50 55 60 65 70 80 90 100)  
batch_size=5

# Compute total number of rng_w batches
total_rngs=${#M_values[@]}
for ((i = 0; i < total_rngs; i += batch_size)); do
    echo "Starting batch from index $i to $(($i + batch_size - 1))"
    for coupling_connectivity in "${coupling_connectivity_values[@]}"; do   
        for ((j = i; j < i + batch_size && j < total_rngs; j++)); do
            M=${M_values[$j]}

            log_file="./log/freq_connectivity_${coupling_connectivity}_M_${M}.log"
            err_file="./error/freq_connectivity_${coupling_connectivity}_M_${M}.err"

            nohup matlab -nodisplay -nosplash -nojvm -r "rescale_connectivity_scan_run_1('dde23', ${coupling_connectivity}, ${M}); exit;" \
    > "$log_file" 2> "$err_file" &

        done

    done
  # Wait for this batch to finish before starting the next one
    wait
    echo "Completed batch from index $i to $(($i + batch_size - 1))"
done

echo "All MATLAB tasks completed."
