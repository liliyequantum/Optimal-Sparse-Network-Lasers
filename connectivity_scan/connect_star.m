clear;

num_rng_w_array = 0:99;
connectivity_array = 0:0.05:1;
ave_S_2d = zeros(length(num_rng_w_array),length(connectivity_array));
for widx = 1:length(num_rng_w_array)
    for cidx = 1:length(connectivity_array)
        data = load(['./data/diode_data_connectivity_',num2str(connectivity_array(cidx)),...
            '_num_rng_w_',num2str(num_rng_w_array(widx)),'.mat']);
        ave_S_2d(widx,cidx) = max(data.ave_S_array);
    end
    disp(['progress: ',num2str(widx/length(num_rng_w_array))])
end

[value,connect_idx] = max(ave_S_2d,[],2);
connect_val = connectivity_array(connect_idx);

save('connect_star.mat','connect_val')

% load('connect_star.mat')
% connect_val_mean = mean(connect_val);
% connect_val_std = std(connect_val);
