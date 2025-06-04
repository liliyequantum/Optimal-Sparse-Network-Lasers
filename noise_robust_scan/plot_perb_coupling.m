clear;close all;

data = load('data_perb_kappa.mat');
sigma_kappa_perb_array = data.sigma_kappa_perb_array;
ave_S_sample = data.ave_S_sample;
std_S_sample = data.std_S_sample;
coupling_perb = data.coupling_perb;
mean_coupling_perb = squeeze(mean(coupling_perb, [1 2 3]));

mean_S = mean(ave_S_sample);
std_S = mean(std_S_sample);

red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
figure(1); clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size
yyaxis left
set(gca, 'YColor', blue_base);
errorbar(sigma_kappa_perb_array, mean_S, std_S, 'o-', 'color', blue_base,...
    'LineWidth', 2, 'MarkerSize', 6, 'CapSize', 8);
ylabel('$\langle S \rangle$','Interpreter','latex');
yticks([0.5,0.75,0.9, 1])
ylim([0.5, 1]);
xlim([0,0.31])

yyaxis right
set(gca, 'YColor', red_base);
plot(sigma_kappa_perb_array, mean_coupling_perb, '-o', 'color', red_base,'LineWidth', 2);hold on;
plot([0,0.31], [0.05,0.05], '-.','color',red_base, 'LineWidth', 2);
ylabel('$\langle \delta K_{ij} \rangle\,(ns^{-1})$', 'Interpreter','latex');
yticks([0,0.05,0.1,0.2])
ylim([0, 0.2]);

% ===== Common settings =====
xlabel('$\sigma_{\kappa} (ns^{-1})$','Interpreter','latex');
grid on;

% Style for both y-axes
ax = gca;
ax.FontSize = 20;
ax.LineWidth = 1.5;
ax.XTickMode = 'auto';  % Ensure both yyaxis share same X ticks
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);