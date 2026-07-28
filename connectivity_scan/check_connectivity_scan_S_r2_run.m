% connectivity_scan_S_r2_run.m
% Script (not a function): scans coupling_connectivity over 0 ... 1, and for
% each value computes BOTH synchronization measures from the same trajectory:
%
%   S(t)   = |sum_j E_j|^2 / (M * sum_j |E_j|^2)     intensity-weighted
%   R^2(t) = |sum_j E_j/|E_j||^2 / M^2               phase-only (Kuramoto)
%
% Plots S(t) and R^2(t), prints <S> and <R^2>, and quantifies WHY the two
% measures track each other so closely (see the decomposition section).
%
% Requires only base MATLAB (no Statistics Toolbox).

clear; clc; close all;
maxNumCompThreads(1);
rng('shuffle');

%% ------------------------------------------------------------------ setup
code_dir = '../';                 % holds lk_dde23 / lk_abm4milshtein / freq_disorders
addpath(code_dir);

method     = 'dde23';             % 'dde23' or 'abm4milshtein'
M          = 24;
num_rng_w  = 1;
std_w      = 14;
d          = 1;                   % coupling strength per existing link

conn_list  = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0];

% realizations of the random sparse graph per connectivity.
% c = 0 and c = 1 give a deterministic K, so they always use 1 realization.
% Raise this for publication statistics (the original scan used 1000).
num_repeat_sparse = 10;

% connectivities whose time series get plotted (must be members of conn_list)
plot_conn = [0 0.1 0.3 0.5 0.7 1.0];

data = load(fullfile(code_dir,'freq_disorders',['M_',num2str(M)], ...
    ['freq_disorder_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w), ...
     '_std_w_',num2str(std_w),'.mat']));
params.detuning = data.sorted_W;
params.M        = length(params.detuning);

initial_state_noise_switch = 0;   % with noise: 1, without: 0
if strcmp(method,'dde23')
    max_step = 1e-2;
elseif strcmp(method,'abm4milshtein')
    h_abm        = 1e-3;
    noise_switch = 0;
end

%% -------------------------------------------- rescaled diode laser params
N_bar = 1;
I_bar = 1;
tau   = 3;                      % ns, time delay (3 ns for diode)

params.freq_ref      = 2*pi/tau;
params.tau_const     = tau;
params.alpha         = 5;                   % linewidth enhancement factor
params.N0            = 1.5e8/N_bar;         % carriers at transparency
params.s             = 2e-7*I_bar;          % gain saturation coefficient
params.g             = 1.5e-5;              % gain coefficient, ns^-1
params.g_E           = params.g*N_bar;
params.g_N           = params.g*I_bar;
params.gamma         = 500;                 % cavity loss, ns^-1
params.gamma_n       = 0.5;                 % carrier loss, ns^-1
params.gamma_n_noise = params.gamma_n/N_bar;
params.j0            = 1/N_bar * 4 * params.gamma_n * ...
                       (params.N0*N_bar + params.gamma/params.g);
params.Rsp           = 5/I_bar;             % GHz, spontaneous emission noise

%% ------------------------------------------------------------ scan loops
nC = numel(conn_list);
ave_S_all   = cell(nC,1);   % <S>   per realization
ave_r2_all  = cell(nC,1);   % <R^2> per realization
ave_cv_all  = cell(nC,1);   % amplitude coefficient of variation, per realization
decomp_all  = zeros(nC,3);  % [cross-term, |D|^2 term, -CV^2 R^2 term], realization-averaged
series      = struct();     % time series of realization 1, for plotting

tic
for ic = 1:nC
    c = conn_list(ic);
    num_repeat = num_repeat_for(c, num_repeat_sparse);
    coupling_matrix_cell = gen_coupling(M, d, c, num_repeat);

    aS = zeros(num_repeat,1);
    ar = zeros(num_repeat,1);
    ac = zeros(num_repeat,1);
    ad = zeros(num_repeat,3);

    for i = 1:num_repeat
        params.coupling_matrix = coupling_matrix_cell{i,1};

        if strcmp(method,'dde23')
            [~, t_cell, E_cell, ~, ~, ~] = lk_dde23(max_step, ...
                params, initial_state_noise_switch);
        elseif strcmp(method,'abm4milshtein')
            [t_cell, E_cell, ~, ~, ~] = lk_abm4milshtein(h_abm, noise_switch, ...
                params, initial_state_noise_switch);
        end

        t_sol = t_cell{1};
        E_sol = E_cell{1};

        % ---------------------------------------------- order parameters
        S  = abs(sum(E_sol,1)).^2 ./ sum(abs(E_sol).^2,1) ./ M;

        E_sol_norm = E_sol ./ abs(E_sol);
        r2 = abs(sum(E_sol_norm,1)).^2 ./ M.^2;

        % amplitude heterogeneity: coefficient of variation of |E_j| at each t
        A  = abs(E_sol);
        cv = std(A,0,1) ./ mean(A,1);

        % averaging window: second half of the trajectory
        index = find(t_sol > round(t_sol(end)/2), 1);
        w     = index:length(t_sol);

        aS(i)   = sum(S(w))  ./ length(w);
        ar(i)   = sum(r2(w)) ./ length(w);
        ac(i)   = sum(cv(w)) ./ length(w);
        ad(i,:) = sr2_decomposition(E_sol, w);

        % ------------------------ store realization 1 for the time series
        if i == 1
            series(ic).t  = t_sol;
            series(ic).S  = S;
            series(ic).r2 = r2;
            series(ic).cv = cv;
            series(ic).index = index;
        end
    end
    % averaged over the same realizations as <S> and <R^2>, so that
    % sum(decomp_all(ic,:)) reproduces mean_S(ic) - mean_r2(ic) exactly
    decomp_all(ic,:) = mean(ad,1);

    ave_S_all{ic}  = aS;
    ave_r2_all{ic} = ar;
    ave_cv_all{ic} = ac;

    fprintf('connectivity %.2f done (%d realization(s))\n', c, num_repeat);
end
toc

%% ------------------------------------------------------- summary vectors
mean_S  = cellfun(@mean, ave_S_all);
mean_r2 = cellfun(@mean, ave_r2_all);
std_S   = cellfun(@std,  ave_S_all);
std_r2  = cellfun(@std,  ave_r2_all);
mean_cv = cellfun(@mean, ave_cv_all);

%% --------------------------------------------------- fig 1: time series
np       = numel(plot_conn);
zoom_win = [95 100];        % ns, short window so individual cycles resolve
f1  = figure('Color','w','Position',[100 100 1300 180*np],'Visible','off');
tl  = tiledlayout(f1, np, 3, 'TileSpacing','compact','Padding','compact');

for k = 1:np
    ic = find(conn_list == plot_conn(k), 1);
    if isempty(ic); continue; end
    s = series(ic);

    % --- full trace, both measures overlaid (S is hidden under R^2)
    nexttile
    plot(s.t, s.r2, 'LineWidth', 1.6, 'Color', [0.85 0.33 0.10]); hold on
    plot(s.t, s.S,  'LineWidth', 0.6, 'Color', [0 0.45 0.74]);
    xline(s.t(s.index),'k:');
    ylabel(sprintf('c = %.1f', conn_list(ic)));
    ylim([0 1]); grid on
    if k == 1
        title('full trace: S(t) and R^2(t)');
        legend('R^2(t)','S(t)','Location','northwest');
    end
    if k == np; xlabel('t (ns)'); end

    % --- zoom, so that the two curves can actually be told apart
    nexttile
    m = s.t >= zoom_win(1) & s.t <= zoom_win(2);
    plot(s.t(m), s.r2(m), 'LineWidth', 2.2, 'Color', [0.85 0.33 0.10]); hold on
    plot(s.t(m), s.S(m),  'LineWidth', 0.9, 'Color', [0 0.45 0.74]);
    xlim(zoom_win); ylim([0 1]); grid on
    if k == 1; title(sprintf('zoom, t = %g-%g ns', zoom_win)); end
    if k == np; xlabel('t (ns)'); end

    % --- pointwise difference
    nexttile
    plot(s.t, s.S - s.r2, 'LineWidth', 0.8); hold on
    yline(0,'k:');
    grid on
    if k == 1; title('S(t) - R^2(t)'); end
    if k == np; xlabel('t (ns)'); end
end
title(tl, sprintf('M = %d, %s, d = %g', M, method, d));

if ~exist('./fig','dir'); mkdir('./fig'); end
f1_name = ['./fig/scan_S_r2_timeseries_M_',num2str(M),'.png'];
exportgraphics(f1, f1_name, 'Resolution', 150);

%% ------------------------------------------------- fig 2: scan + reasons
f2 = figure('Color','w','Position',[100 100 1000 800],'Visible','off');

subplot(2,2,1)
errorbar(conn_list, mean_S,  std_S,  '-o','LineWidth',1.2); hold on
errorbar(conn_list, mean_r2, std_r2, '--s','LineWidth',1.2);
xlabel('coupling connectivity c'); ylabel('order parameter');
title('\langle S \rangle and \langle R^2 \rangle vs connectivity');
legend('\langle S \rangle','\langle R^2 \rangle','Location','northwest');
ylim([0 1]); grid on

subplot(2,2,2)
plot(conn_list, mean_S - mean_r2, '-o','LineWidth',1.2); hold on
yline(0,'k:');
xlabel('coupling connectivity c'); ylabel('\langle S \rangle - \langle R^2 \rangle');
title('difference between the two measures');
grid on

subplot(2,2,3)
plot(conn_list, mean_cv, '-o','LineWidth',1.2);
xlabel('coupling connectivity c'); ylabel('CV = std_j|E_j| / mean_j|E_j|');
title('amplitude heterogeneity');
grid on

subplot(2,2,4)
plot(conn_list, decomp_all(:,1), '-o', ...
     conn_list, decomp_all(:,2), '-s', ...
     conn_list, decomp_all(:,3), '-^', 'LineWidth',1.2); hold on
plot(conn_list, sum(decomp_all,2), 'k--','LineWidth',1.4);
xlabel('coupling connectivity c'); ylabel('contribution to \langle S - R^2 \rangle');
title('decomposition of S - R^2');
legend('2Re(Z^*D)/M^2q  (1st order)','|D|^2/M^2q  (2nd order)', ...
       '-CV^2R^2/q  (2nd order)','sum','Location','best');
grid on

f2_name = ['./fig/scan_S_r2_summary_M_',num2str(M),'.png'];
exportgraphics(f2, f2_name, 'Resolution', 150);

%% --------------------------------------------------------------- report
fprintf('\n============ M = %d, method = %s, d = %g ============\n', M, method, d);
fprintf('%6s %6s %10s %10s %12s %12s %10s\n', ...
    'c','n_rep','<S>','<R^2>','<S>-<R^2>','rel.diff','CV');
for ic = 1:nC
    rel = (mean_S(ic) - mean_r2(ic)) / mean_r2(ic);
    fprintf('%6.2f %6d %10.6f %10.6f %12.3e %12.3e %10.3e\n', ...
        conn_list(ic), numel(ave_S_all{ic}), mean_S(ic), mean_r2(ic), ...
        mean_S(ic)-mean_r2(ic), rel, mean_cv(ic));
end

fprintf('\n--- where the (tiny) difference comes from ---\n');
fprintf('%6s %14s %14s %14s %14s %10s\n', ...
    'c','2Re(Z*D)/M2q','|D|^2/M2q','-CV^2R^2/q','sum','rel/CV^2');
for ic = 1:nC
    rel = (mean_S(ic) - mean_r2(ic)) / mean_r2(ic);
    fprintf('%6.2f %14.3e %14.3e %14.3e %14.3e %10.3f\n', ...
        conn_list(ic), decomp_all(ic,1), decomp_all(ic,2), decomp_all(ic,3), ...
        sum(decomp_all(ic,:)), rel/mean_cv(ic)^2);
end
fprintf('\nfigures: %s\n         %s\n', f1_name, f2_name);

if ~exist('./data','dir'); mkdir('./data'); end
save(['./data/connectivity_scan_S_r2_M_',num2str(M),'.mat'], ...
     'conn_list','ave_S_all','ave_r2_all','ave_cv_all','decomp_all', ...
     'mean_S','mean_r2','std_S','std_r2','mean_cv','series','params','M','d','method');

%% ------------------------------------------------------- local functions
function n = num_repeat_for(c, num_repeat_sparse)
    % c = 0 (no links) and c = 1 (all-to-all) both give a deterministic K,
    % so averaging over graph realizations is meaningless there.
    if c == 0 || c == 1
        n = 1;
    else
        n = num_repeat_sparse;
    end
end

function coupling_matrix_cell = gen_coupling(M, d, coupling_connectivity, num_repeat)
    coupling_matrix_cell = cell(num_repeat,1);
    if coupling_connectivity == 0            % no links at all
        K = zeros(M,M);
        for repIdx = 1:num_repeat
            coupling_matrix_cell{repIdx,1} = K;
        end
    elseif coupling_connectivity == 1        % all-to-all coupling
        K = d*(ones(M)-eye(M));
        for repIdx = 1:num_repeat
            coupling_matrix_cell{repIdx,1} = K;
        end
    else                                     % sparse random symmetric graph
        numUpperDiagElements = (M*(M-1))/2;
        numOnes = round(numUpperDiagElements * coupling_connectivity);
        upperDiagIndices = find(triu(ones(M),1));
        for repIdx = 1:num_repeat
            K = zeros(M,M);
            % randperm = sampling without replacement, base MATLAB only
            % (the original used randsample, which needs the Stats Toolbox)
            selectedIndices = upperDiagIndices(randperm(numUpperDiagElements, numOnes));
            K(selectedIndices) = d;
            K = K + K';
            coupling_matrix_cell{repIdx,1} = K;
        end
    end
end

function terms = sr2_decomposition(E_sol, w)
    % Exact algebraic split of S - R^2, time-averaged over window w.
    %
    % With E_j = A_j exp(i th_j) and a_j = A_j / mean_k(A_k):
    %   Z = sum_j exp(i th_j),  D = sum_j (a_j - 1) exp(i th_j),  q = 1 + CV^2
    %   S     = |Z + D|^2 / (M^2 q)
    %   R^2   = |Z|^2 / M^2
    %   S-R^2 = [ 2Re(Z* D) + |D|^2 ] / (M^2 q)  -  (CV^2/q) * R^2
    %
    % term 1 is FIRST order in amplitude deviation (amplitude-phase
    % correlation); terms 2 and 3 are SECOND order.
    M   = size(E_sol,1);
    A   = abs(E_sol);
    a   = A ./ mean(A,1);
    ph  = E_sol ./ A;
    Z   = sum(ph,1);
    D   = sum((a-1).*ph,1);
    cv2 = mean((a-1).^2,1);
    q   = 1 + cv2;
    R2  = abs(Z).^2 ./ M^2;

    t1 = 2*real(conj(Z).*D) ./ (M^2*q);
    t2 = abs(D).^2          ./ (M^2*q);
    t3 = -(cv2./q) .* R2;

    terms = [mean(t1(w)), mean(t2(w)), mean(t3(w))];
end
