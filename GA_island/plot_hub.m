clear;close all;
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];

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
hub_val = k_i - (mu_k + sigma_k);


figure(5); clf;
yyaxis left;
set(gcf, 'Position', [100, 100, 700, 300]); % Set figure size to 800x600 pixels
bar(1:length(k_i), hub_val,'FaceColor', blue_base); hold on;
plot([1, length(k_i)], [0, 0], 'k-.', 'LineWidth', 2);
xlabel('No. Laser');
ylabel('$\bar{k}_i - (\mu_k + \sigma_k)$', 'Interpreter', 'latex');
title('Hub Lasers','Interpreter','latex');
set(gca, 'FontSize', 16,'TickDir','out','linewidth',1.5,'YColor', blue_base);
xlim([0, length(k_i)+1]);
xticks([1, 6, 12, 18, 24]);
xticklabels({'1','6','12','18','24'});
% ylim([min(hub_val - std_k_i)-0.1, max(hub_val + std_k_i)+0.1]);
grid on;

yyaxis right;
plot(1:M, detuning_abs_mean, 'o-', 'color', red_base, 'LineWidth', 2); hold on;
errorbar(1:M, detuning_abs_mean, detuning_abs_std, 'color', red_base, 'LineWidth', 1.2);
grid on;
ylabel('$\bar{\Delta}_i$ (rad/ns)','Interpreter','latex')
set(gca, 'FontSize', 18, 'TickDir','out','linewidth',1.5,'YColor', red_base);

% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

% save('data_LK.mat','best_S','optimized_K','detuning_2d')