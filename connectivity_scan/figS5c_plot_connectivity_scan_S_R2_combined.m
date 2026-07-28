clear; clc; close all;

%% Color Definitions
yellow = [0.9290 0.6940 0.1250];
blue_dark = [0, 0.2, 0.6];

%% Data Loading
M = 24;
num_rng_w = 1; 
std_w = 14;  

% Connectivity configuration
connectivity_array = 0:0.02:1;
nC = length(connectivity_array);

mean_S  = zeros(nC,1);
mean_R2 = zeros(nC,1);
pump_factor = 4;

for cidx = 1:nC
    % ----- S data (same files as plot_connectivity_scan.m) -----
    if pump_factor == 4
        data_file_S = ['./data/diode_data_connectivity_', ...
            num2str(connectivity_array(cidx)),'_M_',num2str(M),'.mat'];
    else
        data_file_S = ['./data/pump_',num2str(pump_factor), ...
            '_connectivity_',num2str(connectivity_array(cidx)), ...
            '_M_',num2str(M),'.mat'];
    end
    temp_S = load(data_file_S);
    mean_S(cidx) = mean(temp_S.ave_S_array);

    % ----- R^2 data (same files as plot_connectivity_scan_parameter_r2.m) -----
    data_file_R2 = ['./data/diode_data_connectivity_', ...
        num2str(connectivity_array(cidx)),'_M_',num2str(M),'parameter_r2.mat'];
    temp_R2 = load(data_file_R2);
    mean_R2(cidx) = mean(temp_R2.ave_r2_array);
end

% Quantify the difference between the two ensemble-average curves.
% Quote this number in the SI caption / referee response.
diff_curve = mean_S - mean_R2;
fprintf('max |<S> - <R^2>|  = %.4g\n', max(abs(diff_curve)));
fprintf('mean |<S> - <R^2>| = %.4g\n', mean(abs(diff_curve)));

%% Figure Initialization
figure(1); clf;
set(gcf, 'Position', [100, 100, 900, 300], 'Color', 'w');
axPos = [0.15, 0.15, 0.75, 0.75];
ax1 = axes('Position', axPos);
hold(ax1, 'on');

%% Plotting Data
% Plot <S> first (solid), then <R^2> on top (dashed) so the dashed
% curve remains visible where the two nearly coincide.
hS  = plot(ax1, connectivity_array, mean_S,  '-',  ...
    'Color', yellow,    'LineWidth', 3);
hR2 = plot(ax1, connectivity_array, mean_R2, '--', ...
    'Color', blue_dark, 'LineWidth', 2);

% Optimal connectivity marker (same as main-text Fig. 2)
chi_star = 0.4;
xline(ax1, chi_star, 'k--', 'LineWidth', 1, 'Alpha', 0.5);
text(ax1, chi_star + 0.02, 0.25, '$\chi^{*}$', ...
    'Interpreter', 'latex', 'FontSize', 22);

%% Formatting Axes
ax1.XLim = [0, 1];
ax1.YLim = [0, 1];
ax1.FontSize = 22;
ax1.LineWidth = 2;
ax1.TickDir = 'out';
ax1.TickLength = [0.015, 0.015];

% Labels (Uncomment if you want them rendered in the script)
% xlabel(ax1, 'Connectivity $\chi$', 'Interpreter', 'latex', 'FontSize', 24);
% ylabel(ax1, 'Sync. measures', 'Interpreter', 'latex', 'FontSize', 24);

grid(ax1, 'off');

%% Legend
legend([hS, hR2], {'$\langle S \rangle_e$', '$\langle R^{2} \rangle_e$'}, ...
    'Interpreter', 'latex', 'Location', 'northwest', ...
    'FontSize', 20, 'EdgeColor', 'none', 'Color', 'none');

%% Inset: magnified difference <S> - <R^2>
% Shows the referee explicitly that the gap is tiny everywhere.
% Comment this block out if you prefer to quote the max difference
% in the caption instead.
axInset = axes('Position', [0.62, 0.25, 0.26, 0.25]);
hold(axInset, 'on');
plot(axInset, connectivity_array, diff_curve, '-', ...
    'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
yline(axInset, 0, 'k:', 'LineWidth', 0.5);
axInset.XLim = [0, 1];
axInset.FontSize = 12;
axInset.LineWidth = 1;
axInset.TickDir = 'out';
title(axInset, '$\langle S \rangle_e - \langle R^{2} \rangle_e$', ...
    'Interpreter', 'latex', 'FontSize', 14);

%% Export
exportgraphics(gcf, 'sparse_sync_S_R2_combined.pdf', 'ContentType', 'vector');
% For the LaTeX SI, a PDF export is usually cleaner:
% exportgraphics(gcf, 'sparse_sync_S_R2_combined.pdf', 'ContentType', 'vector');
