clear;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

data = load('bestAdjMatrix_at_each_connect.mat');
bestAdjMatrix_connect_cell = data.bestAdjMatrix_connect_cell;
connectivity_array = data.connectivity_array;

data = load('../freq_disorders/M_24/freq_disorder_M_24_num_rng_w_1_std_w_14.mat'); 
W = data.sorted_W;
M = 24;
method = 'dde23';%'abm4milshtein';%

freq_E_win_mean = zeros(M,length(connectivity_array));
freq_E_win_std = zeros(M, length(connectivity_array));

for cidx = 1:length(connectivity_array)
    coupling_matrix = bestAdjMatrix_connect_cell{cidx};
    tic
    [sol, t_sol, ~, ~, ~, ~, ~, ave_S] = ...
        Diode_Lang_Kobayashi_Eq(method, W,  coupling_matrix);
    toc
    
    if strcmp(method, 'dde23')
         t_end = t_sol(end);
         t_start = t_end/2; % ns 
         L = (t_end-t_start)/1e-3;
         t = linspace(t_start,t_end,L); % start from 7.5 ns to aviod the transient dynamics
         y = deval(t,sol);        
         E = y(1:M,:) + 1i * y(M+1:2*M,:);
     else
         t = t_sol(floor(end/2):end);
         E = E_sol(:,floor(end/2):end);    
     end
    indicator_cell = freq_locking_indicator(t, E);
            
    freq_E_win_mean(:,cidx) = indicator_cell{1};
    freq_E_win_std(:,cidx) = indicator_cell{2};
    disp(['progress: ',num2str(cidx/length(connectivity_array))])
end

save('data_final_frequency_bestAdjMatrix_each_connect.mat',...
    'freq_E_win_mean','freq_E_win_std','connectivity_array')
%% plot coupling_matrix
% figure(1); clf;
% hold on;
% set(gca, 'FontSize', 20, 'LineWidth', 1);
% xlabel('No. Laser'); ylabel('No. Laser');
% [row, col] = find(coupling_matrix);  % find nonzero (1) entries
% scatter(col, row, 100, 'k',...
%     's', 'filled'); hold on;% 's' = square marker
% % Axes settings
% axis equal; axis tight;
% xlim([0.5, 24.5]); ylim([0.5, 24.5]);
% xticks([1,12,24]); yticks([1,12,24]);
% xticklabels({'1', '12', '24'}); yticklabels({'1', '12', '24'});
% set(gca, 'YDir', 'reverse');  % To match image matrix layout
% % title('Overlay of 10 Optimized Coupling Matrices');
% colormap([1 1 1; 0 0 0]); % White for 0, Black for 1
% c = colorbar;
% c.Ticks = [0.25, 0.75]; % Midpoints for better alignment
% c.TickLabels = {'0', '1'};
% c.Label.Interpreter = 'latex';

function indicator_cell = freq_locking_indicator(t, E)
    indicator_cell = cell(2,1);
    %% short-term window preparation
    dt = t(2)-t(1);
    [M, ~] = size(E);

    %  Set up sliding window parameters
    tau = 3;%diode
    window_size = round(3*tau/dt);     % Number of points in each window
    step_size   = round(window_size/10);      % Slide window by this many points each time
    N = length(t);
    num_windows = floor((N - window_size) / step_size) + 1;
    
    %% short-term frequency
    phase_E = zeros(M,length(t));
    for Midx = 1:M
        phase_E(Midx,:) = unwrap(angle(E(Midx,:)));
    end
    
    freq_E_time = zeros(M, num_windows);  % Frequency at each window
    time_center = zeros(M, num_windows);  % Time center of each window
    for Midx=1:M
        phi_E = phase_E(Midx,:);  % Unwrapped phase
        for i = 1:num_windows
            idx_start = (i-1)*step_size + 1;
            idx_end   = idx_start + window_size - 1;
            t_win   = t(idx_start:idx_end);
            phi_E_win = phi_E(idx_start:idx_end);
            p = polyfit(t_win, phi_E_win, 1);            
            freq_E_time(Midx,i) = p(1)/2/pi;  % frequency GHz, depending on t units)
            time_center(Midx,i) = mean(t_win);    % Time at the center of this window
        end
    end
    freq_E_win_mean = mean(freq_E_time, 2);  % mean along rows(time)
    freq_E_win_std  = std(freq_E_time, 0, 2);  % std along rows(time)
    
    indicator_cell{1} = freq_E_win_mean; % frequency
    indicator_cell{2} = freq_E_win_std;
    
    
end