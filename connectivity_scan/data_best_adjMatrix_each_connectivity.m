clear;
M=24;
connectivity_array = 0:0.05:1;
bestAdjMatrix_connect_cell = cell(length(connectivity_array),1);
for cidx = 1:length(connectivity_array)
    data = load(['./data/diode_data_connectivity_',num2str(connectivity_array(cidx)),...
    '_M_',num2str(M),'.mat']);
    [value, loc] = max(data.ave_S_array);
    bestAdjMatrix_connect_cell{cidx} = data.coupling_matrix_cell{loc};
end
save('bestAdjMatrix_at_each_connect.mat','bestAdjMatrix_connect_cell','connectivity_array')