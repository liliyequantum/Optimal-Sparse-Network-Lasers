% function freq_disorder_gen(M)

M = 400; % M Number of lasers in 1D array
mkdir(['./M_',num2str(M)])
if M == 1
    sorted_W = 0; % rad/ns
    save(['./M_',num2str(M),'/freq_disorder_M_',num2str(M),'.mat'])
else
    num_rng_w_array = 0:1:9;
    std_w_array = [14]; % rad/ns
    for rngwIdx = 1:1:length(num_rng_w_array)
        for stdwIdx = 1:1:length(std_w_array)
    
            num_rng_w = num_rng_w_array(rngwIdx);
            std_w =  std_w_array(stdwIdx);
            
            rng(num_rng_w);
            W =  std_w* randn(M, 1);  % Disorder for each laser
            [~, sortIdx] = sort(W); % Get the sorted indices based on abs(W)
            sorted_W = W(sortIdx);       % Reorder W using the sorted indices
            save(['./M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),...
                '_std_w_',num2str(std_w),'.mat'], 'sorted_W')
        end
    end

end
% end
