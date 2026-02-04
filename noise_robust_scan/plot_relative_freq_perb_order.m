clear; close all;

% Color definitions
blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
color_map = [blue_base; red_base; purple];

% Load data
load('data_perb_w.mat')

% Compute statistics
freq_perb = W + f_perb;
freq_perb_std = reshape(std(freq_perb, 0, 2), M, num_sigma);
freq_perb_mean = reshape(mean(freq_perb, 2), M, num_sigma);

% Create main plot
figure; hold on;
for sidx = [4 5 6]
    if sidx == 4
         errorbar(1:M, freq_perb_mean(:,sidx) + 40*(sidx-4), freq_perb_std(:,sidx), 'o-', ...
        'Color', color_map(sidx-3,:), ...
        'LineWidth', 2, 'MarkerSize', 5, 'CapSize', 8);
    else
    errorbar(1:M, freq_perb_mean(:,sidx) + 40*(sidx-4), freq_perb_std(:,sidx), 'o-', ...
        'Color', color_map(sidx-3,:), ...
        'LineWidth', 2, 'MarkerSize', 6, 'CapSize', 8);
    end
end

xlabel('Laser No.','Interpreter','latex');
ylabel('Relative $\Delta_i$ rad/ns', 'Interpreter', 'latex');
grid on;
set(gca, 'FontSize', 20);
axis tight;
xticks([1, 6, 12, 18, 24]);

% Get handle to main axes
ax1 = gca;
ax1.TickDir = 'in';
ax1.LineWidth = 1.5;

% Create duplicate top-right axes without labels
ax2 = axes('Position', ax1.Position, ...
           'XAxisLocation', 'top', ...
           'YAxisLocation', 'right', ...
           'Color', 'none', ...
           'XColor', ax1.XColor, ...
           'YColor', ax1.YColor, ...
           'TickLength', ax1.TickLength, ...
           'LineWidth', ax1.LineWidth, ...
           'FontSize', ax1.FontSize, ...
           'TickDir', 'in');

% Match limits and ticks, but remove labels
ax2.XLim = ax1.XLim;
ax2.YLim = ax1.YLim;
ax2.XTick = ax1.XTick;
ax2.YTick = ax1.YTick;
ax2.XTickLabel = [];
ax2.YTickLabel = [];

% Export
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);
