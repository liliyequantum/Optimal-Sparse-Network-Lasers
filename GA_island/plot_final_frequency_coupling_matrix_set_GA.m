clear;clc;close all;
num_rng_GA = 0;
numGen = 30;
data = load(['data_final_frequency_worst_coupling_matrix_set_GA_',num2str(num_rng_GA),'.mat']);
delta_mean_array = 2*pi*data.freq_E_win_mean;
delta_std_array = 2*pi*data.freq_E_win_std;
gen_array = 1:1:numGen;
M = 24;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];

figure(1); hold on;
set(gcf, 'Position', [100, 100, 600, 300]); 
for gidx = 1:length(gen_array)
    for Midx = 1:M
        x = gen_array(gidx);
        y = delta_mean_array(Midx, gidx);
        err = delta_std_array(Midx, gidx);

        h = errorbar(x, y, err, 'o',...
            'Color', orange,...
            'MarkerFaceColor', orange,...
            'MarkerSize', 4,...
            'CapSize', 4,...
            'LineWidth', 1);
        set(h, 'HandleVisibility', 'off');
    end
    disp(['progress: ',num2str(gidx/length(gen_array))])
end
% plot([0.4,0.4],[-40,40],'k-.','LineWidth',1); hold on;
% xticks(0:0.2:1)
xlabel('Generation No.','Interpreter','latex')
ylabel('$\Delta^{\textnormal{fit}}_{\textnormal{win}}$(rad/ns)','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
box on
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);