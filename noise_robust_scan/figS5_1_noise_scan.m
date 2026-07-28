function figS5_1_noise_scan(init_noise_var, dynamic_noise_var, num_sample)
    % clear;close all;
    maxNumCompThreads(1);
    addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq
    rng('shuffle');

    init_state_noise_switch = 1;
    dynamic_noise_switch = 1;
    % init_noise_var = 1e-1;
    % dynamic_noise_var = 1; % R_sp GHz
    % num_sample = 3;

    data = load('../GA_island/data/GA_island_gaussian_con_0.4_rng_3_popSize_100_numGen_100_mutRate_0.03_elite_8_numIs_2_migInter_5_ migFrac_0.05.mat');
    coupling_matrix = data.bestAdjMatrix;
    S_best = data.bestValue;
 
    % Parameters
    M = 24; % Nodes (Adjacency Matrix Size)
    data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_1_std_w_14.mat']); 
    W = data.sorted_W; % detuning
    method = 'abm4milshtein';%'dde23';%

    ave_S_sample = zeros(num_sample,1);
    std_S_sample = zeros(num_sample,1);
    tic
    for i = 1:num_sample
        [~, t_sol, ~, ~, ~, ~, S, ave_S_sample(i)] = ...
         Diode_Lang_Kobayashi_Eq_noise(method, W, coupling_matrix,...
            init_state_noise_switch, init_noise_var, dynamic_noise_switch, dynamic_noise_var);
        
        index = find(t_sol>round(t_sol(end)/2),1);
        std_S_sample(i) = std(S(index:end));
        disp(['progress: ',num2str(i/num_sample)])
    end
    toc
    save(['./data/init_noise_var_',num2str(init_noise_var),'_dynamic_noise_var_',num2str(dynamic_noise_var),...
        '_num_sample_',num2str(num_sample),'.mat'])
end

   
   
