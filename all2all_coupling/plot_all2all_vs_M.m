clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; purple;green];
% color_map = [green];

M_array = [12 24 50];
num_rng_w = 1;
std_w = 14;
% w_factor = 30;
d_array = [0:0.05:3, 3.2:0.2:5];

ave_S_2d_max_step = zeros(length(d_array),length(M_array));
for Midx = 1:length(M_array)
    M = M_array(Midx);
    load(['./data/diode_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
        '_std_w_',num2str(std_w),'.mat'])
    ave_S_2d_max_step(:,Midx) = ave_S_array;
end

figure(1);
for Midx=1:length(M_array)
   plot(d_array', ave_S_2d_max_step(:,Midx), '-o', ...
    'Color', color_map(Midx,:), ...
    'MarkerSize', 4, ...
    'LineWidth', 1.5, ...
    'DisplayName', ['M = ', num2str(M_array(Midx))]); 
hold on;

end
% plot(d_array, ones(1,length(d_array)),'-k','LineWidth',3,'DisplayName','\omega_i = \omega_0')
legend('FontSize',16,'Location','best') 
ylim([0,1])
xlim([0,5])
xlabel('$\kappa (ns^{-1})$','Interpreter','latex')
ylabel('$\langle S \rangle$','Interpreter','latex')
ax1 = gca; % Get the current axes (main plot)
ax1.FontSize = 20;
ax1.LineWidth = 1.5;
ax1.TickLength = [0.015, 0.015]; % shorter ticks
ax1.TickDir = 'out'; % ticks pointing outwards
ax1.XTickLabelRotation = 0; % if you prefer horizontal
grid on;
ax1.GridAlpha = 0.05; % light, unobtrusive grid
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);
