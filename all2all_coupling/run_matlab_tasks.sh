#!/bin/bash

# cd /d/2025/laser_model_local/diode_conclusion/github_code/all2all_coupling

# Make directories for logs and errors
mkdir -p log error

# Define parameters
M_values=(24)                  # Number of lasers
num_rng_w_values=(1)
std_w_values=(14)
d_step_size=0.05
max_d=1
gamma_n=0.5

# Iterate over all combinations of M, max_step, and disorder_std
for M in "${M_values[@]}"; do
    for num_rng_w in "${num_rng_w_values[@]}"; do
          for std_w in "${std_w_values[@]}";do
                # Generate unique log and error file names
                log_file="./log/all2all_gamman_${gamma_n}_M_${M}_numrngw_${num_rng_w}_stdw_${std_w}.log"
                err_file="./error/all2all_gamman_${gamma_n}_M_${M}_numrngw_${num_rng_w}_stdw_${std_w}.err"
    
                # Run MATLAB function with parameters
                nohup matlab -nodisplay -nosplash -nojvm -r "rescale_all2all_coupling_scan1('dde23', ${M}, ${num_rng_w}, ${std_w},${d_step_size},${max_d},${gamma_n});exit" \
                    > "$log_file" 2> "$err_file" &
          done 
    done
done

# Wait for all background tasks to complete
wait

echo "All MATLAB tasks completed."