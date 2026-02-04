#!/bin/bash

# cd /d/laser_model_local/diode_conclusion/code/inhomogenous_scan

# Make directories for logs and errors
mkdir -p log error

# Define parameters
var_values=(0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4)
kappa_values=(0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0)
num_sample_values=(1000)

for var in "${var_values[@]}"; do
    for kappa in "${kappa_values[@]}"; do
        for num_sample in "${num_sample_values[@]}"; do
            log_file="./log/inhomo_scan_var_${var}_kappa_${kappa}_num_sample_${num_sample}.log"
            err_file="./error/inhomo_scan_var_${var}_kappa_${kappa}_num_sample_${num_sample}.err"
            nohup matlab -nodisplay -nosplash -nojvm -r "inhomo_scan(${var},${kappa},${num_sample});exit" > "$log_file" 2> "$err_file" &     
        done  
    done
done

# Wait for all background tasks to complete
wait

echo "All MATLAB tasks completed."
#export PATH="/c/Program Files/MATLAB/R2024a/bin:$PATH"
