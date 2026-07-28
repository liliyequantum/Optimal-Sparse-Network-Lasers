#!/bin/bash
# cd /d/2025/laser_model_local/diode_conclusion/github_code/freq_disorders

# Create folders for output
mkdir -p log error

M_values=(12 50)      

for M in "${M_values[@]}"; do

    log_file="./log/all2all_M_${M}.log"
    err_file="./error/all2all_M_${M}.err"

    # Run MATLAB function with parameters for linux
    # matlab nohup -nodisplay -r "freq_disorder_gen(${M});exit" \
     #   > "$log_file" 2> "$err_file" & 
    
    # Run MATLAB function with parameters for windows
    matlab -batch "freq_disorder_gen(${M});" \
        > "$log_file" 2> "$err_file" &

done

# Define log and error files
# Wait for background process to finish
wait

echo "All MATLAB tasks completed."