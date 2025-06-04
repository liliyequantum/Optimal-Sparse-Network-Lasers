clear;close all;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

% Parameters
M = 24; % Nodes (Adjacency Matrix Size)
type_freq_disorder = 'gaussian';

std_w = 14;

num_rng_w_array = 0:1:9;
num_wrng = length(num_rng_w_array);
K_3d = zeros(M,M,num_wrng);
varphijtaui_3d = zeros(M,M,num_wrng);
for rngwidx = 1:num_wrng
    num_rng_w = num_rng_w_array(rngwidx);
    data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
    num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']); 
    W = data.sorted_W; % detuning

    if num_rng_w == 0
        data = load('./data/GA_island_gaussian_rngw_0_rngga_2_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    elseif num_rng_w == 1
        % data = load('./data/GA_island_gaussian_rngw_1_rngga_1_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
        data = load('./data_num_rng_w_1/GA_island_gaussian_con_0.4_rng_3_popSize_100_numGen_100_mutRate_0.03_elite_8_numIs_2_migInter_5_ migFrac_0.05.mat');
    elseif num_rng_w == 2
        data = load('./data/GA_island_gaussian_rngw_2_rngga_0_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    elseif num_rng_w == 3
        data = load('./data/GA_island_gaussian_rngw_3_rngga_0_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    elseif num_rng_w == 4
        data = load('./data/GA_island_gaussian_rngw_4_rngga_0_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    elseif num_rng_w == 5
        data = load('./data/GA_island_gaussian_rngw_5_rngga_1_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    elseif num_rng_w == 6
        data = load('./data/GA_island_gaussian_rngw_6_rngga_4_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    elseif num_rng_w == 7
        data = load('./data/GA_island_gaussian_rngw_7_rngga_1_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    elseif num_rng_w == 8
        data = load('./data/GA_island_gaussian_rngw_8_rngga_4_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    elseif num_rng_w == 9
        data = load('./data/GA_island_gaussian_rngw_9_rngga_1_popSize_200_numGen_200_numIs_4_case_type_slow.mat');
    end
    
    best_S = data.bestValue;
    best_coupling_matrix =  data.bestAdjMatrix;
    K_3d(:,:,rngwidx) = best_coupling_matrix;
    [sol, t_sol, E_sol, N_sol, Iss, Nss, S, ave_S] = ...
        Diode_Lang_Kobayashi_Eq('dde23', W,  best_coupling_matrix);
    
    t_start = 0; % ns
    L = 100001; % Number of time points
    x = linspace(t_start,t_sol(end),L); %
    % x = t_sol;
    dx = x(2)-x(1);
    tau = 3;
    num_tau = tau/dx;
    tic
    y = deval(x,sol); % interpolation check, compare with abm and dde23
    toc
    E_sol_deval = zeros(M,L);
    N_sol_deval = zeros(M,L);
    r_sol_deval = zeros(M,L);
    phase_sol_deval = zeros(M,L);
    for Midx = 1:M
        E_sol_deval(Midx,:) = y(Midx,:)+1i*y(Midx+M,:);
        N_sol_deval(Midx,:) = y(Midx+2*M,:);
        r_sol_deval(Midx,:) = abs(E_sol_deval(Midx,:));
        phase_sol_deval(Midx,:) = unwrap(angle(E_sol_deval(Midx,:)));
    end
    
    N0 = 1.5e8; %  number of carriers at transparency
    s = 2e-7; % gain saturation coefficient
    g = 1.5e-5; % gain coefficient, ns^-1 with efficiency \eta_i = 90%
    gamma = 500;
    gamma_n = 0.5;
    alpha = 5;
    j0 = 4 * gamma_n * (N0 + gamma / g); 
    
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

save('K_phase_data.mat','K_3d','varphijtaui_3d')