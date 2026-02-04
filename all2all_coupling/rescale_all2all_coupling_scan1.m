function rescale_all2all_coupling_scan1(method, M, num_rng_w, std_w, d_step_size, max_d, gamma_n) 

% clear;clc;close all;
maxNumCompThreads(1);
% make sure w_0\times lag = 2k\pi
addpath('../'); % to include two functions, lk_vcsel_dde23.m and lk_vcsel_abm4milshtein.m

% method = 'dde23'; % 'dde23' time delay differential equation(dde); 
% M = 24;
% num_rng_w = 1;
% std_w = 14;

data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
    num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']);
params.detuning = data.sorted_W;
params.M = length(params.detuning);

initial_state_noise_switch = 0; %with noise: 1, without: 0
% 'abm4milshtein' for dde when noise_switch = 0; 
% for time delay stochastic delay differential equation (sdde) when noise_switch = 1
if strcmp(method, 'dde23')
    max_step = 1e-2; % for dde23
elseif strcmp(method,  'abm4milshtein')
    h_abm = 1e-3; % for abm_noise
    noise_switch = 0; % for abm4milshtein, with noise: 1, without: 0
end

N_bar = 2e8;
I_bar = 5.5e5;
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
params.gamma_n = gamma_n;%0.5;%0.5; % carrier loss, ns^-1
params.gamma_n_noise = params.gamma_n/N_bar;
params.j0 = 1/N_bar * 4 * params.gamma_n * (params.N0 * N_bar + params.gamma / params.g); % pump current, ns^-1
params.Rsp = 5/I_bar; % GHz  spontaneous emission noise radius

d_array = 0:d_step_size:max_d;
num_d = length(d_array);

ave_S_array = zeros(num_d,1);
K_cell = cell(num_d, 1);
tic
for idx = 1:num_d
    % i = num_d;
    d = d_array(idx);
    params.coupling_matrix = d * (ones(M)-eye(M));    % .* exp(-1i .* params.freq_ref .* tau); % make sure w_0\times lag = 2k\pi 
    K_cell{idx, 1} = params.coupling_matrix;
    if strcmp(method, 'dde23')
        % dde23
        [~, t_cell, E_cell, ~,~, ~] = lk_dde23(max_step, ...
            params,initial_state_noise_switch);
    elseif strcmp(method,  'abm4milshtein')
        % abm
        [t_cell, E_cell, ~, ~, ~] = lk_abm4milshtein(h_abm, noise_switch,...
            params,initial_state_noise_switch);
    end
    
    t_sol = t_cell{1};
    E_sol = E_cell{1};
    % N_sol = N_cell{1};
    % Iss = Iss_cell{1};
    % Nss = Nss_cell{1};

    % Reconstruct the complex electric field E
    S = abs(sum(E_sol,1)).^2./sum(abs(E_sol).^2,1)./M;
    index = find(t_sol > round(t_sol(end)/2), 1);
    ave_S_array(idx) = sum(S(index:end))./length(t_sol(index:end));
 
    disp(['progress: ', num2str(idx/num_d)])
end
toc

clear t_sol E_sol t_cell E_cell
mkdir('data_homo')
save(['./data_homo/gamman_',num2str(gamma_n),'_diode_data_M_',num2str(M),'_num_rng_w_', num2str(num_rng_w),...
    '_std_w_',num2str(std_w),'.mat'],'-v7.3')

end

