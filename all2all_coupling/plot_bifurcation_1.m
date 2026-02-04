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
alpha = 0;

data = load(['./data_bifurcation/disorder_free_all2all_dk_0.001_alpha_',num2str(alpha),'_data.mat']);
I_peak_cell = data.I_peak_cell;
d_array = data.kappa_array;%data.d_array;
cmap = lines(M);  % You can also try 'parula', 'jet', etc.
sizes = 10;
figure(1);clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
for Midx = 1:M
    for didx = 1:length(d_array)
        peaks = I_peak_cell{didx,Midx};
        scatter(d_array(didx) * ones(1, length(peaks)), peaks, sizes, ...
                'filled', 'MarkerFaceColor', cmap(Midx,:), 'MarkerEdgeColor', 'none');
        hold on;
    end
   disp(['progress: ',num2str(Midx/M)])
end
% plot([0.4,0.4],[0,6],'k--','LineWidth',1.5); hold on;
% title(['$\alpha=$ ',num2str(alpha),', $\tau$ = ', num2str(delay) ' ns'],'Interpreter','latex')
% title(['$\alpha=$',num2str(alpha),', laser for all'],'Interpreter','latex')
% title(['$\alpha=$',num2str(alpha),', laser No.',num2str(Midx)],'Interpreter','latex')
xlabel('$\kappa (ns^{-1})$','Interpreter','latex')
ylabel('${\rm LocMax}(I(t)/I_s)$','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
grid on;
xlim([0,1])
ylim([0,2.5])
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);