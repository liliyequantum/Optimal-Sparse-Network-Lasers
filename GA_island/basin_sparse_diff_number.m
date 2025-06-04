   clear;
    maxNumCompThreads(1);
    addpath('../')
    rng('shuffle')
    
    rng_ga_1 = 0; % rng_ga
    rng_ga_2 = 1; % rng_ga
    
    M = 24;
    num_rng_w = 1;
    std_w = 14;
    
    %% load detuning
    data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
        num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']);
    detuning = data.sorted_W;
    
    %% load coupling matrix
    data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w),...
            '_rngga_',num2str(0),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
    K_0 = data.bestAdjMatrix;
    data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w),...
            '_rngga_',num2str(1),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
    K_1 = data.bestAdjMatrix;
    data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w),...
            '_rngga_',num2str(2),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
    K_2 = data.bestAdjMatrix;
    data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w),...
            '_rngga_',num2str(3),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
    K_3 = data.bestAdjMatrix;
    data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w),...
            '_rngga_',num2str(4),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
    K_4 = data.bestAdjMatrix;
    
  
Ks = {K_0, K_1, K_2, K_3, K_4};
num_matrices = length(Ks);
diff_count_matrix = zeros(num_matrices);

for i = 1:num_matrices
    for j = i+1:num_matrices
        diff_count_matrix(i,j) = sum(sum(Ks{i} ~= Ks{j}));
        diff_count_matrix(j,i) = diff_count_matrix(i,j);  % symmetry
    end
end

disp('Pairwise difference counts between matrices:');
disp(diff_count_matrix);
