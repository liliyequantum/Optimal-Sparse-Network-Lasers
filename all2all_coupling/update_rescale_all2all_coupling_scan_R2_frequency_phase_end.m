% function rescale_all2all_coupling_scan(M, num_rng_w, std_w) 

clear;clc;close all;
maxNumCompThreads(1);
% make sure w_0\times lag = 2k\pi
addpath('../'); % to include two functions, lk_vcsel_dde23.m and lk_vcsel_abm4milshtein.m

% default method = 'dde23'; % 'dde23' time delay differential equation(dde); 
M = 24;
num_rng_w = 1;
std_w = 14;

data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
    num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']);
params.detuning = data.sorted_W;
params.M = length(params.detuning);

initial_state_noise_switch = 0; %with noise: 1, without: 0
max_step = 1e-2; % default dde23

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
params.gamma_n = 0.5;%0.5; % carrier loss, ns^-1
params.gamma_n_noise = params.gamma_n/N_bar;
params.j0 = 1/N_bar * 4 * params.gamma_n * (params.N0 * N_bar + params.gamma / params.g); % pump current, ns^-1
params.Rsp = 5/I_bar; % GHz  spontaneous emission noise radius

d_array = 0:0.02:1;%[0, 0.4, 1];%0:0.1:3;%[0:0.05:3, 3.2:0.2:5];
num_d = length(d_array);

t_start = 50; % ns
t_end = 100; % ns
L = (t_end-t_start)/1e-3;
t = linspace(t_start,t_end,L); 
dt = t(2)-t(1);

ave_S_array = zeros(num_d,1);
ave_R2_array = zeros(num_d,1);
delta_mean_array = zeros(num_d, M);
delta_std_array = zeros(num_d, M);
varphi_mean_array = zeros(num_d, M);
varphi_std_array = zeros(num_d, M);
K_cell = cell(num_d, 1);
tic
for didx = 1:num_d
    % didx = 9;%num_d;
    d = d_array(didx);
    params.coupling_matrix = d * (ones(M)-eye(M));    % .* exp(-1i .* params.freq_ref .* tau); % make sure w_0\times lag = 2k\pi 
    K_cell{didx, 1} = params.coupling_matrix;
    [sol, ~, ~, ~,~, ~] = lk_dde23(max_step, params,initial_state_noise_switch);
    
    y = deval(t,sol);
    E_sol = zeros(M, length(t));
    for Midx = 1:M
        E_sol(Midx,:) = y(Midx,:) + 1i*y(Midx+M,:);
    end

    % Reconstruct the complex electric field E
    S = abs(sum(E_sol,1)).^2./sum(abs(E_sol).^2,1)./M;
    R2 = abs(sum(E_sol./abs(E_sol),1)).^2./M.^2;
    ave_S_array(didx) = sum(S)./length(t);
    ave_R2_array(didx) = sum(R2)./length(t);

    %  Set up sliding window parameters
    window_size = round(3*params.tau_const/dt);     % Number of points in each window
    step_size   = round(window_size/10);      % Slide window by this many points each time
    N = length(t);
    num_windows = floor((N - window_size) / step_size) + 1;

    % figure(1); hold on;
    for Midx = 1:M
        freq_E_time = zeros(num_windows,1);
        phi_E = unwrap(angle(E_sol(Midx,:)));
        for i = 1:num_windows
            idx_start = (i-1)*step_size + 1;
            idx_end   = idx_start + window_size - 1;
            t_win   = t(idx_start:idx_end);
            phi_E_win = phi_E(idx_start:idx_end);
            p = polyfit(t_win, phi_E_win, 1);            
            freq_E_time(i) = p(1);  % angular frequency rad/ns   
        end
        delta_mean_array(didx, Midx) = mean(freq_E_time);
        delta_std_array(didx, Midx) = std(freq_E_time);
     
        varphi_E_time = zeros(num_windows,1);
        varphi_E = phi_E - mean(freq_E_time)*t;
        for i = 1:num_windows
            idx_start = (i-1)*step_size + 1;
            idx_end   = idx_start + window_size - 1;
            varphi_E_win = varphi_E(idx_start:idx_end); 
            varphi_E_time(i) = mean(varphi_E_win);  % angular frequency rad/ns   
        end
        varphi_mean_array(didx,Midx) = mean(varphi_E_time);
        varphi_std_array(didx,Midx) = std(varphi_E_time);
        % plot(1:num_windows, varphi_E_time);
    end

    disp(['progress: ', num2str(didx/num_d)])
end
toc

clear E_sol
mkdir('data')
save(['./data/update_R2_freq_diode_data_d_',num2str(d_array(2)-d_array(1)),'_',num2str(d_array(end)),'_M_',num2str(M),'_num_rng_w_', num2str(num_rng_w),...
    '_std_w_',num2str(std_w),'.mat'],'-v7.3')
% 
% end

