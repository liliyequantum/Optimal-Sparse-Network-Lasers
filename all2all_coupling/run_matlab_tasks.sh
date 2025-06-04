#!/bin/bash

# cd /d/2025/laser_model_local/diode_conclusion/github_code/all2all_coupling

# Make directories for logs and errors
mkdir -p log error

# Define parameters
M_values=(24)                  # Number of lasers
num_rng_w_values=($(seq 0 1))
std_w_values=(14)

# Iterate over all combinations of M, max_step, and disorder_std
for M in "${M_values[@]}"; do
    for num_rng_w in "${num_rng_w_values[@]}"; do
          for std_w in "${std_w_values[@]}";do
                # Generate unique log and error file names
                log_file="./log/all2all_M_${M}_numrngw_${num_rng_w}_stdw_${std_w}.log"
                err_file="./error/all2all_M_${M}_numrngw_${num_rng_w}_stdw_${std_w}.err"
    
                # Run MATLAB function with parameters
                #matlab nohup -nodisplay -r "rescale_all2all_coupling_scan('dde23', ${M}, ${num_rng_w}, ${std_w});exit" \
                #    > "$log_file" 2> "$err_file" &
                matlab -batch "rescale_all2all_coupling_scan('dde23', ${M}, ${num_rng_w}, ${std_w});" \
                    > "$log_file" 2> "$err_file" &
          done 
    done
done

# Wait for all background tasks to complete
wait

echo "All MATLAB tasks completed."