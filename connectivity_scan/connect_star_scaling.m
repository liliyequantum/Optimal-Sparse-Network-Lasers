clear;

M_array = [12 18 24 30 36 42 46 50 55 60 65 70 80 90 100];
connectivity_array = 0:0.05:1;
ave_S_2d = zeros(length(M_array),length(connectivity_array));
for Midx = 1:length(M_array)
    for cidx = 1:length(connectivity_array)
        data = load(['./data/diode_data_connectivity_',num2str(connectivity_array(cidx)),...
        '_M_',num2str(M_array(Midx)),'.mat']);
        ave_S_2d(Midx,cidx) = max(data.ave_S_array);
    end
    disp(['progress: ',num2str(Midx/length(M_array))])
end

[value,connect_idx] = max(ave_S_2d,[],2);
connect_val = connectivity_array(connect_idx);

save('connect_star_scaling.mat','connect_val')

% load('connect_star.mat')
% connect_val_mean = mean(connect_val);
% connect_val_std = std(connect_val);
