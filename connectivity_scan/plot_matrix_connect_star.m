clear;
load('./data/diode_data_connectivity_0.35_M_24.mat')

K = 10;

[sortedS, idx] = sort(ave_S_array(:), 'descend');
top_idx = idx(1:min(K, numel(idx)));


figure('Color','w','Name','Top by ave\_S');
tiledlayout(2,5,'Padding','compact','TileSpacing','compact');

for n = 1:numel(top_idx)
    A = coupling_matrix_cell{top_idx(n)};   

   
    A = double(A > 0.5);
    
    nexttile;
    imagesc(A);                
    axis image off;
    caxis([0 1]);              
    colormap(gca, [1 1 1; 0 0 0]);  
    
    title(sprintf('#%d  idx=%d  S=%.4g', ...
          n, top_idx(n), sortedS(n)), 'FontSize', 10, 'Interpreter','none');
end

% exportgraphics(gcf, 'top10_coupling.png', 'Resolution', 300);
