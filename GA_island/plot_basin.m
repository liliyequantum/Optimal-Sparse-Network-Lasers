clear;close all;

red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];

rng_ga_1 = 2;
rng_ga_2 = 4;

% Load data
data = load(['./data_basin/ave_S_rng_',num2str(rng_ga_1),'_',num2str(rng_ga_2),'.mat']);
ave_S_2d = data.ave_S_2d;   % 11x100
s_array = data.s_array;     % 11x1

% Compute mean and std over realizations (along columns)
mean_S = mean(ave_S_2d, 2);     % 11x1
std_S = std(ave_S_2d, 0, 2);    % 11x1

% Plot mean line with error bars
figure;
plot(s_array, mean_S, 'o-', 'color', blue_base, 'LineWidth', 2); hold on;
errorbar(s_array, mean_S, std_S, 'color', blue_base, 'LineWidth', 1.2);
title(sprintf('$K^{\\mathrm{GA}}_{%d}$ to $K^{\\mathrm{GA}}_{%d}$', rng_ga_1, rng_ga_2), 'Interpreter', 'latex');
xlabel('$\xi$','Interpreter','latex');
ylabel('$\langle S\rangle$','Interpreter','latex');
grid on;
set(gca, 'FontSize', 18, 'TickDir','out','linewidth',1.5);
ylim([0.85,1])
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);
