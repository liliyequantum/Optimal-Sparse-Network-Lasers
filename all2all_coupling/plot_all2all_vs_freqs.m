clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; purple;green;bright_blue;dark_red;blue;orange;yellow];

M_array = [12, 24, 50];
num_rng_w_array = 0:9;
std_w = 14;
d_array = [0:0.05:3, 3.2:0.2:5];

[d_array,mean_S,upper_S,lower_S, ave_S_3d]= plot_data(M_array, d_array, num_rng_w_array, std_w);

% a = mean(ave_S_3d(:,14,1));
% b= std(ave_S_3d(:,14,1));
% a+b

figure;
for M_idx = 1:length(M_array)
    plot(d_array,mean_S(:, M_idx),'-o', 'color',color_map(M_idx,:),'MarkerSize', 4, 'LineWidth', 1.5,...
        'DisplayName',['M = ',num2str(M_array(M_idx))]); hold on;
    fill([d_array, fliplr(d_array)], [upper_S(:,M_idx)', fliplr(lower_S(:,M_idx)')],color_map(M_idx,:),...
        'FaceAlpha', 0.4, 'EdgeColor', 'none', 'HandleVisibility', 'off'); hold on;
end

legend('FontSize',18, 'Location','best')

axis tight
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
ylim([0,1])

exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);
% close;

function [d_array,mean_S,upper_S,lower_S, ave_S_3d]=plot_data(M_array,...
    d_array, num_rng_w_array, std_w)

    % coupling_sum_3d = zeros(length(num_rng_w_array),length(d_array),length(M_array));
    ave_S_3d = zeros(length(num_rng_w_array),length(d_array),length(M_array));
    for M_idx = 1:length(M_array)
        M = M_array(M_idx);
        for rng_idx = 1:length(num_rng_w_array)
            num_rng_w = num_rng_w_array(rng_idx);
            data = load(['./data/diode_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
                '_std_w_',num2str(std_w),'.mat']);
        
            ave_S_3d(rng_idx, :, M_idx) = data.ave_S_array;
            
        end
    end
    
    mean_S = zeros(length(d_array),length(M_array));
    upper_S = zeros(length(d_array),length(M_array));
    lower_S = zeros(length(d_array),length(M_array));
    for M_idx = 1:length(M_array)
        for d_idx = 1:length(d_array)           
            tmp = ave_S_3d(:, d_idx, M_idx);
            mean_tmp = mean(tmp);
            std_tmp = std(tmp);

            mean_S(d_idx,M_idx) = mean_tmp;
            upper_S(d_idx,M_idx) = mean_tmp + std_tmp;
            lower_S(d_idx,M_idx) = mean_tmp - std_tmp;

        end
    end
    
 
end

