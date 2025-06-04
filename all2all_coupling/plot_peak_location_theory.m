clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; purple;green;bright_blue;dark_red;blue;orange;yellow];
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];

M_array = [12 18 24 30 36 42 46 50 55 60 65 70 80 90 100];%[12, 24, 50];
num_rng_w_array = 0:9;
std_w = 14;
d_array = 0:0.01:1.5;

ave_S_3d = zeros(length(d_array),length(num_rng_w_array),length(M_array));
for Midx = 1:length(M_array)
    M = M_array(Midx);
    for widx = 1:length(num_rng_w_array)
        num_rng_w = num_rng_w_array(widx);
        data = load(['./data_peak_theory/diode_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
                        '_std_w_',num2str(std_w),'.mat']);  
        ave_S_3d(:, widx , Midx) = data.ave_S_array;
    end
end

mean_S = reshape(mean(ave_S_3d,2), [length(d_array),length(M_array)]);
% Assume your matrix is called A (71x3)
[~, max_indices] = max(mean_S(1:100,:), [], 1);
max_peak_d = d_array(max_indices);

coeff = max_peak_d.*(M_array-1)
figure(1); clf;
scatter(1./(M_array-1), max_peak_d, 50, 'o', 'MarkerEdgeColor', red_base, 'LineWidth', 2); hold on;
plot(1./(M_array-1), mean(coeff)./(M_array-1), 'k', 'LineWidth', 1.5); hold on;

axis tight
xlabel('$1/(M-1)$','Interpreter','latex')
ylabel('$\kappa^{*} (ns^{-1})$','Interpreter','latex')

% Primary axes settings
ax1 = gca;
ax1.FontSize = 20;
ax1.LineWidth = 1.5;
ax1.TickLength = [0.015, 0.015];
ax1.TickDir = 'out';
ax1.XTickLabelRotation = 0;
grid on;
ax1.GridAlpha = 0.05;
% ax1.XScale = 'log';

% Add top and right ticks without labels
ax2 = axes('Position', ax1.Position, ...
           'XAxisLocation', 'top', ...
           'YAxisLocation', 'right', ...
           'Color', 'none', ...
           'XColor', ax1.XColor, ...
           'YColor', ax1.YColor, ...
           'TickLength', ax1.TickLength, ...
           'LineWidth', ax1.LineWidth, ...
           'FontSize', ax1.FontSize, ...
           'TickDir', 'out');  % <-- Ticks point outward

% Copy tick values from ax1, remove tick labels
ax2.XTick = ax1.XTick;
ax2.YTick = ax1.YTick;
ax2.XTickLabel = [];
ax2.YTickLabel = [];
ax2.XLim = ax1.XLim;
ax2.YLim = ax1.YLim;

% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);


