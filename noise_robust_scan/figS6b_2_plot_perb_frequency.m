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
ave_f_perb = zeros(1, num_sample,length(sigma_f_perb_array));
for i = 1:num_sample
    for fidx = 1:length(sigma_f_perb_array)
        percentage_f_perb(:,i,fidx) = abs(f_perb(:,i,fidx))./abs(W);
        ave_f_perb(:,i,fidx) = mean(abs(f_perb(:,i,fidx)))./mean(abs(W));
    end
end
mean_percentage_f_perb = squeeze(mean(percentage_f_perb, [1 2]));
mean_ave_f_perb = squeeze(mean(ave_f_perb, [1 2]));


mean_S = mean(ave_S_sample);
std_S = mean(std_S_sample);

red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
figure(1); clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size
% plot([0.357, 0.357], [0,1], '-.', 'color',red_base, 'LineWidth', 2);hold on;
errorbar(sigma_f_perb_array/14, mean_S, std_S, 'o-', 'color', orange,...
    'LineWidth', 2, 'MarkerSize', 6, 'CapSize', 8);hold on;
ylabel('$\langle S \rangle$','Interpreter','latex');
yticks([0,0.3,0.5,0.7,0.9,1])
ylim([0, 1]);
xlim([-0.01,0.75])

% ===== Common settings =====
xlabel('$\sigma_{\omega}/\sigma_{\Delta}$','Interpreter','latex');
grid on;

% Style for both y-axes
ax = gca;
ax.FontSize = 20;
ax.LineWidth = 1.5;
ax.XTickMode = 'auto';  % Ensure both yyaxis share same X ticks
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);