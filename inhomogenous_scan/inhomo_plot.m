clear;close all;

% blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
% red = [1 0 0];
red = [0.85, 0.1, 0.1];
blue = [0.1, 0.45, 0.85];
bright_red = [1, 0.3, 0.3];

var_array = [0.05 0.1:0.1:1];
kappa_array = 0:0.05:1;

% % Linearly interpolate between the colors
% colormap_matrix = zeros(length(var_array), 3);
% for i = 1:3  % For R, G, B channels
%     colormap_matrix(:, i) = linspace(blue(i), bright_blue(i), length(var_array));
% end

S_ave_cell = cell(length(var_array),length(kappa_array));
S_std_cell = cell(length(var_array),length(kappa_array));
S_ave_max = zeros(length(var_array),length(kappa_array));
S_std_max = zeros(length(var_array),length(kappa_array));
for varidx = 1:length(var_array)
    for kidx = 1:length(kappa_array)
        data = load(['./data/var_',num2str(var_array(varidx)),'_kappa_',num2str(kappa_array(kidx)),'_num_sample_1000.mat']);
        S_ave_cell{varidx,kidx} = data.ave_S_sample;
        S_std_cell{varidx,kidx} = data.std_S_sample;
        S_ave_max(varidx,kidx) = max(data.ave_S_sample);
        S_std_max(varidx,kidx) = max(data.std_S_sample);
    end
end
[num_sample, ~] = size(S_ave_cell{1,1});

[value,loc] = max(S_ave_max,[], 2);
data = load('../all2all_coupling/data/diode_data_M_24_num_rng_w_1_std_w_14.mat');
S_ave_all2all = data.ave_S_array(1:length(kappa_array));
[value_all2all, loc_all2all] = max(S_ave_all2all);
S_peak = [value_all2all;value];
S_peak_loc = kappa_array([loc_all2all;loc]);

x_start = 0;
x_end = 1;

figure(1);clf;
% set(gcf, 'Position', [100, 100, 800, 600]); % Set the figure position and size
yyaxis right;
set(gca, 'YColor', purple); % Set the color of the right-hand y-axis to red
plot([0, var_array],S_peak','-<','color',purple,...
    'MarkerSize', 8, 'LineWidth', 2); hold on;
xlim([x_start,x_end])
xticks([0, 0.2, 0.4, 0.6, 0.8, 1.0]);
ylabel('$\langle S \rangle_{\kappa^{*}}$','Interpreter','latex')

yyaxis left;
set(gca, 'YColor', red); % Set the color of the left-hand y-axis to blue    
plot([0, var_array],S_peak_loc,'-o','color',red,...
    'MarkerSize', 8, 'LineWidth', 2); hold on;
xlim([x_start,x_end])
xticks([0, 0.2, 0.4, 0.6, 0.8, 1.0]);
xlabel('$\sigma_{\kappa}~(\textnormal{ns}^{-1})$','Interpreter','latex')
% ylabel('Peak loc ($\kappa$)','Interpreter','latex')
set(gca, 'FontName', 'Helvetica')
ylabel('$\kappa^{*} (ns^{-1})$', 'Interpreter', 'latex')

% legend({'Peak Location', 'Peak Value'}, 'Location', 'best', 'FontSize', 14,'FontName', 'Helvetica')
ax1 = gca; % Get the current axes (main plot)
ax1.FontSize = 20;
ax1.LineWidth = 1.5;
ax1.TickLength = [0.015, 0.015]; % shorter ticks
ax1.TickDir = 'out'; % ticks pointing outwards
ax1.XTickLabelRotation = 0; % if you prefer horizontal
grid on;
ax1.GridAlpha = 0.05; % light, unobtrusive grid


ax2.XTick = ax1.XTick; % Keep ticks aligned
ax2.FontSize = 20; % Match font size
ax2.LineWidth= 1.5;
ax2.TickLength = [0.015, 0.015]; % shorter ticks
ax2.TickDir = 'out'; % ticks pointing outwards
ax2.XTickLabelRotation = 0; % if you prefer horizontal
grid on;
ax2.GridAlpha = 0.05; % light, unobtrusive grid

% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

x_start = 0;
x_end = 1;
y_start = 0;
y_end = 1;
% var_array([2 4 6])
for varidx = [6]%[2 4 6]
figure(varidx);clf;
% set(gcf, 'Position', [100, 100, 800, 600]); % Set the figure position and size
yyaxis right;
set(gca, 'YColor', blue); % Set the color of the right-hand y-axis to red
plot(kappa_array,S_ave_all2all,'-x','color',blue,...
    'MarkerSize', 8, 'LineWidth', 2); hold on;
xlim([x_start,x_end])
ylim([y_start,y_end])
ylabel('$\langle S \rangle$','Interpreter','latex')
grid on;
xticks([0, 0.2, 0.4, 0.6, 0.8, 1.0]);

yyaxis left;
set(gca, 'YColor', red); % Set the color of the left-hand y-axis to blue    
    for kidx = 1:length(kappa_array)
        kappa = kappa_array(kidx);
        scatter(kappa * ones(num_sample, 1), S_ave_cell{varidx, kidx}, 25, bright_red); hold on;
    end
    disp(['progress: ',num2str(varidx/length(var_array))])
xlim([x_start,x_end])
ylim([y_start,y_end])
xlabel('$\kappa (ns^{-1})$','Interpreter','latex')
ylabel('$\langle S \rangle$','Interpreter','latex')
grid on;
xticks([0, 0.2, 0.4, 0.6, 0.8, 1.0]);

ax1 = gca; % Get the current axes (main plot)
ax1.FontSize = 20;
ax1.LineWidth = 1.5;
ax1.TickLength = [0.015, 0.015]; % shorter ticks
ax1.TickDir = 'out'; % ticks pointing outwards
ax1.XTickLabelRotation = 0; % if you prefer horizontal
grid on;
ax1.GridAlpha = 0.05; % light, unobtrusive grid

ax2.XTick = ax1.XTick; % Keep ticks aligned
ax2.FontSize = 20; % Match font size
ax2.LineWidth= 1.5;
ax2.TickLength = [0.015, 0.015]; % shorter ticks
ax2.TickDir = 'out'; % ticks pointing outwards
ax2.XTickLabelRotation = 0; % if you prefer horizontal
grid on;
ax2.GridAlpha = 0.05; % light, unobtrusive grid
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

end

