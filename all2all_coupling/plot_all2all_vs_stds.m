clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; purple;green];
% Define five transparency (alpha) values (from more transparent to fully opaque)
alphas = linspace(0.2, 1, 5);  % Adjust these values as needed

M = 24;
num_rng_w = 1;
std_w_array = [1, 2, 6, 10, 14];
d_array = [0:0.05:3, 3.2:0.2:5];

ave_S_2d_max_step = zeros(length(d_array),length(std_w_array));
for std_w_idx = 1:length(std_w_array)
    std_w = std_w_array(std_w_idx);
    load(['./data/diode_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
        '_std_w_',num2str(std_w),'.mat'])
    ave_S_2d_max_step(:,std_w_idx) = ave_S_array;
end
% ave_S_2d_max_step = zeros(length(d_array),length(w_factor_array));
% for w_factor_idx = 1:length(w_factor_array)
%     w_factor = w_factor_array(w_factor_idx);
%     load(['./data/diode_unifreq_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
%         '_w_factor_',num2str(w_factor),'.mat'])
%     ave_S_2d_max_step(:,w_factor_idx) = ave_S_array;
% end

figure;
for std_w_idx = 1:length(std_w_array)
    plot(d_array(1:50)', ave_S_2d_max_step(1:50, std_w_idx), 'color', [orange, alphas(std_w_idx)], ...
        'LineWidth', 1.5, 'DisplayName', sprintf('$\\sigma_{\\Delta} = %d $ rad/ns', int64(std_w_array(std_w_idx)))); 
    hold on;
end

% plot(d_array, ones(1,length(d_array)),'-k','LineWidth',3,'DisplayName','\omega_i = \omega_0')
legend('FontSize', 16, 'Location', 'best', 'Interpreter', 'latex');

ylim([0,1])
xlim([0,2.5])
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

