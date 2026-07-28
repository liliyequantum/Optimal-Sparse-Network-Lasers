#!/bin/bash

# cd /d/laser_model_local/diode_conclusion/code/noise_scan

# Make directories for logs and errors
mkdir -p log error

# Define parameters
init_noise_var_values=(0.1)
dynamic_noise_var_values=(0.4)
num_sample_values=(10)

for init_noise_var in "${init_noise_var_values[@]}"; do
    for dynamic_noise_var in "${dynamic_noise_var_values[@]}"; do
        for num_sample in "${num_sample_values[@]}"; do
            log_file="./log/noise_scan_init_${init_noise_var}_dynamic_${dynamic_noise_var}_num_sample_${num_sample}.log"
            err_file="./error/noise_scan_init_${init_noise_var}_dynamic_${dynamic_noise_var}_num_sample_${num_sample}.err"
            nohup matlab -nodisplay -r "figS5_1_noise_scan(${init_noise_var}, ${dynamic_noise_var}, ${num_sample});exit" > "$log_file" 2> "$err_file" &     
        done  
    done
done

# Wait for all background tasks to complete
wait

echo "All MATLAB tasks completed."
#export PATH="/c/Program Files/MATLAB/R2024a/bin:$PATH"
