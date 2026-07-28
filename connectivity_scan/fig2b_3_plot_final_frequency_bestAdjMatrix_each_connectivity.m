clear;clc;close all;
data = load('data_final_frequency_bestAdjMatrix_each_connect.mat');
delta_mean_array = 2*pi*data.freq_E_win_mean;
delta_std_array = 2*pi*data.freq_E_win_std;
connectivity_array = data.connectivity_array;
M = 24;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];

figure(1); clf;hold on;
set(gcf, 'Position', [100, 100, 800, 300]); 
for cidx = 1:length(connectivity_array)
    for Midx = 1:M
        x = connectivity_array(cidx);
        y = delta_mean_array(Midx, cidx);
        err = delta_std_array(Midx, cidx);

        h = errorbar(x, y, err, 'o',...
            'Color', purple,...
            'MarkerFaceColor', purple,...
            'MarkerSize', 4,...
            'CapSize', 4,...
            'LineWidth', 1);
        set(h, 'HandleVisibility', 'off');
    end
    disp(['progress: ',num2str(cidx/length(connectivity_array))])
end
% plot([0.4,0.4],[-40,40],'k-.','LineWidth',1); hold on;
xticks(0:0.2:1)
xlabel('$\chi$','Interpreter','latex')
ylabel('$\tilde{\Delta}$(rad/ns)','Interpreter','latex')
set(gca, 'FontSize', 20, 'Box', 'off', 'linewidth', 2, 'TickDir', 'out', 'TickLength', [0.01, 0.01])
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);
exportgraphics(gcf, 'final_plot.png', 'Resolution', 300);
