clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];

M= 24;
gamma_n = 0.5;

data = load(['./data_homo/gamman_',num2str(gamma_n),'_diode_data_M_',num2str(M),'_num_rng_w_1_std_w_14.mat']);
ave_S_array = data.ave_S_array;
d_array = data.d_array;

figure(1);   clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
plot(d_array', ave_S_array, '-o', 'Color', orange, 'MarkerSize', 1, 'LineWidth', 3); hold on;
% plot([0.4,0.4],[0,1],'k--','LineWidth',1.5); hold on;
ylim([0,1.1])
% xlim([0,1])
title(['$\gamma_n$ = ' num2str(gamma_n)], 'Interpreter', 'latex')
xlabel('$\kappa (ns^{-1})$','Interpreter','latex')
ylabel('$\langle S\rangle$','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);
