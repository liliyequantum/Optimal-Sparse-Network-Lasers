clear;
numGen = 30;
num_rng_GA = 0;
data = load(['./data_coupling_matrix_set_GA/updated_GA_island_num_rng_GA_',...
    num2str(num_rng_GA),'.mat']);
coupling_matrix_set = data.coupling_matrix_set;
fitnessScores_set = data.fitnessScores_set;
gen_array = 1:1:numGen;
worstAdjMatrix = cell(length(gen_array),1);
worst_S = zeros(length(gen_array),1);
% Get the best adjacency matrix from all islands

for gidx = 1:length(gen_array)
    gen = gen_array(gidx);
    % ridx 是当前行
    rowCells = fitnessScores_set(gen, :);          % 这一行的所有 50x1 向量
    minsPerCell = cellfun(@min, rowCells);          % 每个 cell 内部的最小值
    [worst_S(gidx,1), worstCol] = min(minsPerCell);      % 这一行里最小值所在的列
    
    % 在该列的 50x1 向量里再找其位置（避免用 ==，直接用 argmin）
    vec = rowCells{worstCol};                       % 50x1 向量
    [~, worstIdx] = min(vec);                       % 该向量中的索引(1..50)
    
    % 取对应的个体/耦合矩阵（注意 islands 与 fitnessScores_set 对齐）
    worstPop = coupling_matrix_set{gen, worstCol};             % 这一格里的个体集合(通常是 cell)
    worstAdjMatrix{gidx,1} = worstPop{worstIdx};            % 取到对应的耦合矩阵
end

save(['worstAdjmatrix_GA_',num2str(num_rng_GA),'.mat'],'worstAdjMatrix','worst_S')