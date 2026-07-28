clear;clc;close all;
method = 'dde23';

% data = load('data_LK.mat');
% detuning = data.detuning_2d(:,2);
% adjMatrix = data.optimized_K(:,:,2);
% S_best = data.best_S(2,1);


data = load('../GA_island/data_num_rng_w_1/GA_island_gaussian_con_0.4_rng_3_popSize_100_numGen_100_mutRate_0.03_elite_8_numIs_2_migInter_5_ migFrac_0.05.mat');
adjMatrix = data.bestAdjMatrix;
S_best = data.bestValue;
data = load('../freq_disorders/M_24/freq_disorder_M_24_num_rng_w_1_std_w_14.mat'); 
detuning  = data.sorted_W; % detuning

maxNumCompThreads(1);
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq
rng('shuffle');
 
params.detuning = detuning;
params.M = length(params.detuning);
params.coupling_matrix = adjMatrix;

initial_state_noise_switch = 0; %with noise: 1, without: 0

max_step = 0.5e-2; % for dde23

N_bar = 1;%2e8;
I_bar = 1;%5.5e5;
tau = 3; % 3 ns for diode; 1 ns for vcsel
% rescale diode parameters
params.freq_ref = 2*pi/tau; % tau 
params.tau_const = tau;%1; % time delay, ns
params.alpha = 5;% linewidth enhancement factor
params.N0 = 1.5e8/N_bar; %  number of carriers at transparency
params.s = 2e-7*I_bar; % gain saturation coefficient
params.g = 1.5e-5; % gain coefficient, ns^-1 with efficiency \eta_i = 90%
params.g_E = params.g*N_bar;
params.g_N = params.g*I_bar;
params.gamma = 500;%500; % cavity loss, ns^-1
params.gamma_n = 0.5;%0.5; % carrier loss, ns^-1
params.gamma_n_noise = params.gamma_n/N_bar;
% perturb_noise = rand;
params.jth = 1/N_bar * params.gamma_n * ...
    (params.N0 * N_bar + params.gamma / params.g); % pump current, ns^-1
params.Rsp = 5/I_bar; % GHz  spontaneous emission noise radius

perturb_array = [1.1,2:10];%-0.9:0.1:0;
S_ave_array = zeros(length(perturb_array),1);
for pidx = 1:length(perturb_array)
    perturb_val = perturb_array(pidx);
    params.j0 = perturb_val * params.jth;
    [sol,  t_cell, E_cell, N_cell, Iss_cell, Nss_cell] = lk_dde23(max_step, ...
        params,initial_state_noise_switch);

    t_sol = t_cell{1};
    E_sol = E_cell{1};
    N_sol = N_cell{1};
    Iss = Iss_cell{1};
    Nss = Nss_cell{1};
    
    S = abs(sum(E_sol,1)).^2./sum(abs(E_sol).^2,1)./params.M;
    index = find(t_sol > round(t_sol(end)/2), 1);
    ave_S = sum(S(index:end))./length(t_sol(index:end));
    S_ave_array(pidx) = ave_S;
    disp(['progress: ',num2str(pidx/length(perturb_array))])
end
save('data_pump_Jth.mat')

mean(abs(E_sol(1,:)).^2)
plot(t_sol,abs(E_sol(1,:)).^2)