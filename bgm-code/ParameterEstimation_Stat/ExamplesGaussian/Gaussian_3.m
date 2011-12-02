% Repeated Measures of IQ

clear;

% Data
x=[90 95 100;
    105 110 115;
    150 155 160];
% Derived Variables
[n m]=size(x);

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=1e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('x',x,'n',n,'m',m);

% Initialize Unobserved Variables
for i=1:nchains
    S.mu = 100*ones(1,n); % Intial Values for All The Means
    S.sigma = 1; % Intial Values For The Standard Deviation
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Gaussian_3.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'mu','sigma'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');