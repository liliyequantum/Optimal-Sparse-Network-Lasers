clear;close all;

sigma_init_array = [1e-6, 1e-4, 1e-2, 1e-1];
R_sp_array = [1, 5, 10, 50, 100];
S_ave_grid = zeros(length(R_sp_array), length(sigma_init_array));
S_std_grid = zeros(length(R_sp_array), length(sigma_init_array));
for sidx=1:length(sigma_init_array)
    for ridx = 1:length(R_sp_array)
    data = load(['./data/init_noise_var_',num2str(sigma_init_array(sidx)),...
        '_dynamic_noise_var_',num2str(R_sp_array(ridx)),'_num_sample_100.mat']);
    S_ave_grid(ridx,sidx) = mean(data.ave_S_sample);
    S_std_grid(ridx,sidx) = mean(data.std_S_sample);
    end
end

sigma_init_grid = repmat(sigma_init_array, length(R_sp_array), 1);         
R_sp_grid = repmat(R_sp_array', 1, length(sigma_init_array)); 

figure(1); clf;
% set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
surf(R_sp_grid, sigma_init_grid, S_ave_grid, 'EdgeColor', 'k', 'FaceColor', 'flat');
view(2);  % 2D top-down view
axis tight
colormap(parula)
clim([0.96 max(S_ave_grid(:))])
colorbar;
xlabel('$R_{sp} (ns^{-1})$','Interpreter','latex')
ylabel('$\sigma_{init}$','Interpreter','latex')
set(gca, 'FontSize', 18,'LineWidth',1, 'Yscale', 'log')
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);



figure(2); clf;
% set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
surf(R_sp_grid, sigma_init_grid, S_std_grid, 'EdgeColor', 'k', 'FaceColor', 'flat');
view(2);  % 2D top-down view
axis tight
colormap(parula)
clim([0.001 0.01])
colorbar;
xlabel('$R_{sp} (ns^{-1})$','Interpreter','latex')
ylabel('$\sigma_{init}$','Interpreter','latex')
set(gca, 'FontSize', 18,'LineWidth',1, 'Yscale', 'log')
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);
