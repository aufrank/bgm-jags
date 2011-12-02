% Kappa Coefficient of Agreement

clear;

% Data (Observed Variables)
d=[14 4 5 210];
%d=[20 7 103 417];
%d=[157 0 13 0];

% Derived Variables
n=sum(d);

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=2e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('d',d,'n',n);

% Initialize Unobserved Variables
for i=1:nchains
    S.alpha = 0.5; % An Intial Value
    S.beta = 0.5; % An Intial Value
    S.gamma = 0.5; % An Intial Value
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Kappa_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'kappa','xi','psi','alpha','beta','gamma','pi'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');