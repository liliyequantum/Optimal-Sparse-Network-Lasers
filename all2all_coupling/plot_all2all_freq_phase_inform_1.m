clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];

M= 24;
num_rng_w = 1;
std_w = 14;
% w_factor = 30;
d_array = 0:0.02:1;%0:0.1:3;%[0:0.05:3, 3.2:0.2:5];

data = load(['./data/update_R2_freq_diode_data_d_',num2str(d_array(2)-d_array(1)),'_',num2str(d_array(end)),...
    '_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),'_std_w_',num2str(std_w),'_1.mat']);
ave_S_array = data.ave_S_array;
ave_R2_array = data.ave_R2_array;
delta_mean_array = data.delta_mean_array;
delta_std_array = data.delta_std_array;
intensity_fluc_std_array = data.intensity_fluc_std_array;

figure(1);   clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
plot(d_array', ave_S_array, '-', 'Color', orange, 'MarkerSize', 4, 'LineWidth', 3,'DisplayName','$\langle S\rangle$'); hold on;
% plot(d_array', ave_R2_array, '--', 'Color', bright_blue, 'MarkerSize', 4, 'LineWidth', 3,'DisplayName','$\langle R^{2}\rangle$'); hold on;
% scatter(d_array', ave_R2_array, 30,'MarkerEdgeColor', bright_blue, ...
%     'LineWidth', 2, 'DisplayName', '$\langle R^{2}\rangle$'); hold on;
% h = plot([0.4, 0.4], [0, 1],'-.','LineWidth',1.5, 'Color', [0, 0, 0, 0.5]);hold on;
% set(h, 'HandleVisibility', 'off');
h = plot([0.39,0.39],[0,1],'k-.','LineWidth',1); hold on;
h.Annotation.LegendInformation.IconDisplayStyle = 'off';  % Exclude from legend
% legend('FontSize',16,'Location','best','Interpreter','latex') 
ylim([0,1])
% xlim([0,1])
xlabel('$\kappa (ns^{-1})$','Interpreter','latex')
ylabel('$\langle S\rangle$','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

max(abs(ave_S_array - ave_R2_array))

figure(2); clf;hold on;
set(gcf, 'Position', [100, 100, 600, 300]); 
for didx = 1:length(d_array)
    for i = 1:M
        x = d_array(didx);
        y = delta_mean_array(didx,i);
        err = delta_std_array(didx,i);

        h = errorbar(x, y, err, 'o',...
            'Color', purple,...
            'MarkerFaceColor', purple,...
            'MarkerSize', 4,...
            'CapSize', 4,...
            'LineWidth', 1);
        set(h, 'HandleVisibility', 'off');
    end
    disp(['progress: ',num2str(didx/length(d_array))])
end
plot([0.38,0.38],[-40,40],'k-.','LineWidth',1); hold on;
xticks(0:0.2:1)
xlabel('$\kappa~(ns^{-1})$','Interpreter','latex')
ylabel('$\Delta_i$(rad/ns)','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
box on
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

figure(3); clf;hold on;
set(gcf, 'Position', [100, 100, 600, 300]); 
for Midx = 1:M
    scatter(d_array,intensity_fluc_std_array(:,Midx).^2,'filled');hold on;
end
plot([0.38,0.38],[0,0.1],'k-.','LineWidth',1); hold on;
xticks(0:0.2:1)
xlabel('$\kappa~(ns^{-1})$','Interpreter','latex')
ylabel('RIN','Interpreter','latex')
set(gca, 'fontsize', 18, 'linewidth', 1.5)
box on
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

