clear;close all;
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

data = load('GA_optimized_LK_data.mat');
optimized_K = data.optimized_K;
mean_optimized_K = mean(optimized_K,[3]);
std_optimized_K = std(optimized_K, [], 3);
detuning_2d = data.detuning_2d;
[M, ~] = size(detuning_2d);

detu_abs = detuning_2d;
detuning_abs_mean = mean(detu_abs,2);
detuning_abs_std = std(detu_abs,[],2);

%% Hub criteria
k_i = sum(mean_optimized_K, 2);        % Mean degree of each node
k_i = k_i(:);

% Compute hub deviation from threshold
mu_k = mean(k_i);
sigma_k = std(k_i);
hub_val = k_i;% - (mu_k + sigma_k);


figure(5); clf;
yyaxis left;
set(gcf, 'Position', [100, 100, 500, 400]); % Set figure size to 800x600 pixels
h = bar(1:length(k_i), hub_val, 'FaceColor', purple); hold on;
h.FaceAlpha = 0.3;   % adjust between 0 (fully transparent) and 1 (fully opaque)
plot([0, M+1], [mu_k + sigma_k, mu_k + sigma_k], 'k--', 'LineWidth', 2);
xlabel('Laser No.');
ylabel('$\langle\xi_i\rangle$', 'Interpreter', 'latex');
title('Hub Lasers','Interpreter','latex');
set(gca, 'FontSize', 20,'TickDir','out','linewidth',2,'YColor', purple,'Box','off');
xlim([0, length(k_i)+1]);
xticks([1, 6, 12, 18, 24]);
xticklabels({'1','6','12','18','24'});
% ylim([min(hub_val - std_k_i)-0.1, max(hub_val + std_k_i)+0.1]);
% grid on;

yyaxis right;
plot(1:M, abs(detuning_abs_mean), 'o-', 'color', [red_base 0.5], 'LineWidth', 2); hold on;
errorbar(1:M, abs(detuning_abs_mean), detuning_abs_std, 'color', [red_base 0.5], 'LineWidth', 2);
% grid on;
ylabel('$|\langle\tilde{\Delta}_i\rangle|$ (rad/ns)','Interpreter','latex')
set(gca, 'FontSize', 20, 'TickDir','out','linewidth',2,'YColor', red_base,'Box','off');

% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);
exportgraphics(gcf, 'final_plot.emf');
% save('data_LK.mat','best_S','optimized_K','detuning_2d')