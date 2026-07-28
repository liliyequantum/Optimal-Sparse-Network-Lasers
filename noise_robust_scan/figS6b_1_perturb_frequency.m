clear;
maxNumCompThreads(1);
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq
rng('shuffle');

sigma_f_perb_array = [0.1, 0.5, 1, 3, 5, 10]; % rand/ns
num_sample = 100;

num_sigma = length(sigma_f_perb_array);
init_state_noise_switch = 0;
dynamic_noise_switch = 0;
init_noise_var = 1e-1;
dynamic_noise_var = 1; % R_sp GHz
data = load('../GA_island/data_num_rng_w_1/GA_island_gaussian_con_0.4_rng_3_popSize_100_numGen_100_mutRate_0.03_elite_8_numIs_2_migInter_5_ migFrac_0.05.mat');
coupling_matrix = data.bestAdjMatrix;
S_best = data.bestValue;
data = load('../freq_disorders/M_24/freq_disorder_M_24_num_rng_w_1_std_w_14.mat'); 
W = data.sorted_W; % detuning
M = length(W);
method = 'dde23';%'abm4milshtein';%
f_perb = randn(M,num_sample,num_sigma);
for sidx = 1:num_sigma
    f_perb(:,:,sidx) = sigma_f_perb_array(sidx) * f_perb(:,:,sidx); 
end

ave_S_sample = zeros(num_sample,num_sigma);
std_S_sample = zeros(num_sample,num_sigma);
tic
for sidx = 1:num_sigma
    for i = 1:num_sample
        W_perb = W + f_perb(:,i,sidx);
        [~, t_sol, ~, ~, ~, ~, S, ave_S_sample(i,sidx)] = ...
         Diode_Lang_Kobayashi_Eq_noise(method, W_perb, coupling_matrix,...
            init_state_noise_switch, init_noise_var, dynamic_noise_switch, dynamic_noise_var);
        
        index = find(t_sol>round(t_sol(end)/2),1);
        std_S_sample(i,sidx) = std(S(index:end));
        
    end
    disp(['progress: ',num2str(sidx/num_sigma)])
end
toc
save('data_perb_w.mat')    

