#!/bin/bash

# Make directories for logs and errors
mkdir -p log error

# Define parameters#!/bin/bash

# Make directories for logs and errors
mkdir -p log error

# Define parameters
coupling_connectivity_values=($(seq 0 0.02 1))
M=(24) 
pump_factor_values=(2 3) 

# Compute total number of rng_w batches
for coupling_connectivity in "${coupling_connectivity_values[@]}"; do   
    for pump_factor in "${pump_factor_values[@]}"; do      
            log_file="./log/pump_${pump_factor}_connectivity_${coupling_connectivity}.log"
            err_file="./error/pump_${pump_factor}_connectivity_${coupling_connectivity}.err"

            nohup matlab -nodisplay -nosplash -nojvm -r "rescale_connectivity_scan_run_pump('dde23', ${coupling_connectivity}, ${M}, ${pump_factor}); exit;" \
    > "$log_file" 2> "$err_file" &
    done
    
done

wait

echo "All MATLAB tasks completed."
