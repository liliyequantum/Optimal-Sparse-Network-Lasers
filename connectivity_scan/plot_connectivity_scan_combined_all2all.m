clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; purple;green];

M = 24;
num_rng_w = 9;
std_w = 14;
num_repeat = 1000;
connectivity_array = 0.05:0.05:0.95;

data = load(['../all2all_coupling/data/diode_data_M_',...
    num2str(M),'_num_rng_w_',num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']);
% load(['../all2all_coupling/data/diode_unifreq_data_M_',...
%     num2str(M),'_num_rng_w_',num2str(num_rng_w),'_w_factor_',num2str(w_factor),'.mat'])
d_all2all = data.d_array';
ave_S_all2all = data.ave_S_array;
max_all2all = max(ave_S_all2all);

ave_S = zeros(num_repeat, length(connectivity_array));
mean_S = zeros(1,length(connectivity_array));
for conn_idx = 1:length(connectivity_array)
    coupling_connectivity = connectivity_array(conn_idx);
    if num_rng_w == 1
    data = load(['./data/diode_data_connectivity_',num2str(coupling_connectivity),'.mat']);
    else
    data = load(['./data/diode_data_connectivity_',num2str(coupling_connectivity),...
        '_num_rng_w_',num2str(num_rng_w),'.mat']);
    end
    ave_S(:, conn_idx) = data.ave_S_array;
    mean_S(conn_idx) = mean(data.ave_S_array);
end

data = load(['./data/diode_data_connectivity_0_num_rng_w_',num2str(num_rng_w),'.mat']);
ave_S_conn_0 = data.ave_S_array;
data = load(['./data/diode_data_connectivity_1_num_rng_w_',num2str(num_rng_w),'.mat']);
ave_S_conn_1 = data.ave_S_array;


figure(1);clf;
% set(gcf, 'Position', [100, 100, 800, 600]); % Set the figure position and size
yyaxis left;
set(gca, 'YColor', 'k'); % Set the color of the left-hand y-axis to blue    
for connIdx = 1:length(connectivity_array)
    connectivity = connectivity_array(connIdx);
    scatter(connectivity * ones(num_repeat, 1), ave_S(:, connIdx), 25, yellow); hold on;
    disp(['progress: ',num2str(connIdx/length(connectivity_array))])
end
% plot([0,1], ave_S_conn_1*ones(1,2),'Color','b ', 'LineStyle', '--','LineWidth',2); hold on;
% plot([0,1],max_all2all*ones(1,2),'Color','r', 'LineStyle', '--','LineWidth',2); hold on;
plot([0, connectivity_array, 1], [ave_S_conn_0, mean_S, ave_S_conn_1], ...
    '-o','MarkerSize',4,'LineWidth', 2,'Color',yellow); hold on;
xlim([0,1])
ylim([0,1])
grid on;
xlabel('Connectivity','Interpreter','latex')
ylabel('$\langle S \rangle$','Interpreter','latex')

yyaxis right;
set(gca, 'YColor', green); % Set the color of the right-hand y-axis to red
plot(d_all2all,ave_S_all2all,'-o','color',green,...
    'MarkerSize', 4, 'LineWidth', 2); hold on;
xlim([0,1])
ylim([0,1])
% xlabel('$d (ns^{-1})$','Interpreter','latex')
ylabel('$\langle S \rangle$','Interpreter','latex')
% xticks(d_array)

ax1 = gca; % Get the current axes (main plot)
ax1.FontSize = 20;
ax1.LineWidth = 1.5;
% Create a second axes for the top x-axis
ax2 = axes('Position', ax1.Position, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
           'Color', 'none', 'XColor', green, 'YColor', 'none');

% Set x-axis limits and label
ax2.XLim = ax1.XLim; % Ensure both x-axes match
xlabel(ax2, '$\kappa (ns^{-1})$', 'Interpreter', 'latex', 'Color', green);

% Ensure the new top axis does not interfere with the main axes
ax2.XTick = ax1.XTick; % Keep ticks aligned
ax2.FontSize = 18; % Match font size
ax2.LineWidth= 1.5;
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);