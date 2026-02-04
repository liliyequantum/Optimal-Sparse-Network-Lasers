clear;close all;

data = load('data_perb_pump.mat');
perturb_array = data.perturb_array;
S_ave_array = data.S_ave_array;

red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
figure(1); clf;
set(gcf, 'Position', [100, 100, 950, 400]); % Set figure size
plot(perturb_array, S_ave_array, '-o', 'color', blue_base,'LineWidth', 2);hold on;
plot([-0.1,-0.1],[0,1],'-.','Color',red_base,'LineWidth',2); hold on;
grid on;
yticks([0,0.3,0.6,0.9,1])
xticks([-0.9:0.3:-0.3,-0.1,0])
axis tight
xlabel('$(J''_{0} - J_{0})/J_{0}$','Interpreter','latex');
ylabel('$\langle S\rangle$','Interpreter','latex')
set(gca, 'Fontsize', 20,'linewidth',1.5);
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);