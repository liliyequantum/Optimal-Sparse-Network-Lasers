clear;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
color_map = [blue_base; red_base; purple];

data = load('data_pump_Jth.mat');
perturb_array = data.perturb_array;
S_ave_array = data.S_ave_array;
perturb_array(1)=1;
S_ave_array(1) = 0;
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
figure(1); clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size
plot(perturb_array, S_ave_array, '-o', 'color', green,'LineWidth', 2);hold on;
grid on;
axis tight
yticks([0,0.3,0.6,0.9,1])
ylim([0,1])
xlabel('$J/J_{\rm th}$','Interpreter','latex');
ylabel('$\langle S\rangle$','Interpreter','latex')
set(gca, 'Fontsize', 20,'linewidth',1.5);
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);