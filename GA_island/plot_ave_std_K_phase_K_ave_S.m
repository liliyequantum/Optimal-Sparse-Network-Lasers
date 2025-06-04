clear;close all;
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];


addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq
data = load('GA_optimized_LK_data.mat');
optimized_K = data.optimized_K;
mean_optimized_K = mean(optimized_K,[3]);
std_optimized_K = std(optimized_K, [], 3);
best_S = data.best_S;
mean_best_S = mean(best_S);


data = load('phase_ij_data.mat');
varphijtaui_3d = data.varphijtaui_3d;
mean_varphijtaui = mean(abs(varphijtaui_3d),[3]);
std_varphijtaui = std(abs(varphijtaui_3d), [], 3);


% Plot mean(K_ij)
figure(1); clf;
imagesc(mean_optimized_K);
title('mean($K_{ij}$)', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'LineWidth', 1.2, ...
         'TickDir', 'out', 'Box', 'off');  % <- Ticks outside
xlabel('No. Laser');
ylabel('No. Laser');
tick_positions = [1, 12, 24];
xticks(tick_positions);
yticks(tick_positions);
xticklabels({'1', '12', '24'});
yticklabels({'1', '12', '24'});
xlim([1, 24]);
ylim([1, 24]);
colorbar;
axis equal;
axis tight;
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

% Plot std(K_ij)
figure(2); clf;
imagesc(std_optimized_K);
title('std($K_{ij}$)', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'LineWidth', 1.2, ...
         'TickDir', 'out', 'Box', 'off');  % <- Ticks outside
xlabel('No. Laser');
ylabel('No. Laser');
xticks(tick_positions);
yticks(tick_positions);
xticklabels({'1', '12', '24'});
yticklabels({'1', '12', '24'});
xlim([1, 24]);
ylim([1, 24]);
colorbar;
axis equal;
axis tight;
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

figure(3); clf;
imagesc(mean_varphijtaui);
title('mean($|\bar{\varphi}^{\tau}_{j}-\bar{\varphi}_{i}|$)', 'Interpreter', 'latex')
set(gca, 'FontSize', 18, 'LineWidth', 1.2, ...
         'TickDir', 'out', 'Box', 'off');
xlabel('No. Laser');
ylabel('No. Laser');
tick_positions = [1, 12, 24];
xticks(tick_positions);
yticks(tick_positions);
xticklabels({'1', '12', '24'});
yticklabels({'1', '12', '24'});
xlim([1, 24]);
ylim([1, 24]);
axis equal;
axis tight;
caxis([0, 0.2*pi]);  % or use [min_value, max_value] based on your data
% Set colorbar with custom tick labels
cb = colorbar;
cb.Ticks = [0, 0.1*pi, 0.2*pi];  % Replace with actual values in your data range
cb.TickLabels = {'$0$', '$0.1\pi$', '$0.2\pi$'};
cb.TickLabelInterpreter = 'latex';
cb.FontSize = 16;
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

figure(4); clf;
imagesc(std_varphijtaui);
title('std($|\bar{\varphi}^{\tau}_{j}-\bar{\varphi}_{i}|$)', 'Interpreter', 'latex')
set(gca, 'FontSize', 18, 'LineWidth', 1.2, ...
         'TickDir', 'out', 'Box', 'off');  % <- Ticks outside
xlabel('No. Laser');
ylabel('No. Laser');
xticks(tick_positions);
yticks(tick_positions);
xticklabels({'1', '12', '24'});
yticklabels({'1', '12', '24'});
xlim([1, 24]);
ylim([1, 24]);
colorbar;
axis equal;
axis tight;
caxis([0, max(max(std_varphijtaui))]);  % or use [min_value, max_value] based on your data
% Set colorbar with custom tick labels
cb = colorbar;
cb.Ticks = [0, 0.01*pi, 0.02*pi, 0.03*pi];  % Replace with actual values in your data range
cb.TickLabels = {'$0$', '$0.01\pi$', '$0.02\pi$', '$0.03\pi$'};
cb.TickLabelInterpreter = 'latex';
cb.FontSize = 16;
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);


figure(6); clf;
set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
scatter(1:100, best_S, ...
        60, ...                          % Marker size
        'o', ...                         % Marker shape
        'filled', ...                    % Fill marker
        'MarkerEdgeColor', 'none', ...  % No edge
        'MarkerFaceColor', red_base, ...% Fill color
        'LineWidth', 1.2);hold on;
plot([1, 100], [mean_best_S, mean_best_S], 'k-', 'LineWidth', 3);
title('mean $\langle S\rangle = 0.97$','interpreter','latex')
xlim([0 100]);
ylim([0.94 1]);
xticks(0:20:100);  % Clean X ticks
yticks(0.94:0.02:1);  % Clean Y ticks
grid on;
set(gca,'FontSize',22,'FontName','Times New Roman');
xlabel('No. rng')
ylabel('$\langle S\rangle$','Interpreter','latex')
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);


