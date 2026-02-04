clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; green];

M_array = [24, 50, 100, 200];
num_rng_w = 1;
std_w = 14;
num_d = 21;
num_d_1 = 51;
ave_S_cell = cell(length(M_array),1);
d_array_cell = cell(length(M_array),1);

for Midx = 1:length(M_array)
    M = M_array(Midx);
    
    
    if ismember(M, [24, 50])
        data = load(['./data/diode_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
        '_std_w_',num2str(std_w),'.mat']);
        ave_S_cell{Midx} = data.ave_S_array(1:num_d);
        d_array_cell{Midx} = data.d_array(1:num_d);
    else
        data = load(['./data_homo/diode_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
        '_std_w_',num2str(std_w),'.mat']);
        ave_S_cell{Midx} = data.ave_S_array(1:num_d_1);
        d_array_cell{Midx} = data.d_array(1:num_d_1);
    end
end
size_array = [5, 5, 4,3];
figure(1);
for Midx=1:length(M_array)
       plot(d_array_cell{Midx}, ave_S_cell{Midx}, '-o', ...
        'Color', color_map(Midx,:), ...
        'MarkerSize', size_array(Midx), ...
        'LineWidth', 1.5, ...
        'DisplayName', ['M = ', num2str(M_array(Midx))]); 
        hold on;
end
% plot(d_array, ones(1,length(d_array)),'-k','LineWidth',3,'DisplayName','\omega_i = \omega_0')
legend('FontSize',18,'Location','best') 
ylim([0,1])
% xlim([0,5])
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
