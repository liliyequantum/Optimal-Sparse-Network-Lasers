#!/bin/bash

# cd /d/2025/laser_model_local/diode_conclusion/github_code/all2all_coupling

# Make directories for logs and errors
mkdir -p log error

# Define parameters
dk=0.001
alpha_values=(0 5)

for alpha in "${alpha_values[@]}"; do
    # Generate unique log and error file names
    log_file="./log/birfurcation_alpha_${alpha}.log"
    err_file="./error/birfurcation_alpha_${alpha}.err"
    
    # Run MATLAB function with parameters
    nohup matlab -nodisplay -nosplash -nojvm -r "bifurcation_diagram_all2all_data_gen_1(${dk},${alpha});exit" \
        > "$log_file" 2> "$err_file" &   
done        


# Wait for all background tasks to complete
wait

echo "All MATLAB tasks completed."