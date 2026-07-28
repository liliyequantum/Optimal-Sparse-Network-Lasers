clear;
S_array = zeros(10,1);
for i = 0:9
    data = load(['./data/diode_data_connectivity_1_num_rng_w_',num2str(i),'.mat']);
    S_array(i+1) = data.ave_S_array;
end

mean(S_array)