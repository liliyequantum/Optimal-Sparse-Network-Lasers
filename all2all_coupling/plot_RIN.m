clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; green];

M = 24;
alpha = 5;

data = load(['./data_bifurcation/disorder_free_all2all_dk_0.001_alpha_',num2str(alpha),'_data.mat']);
RIN = data.RIN_2d;
d_array = data.kappa_array;

cmap = lines(M);  % You can also try 'parula', 'jet', etc.

sizes = 10;
figure(1);clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
for Midx = 1:2%M
    for didx = 1:length(d_array) 
        scatter(d_array(didx), RIN(didx,Midx), sizes, ...
                'filled', 'MarkerFaceColor', cmap(Midx,:), 'MarkerEdgeColor', 'none');
        hold on;
    end
   disp(['progress: ',num2str(Midx/M)])
end
% plot([0.4,0.4],[-0.03,0.6],'k--','LineWidth',1.5)
% title(['$\alpha=$ ',num2str(alpha)],'Interpreter','latex')
% title(['$\alpha=$',num2str(alpha),', laser No.',num2str(Midx)],'Interpreter','latex')
xlabel('$\kappa (ns^{-1})$','Interpreter','latex')
ylabel('RIN','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
grid on;
xlim([0,1])
% ylim([-0.03,0.2])
ylim([-0.03,0.2])
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);