clear;

num_rng_w_array = 0:99;
rng_ga_array = 0:4;
best_value_2d = zeros(length(num_rng_w_array),length(rng_ga_array));
for widx = 1:length(num_rng_w_array)
    for gidx = 1:length(rng_ga_array)
        data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w_array(widx)),...
            '_rngga_',num2str(rng_ga_array(gidx)),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
        best_value_2d(widx,gidx) = data.bestValue;
    end
end

[best_S,best_rng_index] = max(best_value_2d,[],2);

M = 24;
optimized_K = zeros(M,M,length(num_rng_w_array));
for widx = 1:length(num_rng_w_array)
    data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w_array(widx)),...
            '_rngga_',num2str(rng_ga_array(best_rng_index(widx))),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
    optimized_K(:,:,widx) = data.bestAdjMatrix;
end

detuning_2d = zeros(M,length(num_rng_w_array));
for i = 1:length(num_rng_w_array)
    num_rng_w = num_rng_w_array(i);
    data = load(['../freq_disorders/M_24/freq_disorder_M_24_num_rng_w_',...
        num2str(num_rng_w),'_std_w_14.mat']); 
    detuning_2d(:,i) = data.sorted_W;
end

save('GA_optimized_LK_data.mat','optimized_K','best_S','detuning_2d')