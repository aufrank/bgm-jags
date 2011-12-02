% Inferring A Common Rate

clear;

% Data
k1=5;n1=10;k2=7;n2=10

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=1e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('k1',k1,'n1',n1,'k2',k2,'n2',n2);

% Initialize Unobserved Variables
for i=1:nchains
    S.theta = 0.5; % An Intial Value for the Success Rate
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Rate_3.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'theta'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');
