clear;
load('./data/diode_data_connectivity_0.35_M_24.mat')
% K 个最佳
K = 10;

% 1) 按 ave_S 从大到小排序，取前 K
[sortedS, idx] = sort(ave_S_array(:), 'descend');
top_idx = idx(1:min(K, numel(idx)));

% 2) 画图（黑=1、白=0）
figure('Color','w','Name','Top by ave\_S');
tiledlayout(2,5,'Padding','compact','TileSpacing','compact');

for n = 1:numel(top_idx)
    A = coupling_matrix_cell{top_idx(n)};   % 取对应的耦合矩阵（0/1）

    % 保险：限制在 [0,1] 且二值化
    A = double(A > 0.5);
    
    nexttile;
    imagesc(A);                 % 显示矩阵
    axis image off;
    caxis([0 1]);               % 映射范围固定到 0..1
    colormap(gca, [1 1 1; 0 0 0]);  % 0=白，1=黑
    
    title(sprintf('#%d  idx=%d  S=%.4g', ...
          n, top_idx(n), sortedS(n)), 'FontSize', 10, 'Interpreter','none');
end

% 如果想保存为图片：
% exportgraphics(gcf, 'top10_coupling.png', 'Resolution', 300);
