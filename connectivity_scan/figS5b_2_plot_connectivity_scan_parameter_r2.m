clear; clc; close all;

%% Color Definitions
yellow = [0.9290 0.6940 0.1250];
blue_bright = [0.2005, 0.5975, 0.8915]; % Kept for reference if needed

%% Data Loading

M = 24;
num_rng_w = 1;
std_w = 14;

% Connectivity configuration
connectivity_array = 0:0.02:1;
ave_S_cell = cell(length(connectivity_array),1);
max_S = zeros(length(connectivity_array),1);
mean_S = zeros(length(connectivity_array),1);
pump_factor = 4;

for cidx = 1:length(connectivity_array)
    if pump_factor == 4
        data_file = ['./data/diode_data_connectivity_',num2str(connectivity_array(cidx)),'_M_',num2str(M),'parameter_r2.mat'];
    else
        data_file = ['./data/pump_',num2str(pump_factor),'_connectivity_',num2str(connectivity_array(cidx)),'_M_',num2str(M),'.mat'];
    end
    
    temp_data = load(data_file);
    ave_S_cell{cidx} = temp_data.ave_r2_array;
    max_S(cidx) = max(temp_data.ave_r2_array);
    mean_S(cidx) = mean(temp_data.ave_r2_array);
end

%% Figure Initialization
figure(1); clf;
set(gcf, 'Position', [100, 100, 900, 300], 'Color', 'w'); 
% Adjusted axis position to center the plot better now that the top axis is gone
% [left, bottom, width, height]
axPos = [0.15, 0.15, 0.75, 0.75]; 
ax1 = axes('Position', axPos);
hold(ax1, 'on');

%% Plotting Data
% Connectivity Scatter (Yellow)
for connIdx = 1:length(connectivity_array)
    S = ave_S_cell{connIdx};
    scatter(ax1, connectivity_array(connIdx) * ones(length(S), 1), S, 25, ...
            'MarkerEdgeColor', yellow, 'LineWidth', 0.5);
end
plot(ax1, connectivity_array, mean_S, 'Color', yellow, 'LineWidth',3);

%% Formatting Axes
ax1.XLim = [0, 1];
ax1.YLim = [0, 1];
ax1.FontSize = 22;
ax1.LineWidth = 2;
ax1.TickDir = 'out';
ax1.TickLength = [0.015, 0.015];

% Labels (Uncomment if you want them rendered in the script)
% xlabel(ax1, 'Connectivity $\chi$', 'Interpreter', 'latex', 'FontSize', 24);
% ylabel(ax1, '$\langle S \rangle$', 'Interpreter', 'latex', 'FontSize', 24);

grid(ax1, 'off');

%% Legend
% % Create a dummy handle for the legend to show a filled circle
% hLegendYellow = scatter(ax1, nan, nan, 40, yellow, 'filled');
% legend(hLegendYellow, {'Sparse Networks'}, ...
%     'Location', 'southeast', 'FontSize', 18, 'EdgeColor', 'none');

%% Export
% Exporting as EMF for high-quality vector graphics in Word/PowerPoint
exportgraphics(gcf, 'sparse_sync_plot.pdf', 'ContentType', 'vector');