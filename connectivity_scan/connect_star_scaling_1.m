clear;

M_array = [12 18 24 30 36 42 46 50 55 60 65 70 80 90 100];
connect_star_array = zeros(length(M_array),1);

for Midx = 1:length(M_array)
    M = M_array(Midx);
    if ismember(M, [42 46 50 55 60 65 70 80 90 100])
        connectivity_array = 0:0.01:0.25;
    elseif M == 12
        connectivity_array = 0:0.05:1;
    elseif M == 18
        connectivity_array = 0.45:0.005:0.47;
    elseif M == 24
        connectivity_array = 0:0.02:1;
    elseif M == 30
        connectivity_array = 0.25:0.01:0.3;
    elseif M == 36
        connectivity_array = 0.23:0.005:0.25;
    end
    ave_S = zeros(length(connectivity_array),1);
    for cidx = 1:length(connectivity_array)
        data = load(['./data/diode_data_connectivity_',num2str(connectivity_array(cidx)),...
        '_M_',num2str(M_array(Midx)),'.mat']);
        ave_S(cidx) = max(data.ave_S_array);
    end
    [~,loc] = max(ave_S);
    connect_star_array(Midx) = connectivity_array(loc);
    disp(['progress: ',num2str(Midx/length(M_array))])
end

save('connect_star_scaling_1.mat','connect_star_array','M_array')

% load('connect_star.mat')
% connect_val_mean = mean(connect_val);
% connect_val_std = std(connect_val);
