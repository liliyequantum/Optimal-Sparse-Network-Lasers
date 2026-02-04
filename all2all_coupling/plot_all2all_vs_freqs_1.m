clear;clc;close all;

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
color_map = [blue; orange; yellow; green;bright_blue;dark_red;blue;orange;yellow];

M_array = [24, 50, 100,200];%[12, 24, 50];
num_rng_w_array = 0:9;
std_w = 14;
num_d = 21;
num_d_1 = 51;

% ave_S_cell = cell(length(M_array),length(num_rng_w_array));
d_array_cell = cell(length(M_array),length(num_rng_w_array));
S_mean_cell = cell(length(M_array),1);
S_upper_cell = cell(length(M_array),1);
S_lower_cell = cell(length(M_array),1);
for Midx = 1:length(M_array)
    M = M_array(Midx);
    if ismember(M, [24, 50])
        S = zeros(num_d, length(num_rng_w_array));
    else
        S = zeros(num_d_1, length(num_rng_w_array));
    end

    for rng_idx = 1:length(num_rng_w_array)
        num_rng_w = num_rng_w_array(rng_idx);

        if ismember(M, [24, 50])
            data = load(['./data/diode_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
                '_std_w_',num2str(std_w),'.mat']);
            % ave_S_cell{Midx, rng_idx} = data.ave_S_array(1:num_d);
            d_array_cell{Midx, rng_idx} = data.d_array(1:num_d);
            S(:,rng_idx) = data.ave_S_array(1:num_d);
        else
             data = load(['./data_homo/diode_data_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
            '_std_w_',num2str(std_w),'.mat']);
            % ave_S_cell{Midx, rng_idx} = data.ave_S_array(1:num_d_1);
            d_array_cell{Midx, rng_idx} = data.d_array(1:num_d_1);
            S(:,rng_idx) = data.ave_S_array(1:num_d_1);
        end  
    end

    S_mean_cell{Midx,1} = mean(S,2);
    S_upper_cell{Midx,1} = mean(S,2) + std(S,0, 2);
    S_lower_cell{Midx,1} = mean(S,2) - std(S,0, 2);
end

size_array = [5, 5, 4,4];
figure;
for Midx = 1:length(M_array)
       plot(d_array_cell{Midx},S_mean_cell{Midx},'-o', 'color',color_map(Midx,:),'MarkerSize', size_array(Midx), 'LineWidth', 1.5,...
            'DisplayName',['M = ',num2str(M_array(Midx))]); hold on;
       fill([d_array_cell{Midx}, fliplr(d_array_cell{Midx})], [S_upper_cell{Midx}', fliplr(S_lower_cell{Midx}')],color_map(Midx,:),...
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


    
    
 


