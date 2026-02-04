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

data = load('connect_star_scaling_1.mat');
connect_val = data.connect_star_array;
M_array = data.M_array;

% coeff = connect_val .* (M_array - 1)
x = 1./(M_array-1);
y = connect_val;
p = polyfit(x, y, 1);   % p(1) = slope, p(2) = intercept
y_fit = polyval(p, x);
figure(1); clf;
set(gcf, 'Position', [100, 100, 400, 550]); 
scatter(x, y, 50, 'o', 'MarkerEdgeColor', red_base, 'LineWidth', 2); hold on;
plot(1./(M_array-1), y_fit, 'k', 'LineWidth', 1.5); hold on;
axis tight
xlabel('$1/(M-1)$','Interpreter','latex')
ylabel('$\chi^{*}$','Interpreter','latex')


% Primary axes settings
ax1 = gca;
ax1.FontSize = 20;
ax1.LineWidth = 1.5;
ax1.TickLength = [0.015, 0.015];
ax1.TickDir = 'in';
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
           'TickDir', 'in');  % <-- Ticks point outward

% Copy tick values from ax1, remove tick labels
ax2.XTick = ax1.XTick;
ax2.YTick = ax1.YTick;
ax2.XTickLabel = [];
ax2.YTickLabel = [];
ax2.XLim = ax1.XLim;
ax2.YLim = ax1.YLim;
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

