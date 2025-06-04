#!/bin/bash

# cd /d/laser_model_local/diode_conclusion/code/noise_scan

# Make directories for logs and errors
mkdir -p log error

# Define parameters
log_file="./log/f_perb.log"
err_file="./error/f_perb.err"

# Run MATLAB script using nohup
nohup matlab -nodisplay -nosplash -r "perturb_frequency; exit;" > "$log_file" 2> "$err_file" &

# Wait for all background tasks to complete
wait

echo "All MATLAB tasks completed."
