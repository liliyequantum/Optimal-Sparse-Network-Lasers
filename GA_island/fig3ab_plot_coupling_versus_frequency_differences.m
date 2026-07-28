clear;close all;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
brown = [192, 79, 21]/255;
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];

% Parameters
M = 24; % Nodes (Adjacency Matrix Size)
type_freq_disorder = 'gaussian';
std_w = 14;
num_rng_w_array = 0:9;
data = load('hub_data.mat');

detuning_2d = data.detuning_2d;
K_3d = data.K_3d;
best_S_1d = data.best_S_1d;
% 
% for i = 1:length(num_rng_w_array)
%     best_S = best_S_1d(i);
%     best_coupling_matrix =  K_3d(:,:,i);
%     W = detuning_2d(:,i); % detuning
% 
%     W_ij = W - W';
%     index_sparse = find(best_coupling_matrix == 1);
%     W_best_ij = W_ij(index_sparse);
%     index_all2all = find(ones(M) - eye(M) == 1);
%     W_all2all_ij = W_ij(index_all2all);
% 
%     max_abs_W = max(abs(W_ij(:)));% Calculate the max absolute value of the detuning differences
%     max_abs_W = ceil(max_abs_W);% Round up to nearest whole number and create symmetric bin edges
%     edges = -max_abs_W : 1 : max_abs_W;
%     [counts_all2all, ~] = histcounts(W_all2all_ij, edges);
%     [counts_sparse, ~]  = histcounts(W_best_ij, edges);
%     bin_centers = edges(1:end-1) + diff(edges)/2;
%     figure(i); clf;
%     set(gcf, 'Position', [100, 100, 250, 250]); % Set figure size to 800x600 pixels
%     hold on;
%     bar(bin_centers, 0.4*counts_all2all, 1, 'FaceColor', [0 0 0], 'FaceAlpha', 0.15, 'EdgeColor', 'none');
%     bar(bin_centers, counts_sparse, 1, 'FaceColor', [0.8500 0.3250 0.0980], 'EdgeColor', 'none');
%     plot(bin_centers, counts_sparse - 0.4*counts_all2all, '-', 'LineWidth', 2);
%     ax = gca;
%     ax.FontSize = 10;
%     % legend('All-to-All Coupling', 'Sparse Engineering', 'Reduction','Location', 'best','fontsize',6);
%     xlabel('$\Delta_{i} - \Delta_{j}$ (rad/ns)', 'Interpreter', 'latex');
%     % ylabel('No. $K(i,j)=1\,ns^{-1}$', 'Interpreter', 'latex');
%     ylabel('$K(i,j)~(ns^{-1})$', 'Interpreter', 'latex');
%     title(['$\langle S \rangle$ = ', sprintf('%.2f', best_S)], 'Interpreter', 'latex','color',[0.8500 0.3250 0.0980]);
%     if i == 2
%         ylim([-20,15])
%     else
%         ylim([-20,21])
%     end
%     % exportgraphics(gcf, ['figure_',num2str(i),'.png'], 'Resolution', 300);
% 
% end

for i = 2
    best_S = best_S_1d(i);
    best_coupling_matrix =  K_3d(:,:,i);
    W = detuning_2d(:,i); % detuning
    
    W_ij = W - W';
    index_sparse = find(best_coupling_matrix == 1);
    W_best_ij = W_ij(index_sparse);
    index_all2all = find(ones(M) - eye(M) == 1);
    W_all2all_ij = W_ij(index_all2all);
    
    max_abs_W = max(abs(W_ij(:)));% Calculate the max absolute value of the detuning differences
    max_abs_W = ceil(max_abs_W);% Round up to nearest whole number and create symmetric bin edges
    edges = -max_abs_W : 1 : max_abs_W;
    [counts_all2all, ~] = histcounts(W_all2all_ij, edges);
    [counts_sparse, ~]  = histcounts(W_best_ij, edges);
    bin_centers = edges(1:end-1) + diff(edges)/2;

    figure(i); clf;
    set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
    hold on;
    bar(bin_centers, counts_all2all./M./(M-1)*100, 1, 'FaceColor', bright_blue, 'FaceAlpha', 1, 'EdgeColor', 'none');
   
    % plot(bin_centers, counts_sparse - 0.4*counts_all2all, '-','LineWidth', 2);
    ax = gca;
    ax.FontSize = 18;
    % legend('All-to-All Coupling', 'Sparse Engineering', 'Reduction','Location', 'best','fontsize',6);
    xlabel('$\Delta_{i} - \Delta_{j}$ (rad/ns)', 'Interpreter', 'latex');
    % ylabel('No. $K(i,j)=1\,ns^{-1}$', 'Interpreter', 'latex');
    ylabel('Links (\%)', 'Interpreter', 'latex');
    % title(['$\langle S \rangle$ = ', sprintf('%.2f', 0.84)], 'Interpreter', 'latex','color',blue);
    % ylim([-15,20])
    ylim([0,3])
    set(gca, 'FontSize', 20, 'Box', 'off', 'linewidth', 2, 'TickDir', 'out', 'TickLength', [0.01, 0.01])

    exportgraphics(gcf, ['figure_', num2str(i), '.png'], 'Resolution', 300);

    figure(i+1); clf;
    set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
    hold on;
    bar(bin_centers, counts_sparse./M./(M-1)*100, 1, 'FaceColor', yellow,'FaceAlpha', 0.8, 'EdgeColor', 'none');   
    % plot(bin_centers, counts_sparse - 0.4*counts_all2all, '-','LineWidth', 2);
    ax = gca;
    ax.FontSize = 18;
    % legend('All-to-All Coupling', 'Sparse Engineering', 'Reduction','Location', 'best','fontsize',6);
    xlabel('$\Delta_{i} - \Delta_{j}$ (rad/ns)', 'Interpreter', 'latex');
    % ylabel('No. $K(i,j)=1\,ns^{-1}$', 'Interpreter', 'latex');
    ylabel('Links (\%)', 'Interpreter', 'latex');
    set(gca, 'FontSize', 20, 'Box', 'off', 'linewidth', 2, 'TickDir', 'out', 'TickLength', [0.01, 0.01])

    % title(['$\langle S \rangle$ = ', sprintf('%.2f', best_S)], 'Interpreter', 'latex','color',brown);
    % ylim([-15,20])
    ylim([0,3])
    exportgraphics(gcf, ['figure_', num2str(i+1), '.png'], 'Resolution', 300);

end




