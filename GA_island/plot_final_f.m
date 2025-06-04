clear;close all;
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];

data = load('final_f_data.mat');
final_f = data.final_f/2/pi;
final_max_std_f = data.final_max_std_f/2/pi;
mean_true_f = data.mean_true_f/2/pi;

figure(1); clf;
set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
scatter(mean_true_f(:), final_f(:), 50, 'filled', 'MarkerFaceColor','k','Marker','o');hold on;
plot([-2, 2], [-1.06+6/3, -1.06+6/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06+5/3, -1.06+5/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06+4/3, -1.06+4/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06+3/3, -1.06+3/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06+2/3, -1.06+2/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06+1/3, -1.06+1/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06, -1.06], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06-1/3, -1.06-1/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06-2/3, -1.06-2/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06-3/3, -1.06-3/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06-4/3, -1.06-4/3], 'k--', 'LineWidth', 1.8);
plot([-2, 2], [-1.06-5/3, -1.06-5/3], 'k--', 'LineWidth', 1.8);

xlim([-2,2])
set(gca,'FontSize',22,'FontName','Times New Roman');
grid on
xlabel('$\bar{f}_{\textnormal{true}}$(GHz)','Interpreter','latex')
ylabel('$\bar{f}_{\textnormal{final}}$ (GHz)','Interpreter','latex')
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

max(final_max_std_f)
min(final_max_std_f)

