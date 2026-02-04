#!/bin/bash

# Make directories for logs and errors
mkdir -p log error

# Define parameters
num_rng_ga_values=(0 1 2 3 4)
pump_factor_values=(2 2.5 3 3.5)

for num_rng_ga in "${num_rng_ga_values[@]}"; do     
    for pump_factor in "${pump_factor_values[@]}"; do       
        # Generate unique log and error file names
        log_file="./log/ga_pump_${pump_factor}_rng_${num_rng_ga}.log"
        err_file="./error/ga_pump_${pump_factor}_rng_${num_rng_ga}.err"
        # Run MATLAB function with parameters
        nohup matlab -nodisplay -nosplash -nojvm -r "GA_island_pump(${num_rng_ga},${pump_factor}); exit;" > "$log_file" 2> "$err_file" & 
    done
done
     
wait 
echo "All MATLAB tasks completed."
