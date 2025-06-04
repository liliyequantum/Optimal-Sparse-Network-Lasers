clear;close all;

data = load('data_perb_w.mat');
sigma_f_perb_array = data.sigma_f_perb_array;
ave_S_sample = data.ave_S_sample;
std_S_sample = data.std_S_sample;
f_perb = data.f_perb;
num_sample = data.num_sample;

data = load('../GA_island/hub_data.mat');
detuning_2d = data.detuning_2d;
W = detuning_2d(:,2);
M = length(W);

percentage_f_perb = zeros(M,num_sample,length(sigma_f_perb_array));
for i = 1:num_sample
    for fidx = 1:length(sigma_f_perb_array)
        percentage_f_perb(:,i,fidx) = abs(f_perb(:,i,fidx))./abs(W);
    end
end
mean_percentage_f_perb = squeeze(mean(percentage_f_perb, [1 2]));


mean_S = mean(ave_S_sample);
std_S = mean(std_S_sample);

red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
figure(1); clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size
yyaxis left
set(gca, 'YColor', blue_base);
errorbar(sigma_f_perb_array, mean_S, std_S, 'o-', 'color', blue_base,...
    'LineWidth', 2, 'MarkerSize', 6, 'CapSize', 8);
ylabel('$\langle S \rangle$','Interpreter','latex');
yticks([0.5,0.7,0.9,1])
ylim([0.5, 1]);
xlim([0,10.5])

yyaxis right
set(gca, 'YColor', red_base);
plot(sigma_f_perb_array, mean_percentage_f_perb*100, '-o', 'color', red_base,'LineWidth', 2);hold on;
plot([0,10.5], [54.95,54.95], '-.', 'color',red_base, 'LineWidth', 2);
ylabel('$\langle |\delta \omega_{i}|/|\Delta_{i}| \rangle (\%)$', 'Interpreter','latex');
yticks([0,50,100,125])
ylim([0, 125]);

% ===== Common settings =====
xlabel('$\sigma_{\omega}$ (rad/ns)','Interpreter','latex');
grid on;

% Style for both y-axes
ax = gca;
ax.FontSize = 20;
ax.LineWidth = 1.5;
ax.XTickMode = 'auto';  % Ensure both yyaxis share same X ticks
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);