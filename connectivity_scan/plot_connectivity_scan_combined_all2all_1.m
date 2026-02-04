clear;clc;close all;
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
blue = [0 0.4470 0.7410];
bright_blue = [0.3010 0.7450 0.9330];
blue_bright = [0.2005, 0.5975, 0.8915];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];

dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; purple;green];

data = load('../noise_robust_scan/data_pump_Jth.mat');
perturb_array = data.perturb_array;
S_ave_array = data.S_ave_array;
S_pump_optimzied = S_ave_array(3);

M=24;
pump_factor = 2;
connectivity_array = 0:0.02:1;
ave_S_cell = cell(length(connectivity_array),1);
max_S = zeros(length(connectivity_array),1);
for cidx = 1:length(connectivity_array)
    if pump_factor == 4
    data = load(['./data/diode_data_connectivity_',num2str(connectivity_array(cidx)),...
    '_M_',num2str(M),'.mat']);
    else
    data = load(['./data/pump_',num2str(pump_factor),'_connectivity_',num2str(connectivity_array(cidx)),...
    '_M_',num2str(M),'.mat']);
    end
    ave_S_cell{cidx} = data.ave_S_array;
    max_S(cidx) = max(data.ave_S_array);
end
[val, loc] = max(max_S);
connectivity_array(loc)

figure(1);clf;
set(gcf, 'Position', [100, 100, 800, 300]); % Set the figure position and size
set(gca, 'YColor', 'k'); % Set the color of the left-hand y-axis to blue    
for connIdx = 1:length(connectivity_array)
    connectivity = connectivity_array(connIdx);
    S = ave_S_cell{connIdx};
    scatter(connectivity * ones(length(S), 1), S, 25, yellow); hold on;
    disp(['progress: ',num2str(connIdx/length(connectivity_array))])
end
scatter(0.4,S_pump_optimzied, 100, 'r', 'p', 'filled')
% xticks(connectivity_array)
% xticklabels(connectivity_array)
% xlim([0,1])
ylim([0,1])
grid on;
xlabel('$\chi$','Interpreter','latex')
ylabel('$\langle S \rangle$','Interpreter','latex')

ax1 = gca; % Get the current axes (main plot)
ax1.FontSize = 20;
ax1.LineWidth = 1.5;
% Create a second axes for the top x-axis
% Primary axes settings
ax1.TickLength = [0.015, 0.015];
ax1.TickDir = 'in';
ax1.XTickLabelRotation = 0;
grid on;
ax1.GridAlpha = 0.05;

% Add top and right ticks without labels
ax2 = axes('Position', ax1.Position, ...
           'XAxisLocation', 'top', ...
           'YAxisLocation', 'right', ...
           'Color', 'none', ...
           'XColor', ax1.XColor, ...
           'YColor', ax1.YColor,...
           'LineWidth',1.5);  % <-- Ticks point outward
% Copy tick values from ax1, remove tick labels
ax2.XTick = ax1.XTick;
ax2.YTick = ax1.YTick;
ax2.XTickLabel = [];
ax2.YTickLabel = [];
ax2.XLim = ax1.XLim;
ax2.YLim = ax1.YLim;


exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);