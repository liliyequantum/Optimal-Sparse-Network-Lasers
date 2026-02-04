clear;close;close all;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];

load('data_LK.mat') % 100 different frequency disorders with 100 optimized sparse matrix by island-based genetic algorithm
% The \Delta_i = 14 Gaussian(0,1) rad/ns with 100 random seeds rng(0-99).
init_state_noise_switch = 0;
init_noise_var = 0.01;
dynamic_noise_switch = 0;
dynamic_noise_var = 30;

% data = load('../freq_disorders/M_200/freq_disorder_M_200_num_rng_w_0_std_w_14.mat');
W = detuning_2d(:,2);%data.sorted_W;%
M = 24;%200;%
best_coupling_matrix = (ones(M)-eye(M));%optimized_K(:,:,2);%
method = 'dde23';%'abm4milshtein';%
tic
% [sol, t_sol, E_sol, N_sol, Iss, Nss, S, ave_S] = ...
%     Diode_Lang_Kobayashi_Eq(method, W,  best_coupling_matrix);
[sol, t_sol, E_sol, N_sol, Iss, Nss, S, ave_S] = ...
    Diode_Lang_Kobayashi_Eq_noise(method, W, best_coupling_matrix,...
    init_state_noise_switch, init_noise_var, dynamic_noise_switch, dynamic_noise_var);
toc

x_start = 10;
y_min = 0;
y_max = 2;
M_array = 1:M;%[2, 4,7,8,13,14,19,20];

time = t_sol(floor(end/2):end);
signal_origin = abs(sum(E_sol,1)).^2;
signal_origin = signal_origin(1,floor(end/2):end);
signal_norm = signal_origin/Iss/M^2;
signal_norm = (signal_norm - mean(signal_norm))./mean(signal_norm);

figure(1);clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
% for Midx = 1:1:length(M_array)
%     signal = abs(E_sol(M_array(Midx), :)).^2 / Iss;  % Power signal
%     time = t_sol;
% 
%     plot(time, signal, 'LineWidth', 1); hold on;
% 
% end
plot(time, signal_origin, 'LineWidth', 1,'Color',green); hold on;
set(gca,'fontsize',22,'LineWidth',1)
xlabel('$t(ns)$','Interpreter','latex')
% ylabel('$|\sum_i E_i|^2/(I_{s}M^2)$','Interpreter','latex')
ylabel('$|E_i|^2$','Interpreter','latex')
% ylabel('$I/I_s$','Interpreter','latex')
% xlim([50,100])
axis tight
% ylim([-0.9,1.1])

exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

std(signal_norm).^2

figure(5);clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
plot(t_sol,S,'LineWidth',1);hold on;
ylim([0,1])
set(gca,'fontsize',18,'FontName','times new roman')
xlabel('$t (ns)$','Interpreter','latex')
ylabel('$\langle S\rangle$','Interpreter','latex')
xlim([0,100])

% Compute cosine of phase
cos_phi = cos(angle(E_sol));  % M x t_len
[~,t_len] = size(E_sol);
% Create time and index grid
t_grid = repmat(t_sol(:)', M, 1);          % M x t_len
M_grid = repmat((1:M)', 1, t_len);         % M x t_len

figure(6); clf;
set(gcf, 'Position', [100, 100, 500, 400]); % Set figure size to 800x600 pixels
surf(t_grid, M_grid, cos_phi, 'EdgeColor', 'none');
view(2);  % 2D top-down view
colormap(parula)
clim([-1, 1])
% colorbar
axis tight
title('$\cos \Omega_{i}(t)$','Interpreter','latex')
xlim([90,100])
xlabel('$t (ns)$','Interpreter','latex')
ylabel('Laser No.')
set(gca, 'FontSize', 22,'LineWidth',1)

figure(7);clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
plot(t_sol, cos_phi(24,:),'LineWidth',1);hold on;
ylim([-1,1])
set(gca,'fontsize',18,'FontName','times new roman')
xlabel('$t (ns)$','Interpreter','latex')
ylabel('$\cos(\Omega_24(t))$','Interpreter','latex')
xlim([98,100])

