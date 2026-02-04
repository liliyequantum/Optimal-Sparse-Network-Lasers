clear;close all;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

% Parameters
M = 24; % Nodes (Adjacency Matrix Size)
type_freq_disorder = 'gaussian';

std_w = 14;

num_rng_w_array = 0:99;
num_wrng = length(num_rng_w_array);
detuning_2d = zeros(M,num_wrng);

data = load('GA_optimized_LK_data.mat');
K_3d = data.optimized_K;

t_start = 50; % ns
t_end = 100; % ns
L = (t_end-t_start)/1e-3;
t = linspace(t_start,t_end,L); 
dt = t(2)-t(1);
tau = 3;

original_delta = zeros(num_wrng,M);
delta_fit_mean_array = zeros(num_wrng,M);
delta_fit_std_array = zeros(num_wrng,M);
varphi_mean_array = zeros(num_wrng,M);
varphi_std_array = zeros(num_wrng,M);
S_array = zeros(num_wrng,L);
R2_array = zeros(num_wrng,L);
for rngwidx = 1:num_wrng
    num_rng_w = num_rng_w_array(rngwidx);
    data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
    num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']); 
    W = data.sorted_W; % detuning
    original_delta(rngwidx,:) = W;
        
    tic
    [sol, ~, ~, ~, ~, ~, ~, ~] = ...
        Diode_Lang_Kobayashi_Eq('dde23', W,  K_3d(:,:,rngwidx));
    y = deval(t,sol); % interpolation check, compare with abm and dde23
    toc

    E_sol = zeros(M,L);
    for Midx = 1:M
        E_sol(Midx,:) = y(Midx,:)+1i*y(Midx+M,:);
    end
    
    % Reconstruct the complex electric field E
    S_array(rngwidx,:) = abs(sum(E_sol,1)).^2./sum(abs(E_sol).^2,1)./M;
    R2_array(rngwidx,:) = abs(sum(E_sol./abs(E_sol),1)).^2./M.^2;
    % a = abs(sum(E_sol./abs(E_sol),1)).^2./M.^2;
    % b = abs(sum(exp(1i*angle(E_sol)),1)).^2./M.^2;
    % max(abs(a-b))
    
    %  Set up sliding window parameters
    window_size = round(3*tau/dt);     % Number of points in each window
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
        delta_fit_mean_array(rngwidx, Midx) = mean(freq_E_time);
        delta_fit_std_array(rngwidx, Midx) = std(freq_E_time);
     
        varphi_E_time = zeros(num_windows,1);
        varphi_E = phi_E - mean(freq_E_time)*t;
        for i = 1:num_windows
            idx_start = (i-1)*step_size + 1;
            idx_end   = idx_start + window_size - 1;
            varphi_E_win = varphi_E(idx_start:idx_end); 
            varphi_E_time(i) = mean(varphi_E_win);  % angular frequency rad/ns   
        end
        varphi_mean_array(rngwidx,Midx) = mean(varphi_E_time);
        varphi_std_array(rngwidx,Midx) = std(varphi_E_time);
        % plot(1:num_windows, mod(varphi_E_time,2*pi));
    end

    disp(['progress: ',num2str(rngwidx/num_wrng)])
end

save('S_R2_delta_fit_varphi_data.mat')