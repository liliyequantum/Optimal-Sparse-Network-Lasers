clear;clc;close all;

% load('birfurcation_data_method_abm4milshtein_dk_0.1.mat')
% phase_idx = 10;
dk = 0.001;
num_phases = 1;
cmap = lines(num_phases);  % You can also try 'parula', 'jet', etc.

sizes = 1;
figure(1);clf;
yyaxis left;
set(gca, 'YColor', 'k'); % Set the color of the left-hand y-axis to blue    
% set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
for phase_idx = 0:num_phases-1
    load(['./data_bifurcation/bifurcation_all2allCoupling_phase_idx_',num2str(phase_idx),'_dk_',...
    num2str(dk),'_data.mat'])
    % load(['./data_bifurcation/cosphase_bifurcation_all2allCoupling_phase_idx_',num2str(phase_idx),'_dk_',...
    % num2str(dk),'_data.mat'])
    color = cmap(phase_idx+1, :);  % Get unique color for each phaseidx
    for kIdx = 1:length(kappa_array)
        peaks = I_peak_cell{kIdx};
        % peaks = cosphase_peak_cell{kIdx};
        scatter(kappa_array(kIdx) * ones(1, length(peaks)), peaks, sizes, ...
                'filled', 'MarkerFaceColor', color, 'MarkerEdgeColor', 'none');
        hold on;
    end
   disp(['progress: ',num2str((phase_idx+1)/num_phases)])
end
xlabel('$\kappa (ns^{-1})$','Interpreter','latex')
ylabel('$I/I_s$','Interpreter','latex')
xticks(0:0.2:1)
grid on;

yyaxis right;
green = [0.4660 0.6740 0.1880];
set(gca, 'YColor', green); % Set the color of the right-hand y-axis to red
set(gca, 'XColor', green);
x = 0:0.1:1;
y=ones(length(x),1);
plot(x,y,'color',green, 'LineWidth', 2); hold on;
xlim([0,1])
ylim([0,1.1])
ylabel('$\langle S \rangle$','Interpreter','latex')

ax1 = gca; % Get the current axes (main plot)
ax1.FontSize = 20;
ax1.LineWidth=1.5;

% Set x-axis limits and label
ax2.XLim = ax1.XLim; % Ensure both x-axes match

% Ensure the new top axis does not interfere with the main axes
ax2.XTick = ax1.XTick; % Keep ticks aligned
ax2.FontSize = 20; % Match font size
ax2.LineWidth=1.5;
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);