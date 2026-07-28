clear;close all;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

% Parameters
M = 24; % Nodes (Adjacency Matrix Size)
type_freq_disorder = 'gaussian';
std_w = 14;
num_rng_w_array = 0:99;

data = load('GA_optimized_LK_data.mat');
K_3d = data.optimized_K;

num_wrng = length(num_rng_w_array);
varphijtaui_3d = zeros(M,M,num_wrng);
for rngwidx = 1:num_wrng
    num_rng_w = num_rng_w_array(rngwidx);
    data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
    num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']); 
    W = data.sorted_W; % detuning

    [sol, t_sol, ~, ~, ~, ~, ~, ~] = ...
        Diode_Lang_Kobayashi_Eq('dde23', W,  K_3d(:,:,rngwidx));
    
    t_start = 0; % ns
    L = 100001; % Number of time points
    x = linspace(t_start,t_sol(end),L); %
    dx = x(2)-x(1);
    tau = 3;
    num_tau = tau/dx;
    tic
    y = deval(x,sol); % interpolation check, compare with abm and dde23
    toc
    E_sol_deval = zeros(M,L);
    phase_sol_deval = zeros(M,L);
    for Midx = 1:M
        E_sol_deval(Midx,:) = y(Midx,:)+1i*y(Midx+M,:);
        phase_sol_deval(Midx,:) = unwrap(angle(E_sol_deval(Midx,:)));
    end

    %% short-term 
    window_size = 3*tau*1/dx;     % Number of points in each window
    step_size   = round(window_size/10);      % Slide window by this many points each time
    t = x(end-floor(L/2):end);
    N = length(t);
    num_windows = floor((N - window_size) / step_size) + 1;
    
    %% \phi_i(t), final frequency
    freq_fit_time = zeros(M,num_windows);
    freq_fit_mean = zeros(M,1);
    freq_fit_std = zeros(M,1);
    phi_time = zeros(M,num_windows);
    time_center = zeros(M, num_windows);  % Time center of each window
    for Midx=1:M
        phi = phase_sol_deval(Midx,end-floor(L/2):end);  % Unwrapped phase
        % Loop over sliding windows
        for i = 1:num_windows
            idx_start = (i-1)*step_size + 1;
            idx_end   = idx_start + window_size - 1;
            t_win   = t(idx_start:idx_end);
            time_center(Midx,i) = mean(t_win);
     
            phi_win = phi(idx_start:idx_end);
            p = polyfit(t_win, phi_win, 1);   % Linear fit to the unwrapped phase           
            freq_fit_time(Midx,i) = p(1);  % Angular frequency % GHz, depending on t units)
    
            phi_time(Midx,i) = mean(phi_win);  
        end
        freq_fit_mean(Midx) = mean(freq_fit_time(Midx,:));  
        freq_fit_std(Midx) = std(freq_fit_time(Midx,:));
    end
    freq_fit_bar = mean(freq_fit_mean);
    freq_fit_max_std = max(freq_fit_std);
    varphi_time = mod(phi_time - freq_fit_bar * time_center + pi, 2*pi) - pi;
    
    % %% \varphi_j(t-\tau)-\varphi_i(t)
    varphijtaui_time = zeros(M,M,num_windows-3);
    varphijtaui = zeros(M,M);
    varphijtaui_std = zeros(M,M);
    for i = 1:M
        for j = 1:M      
            varphijtaui_time(i,j,:) = mod(varphi_time(j,1:end-3)-varphi_time(i,4:end) + pi, 2*pi) - pi;
            varphijtaui(i,j) = mean(varphijtaui_time(i,j,:));
            varphijtaui_std(i,j) = std(varphijtaui_time(i,j,:));
        end
    end

    varphijtaui_3d(:,:,rngwidx) = varphijtaui;
    disp(['progress: ',num2str(rngwidx/num_wrng)])
end

save('phase_ij_data.mat')