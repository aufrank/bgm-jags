% The Seven Scientists

clear;

% Data
x=[-27.020,3.570,8.191,9.898,9.603,9.945,10.056];
% Derived Variables
n=length(x);

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=1e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('x',x,'n',n);

% Initialize Unobserved Variables
for i=1:nchains
    S.mu = 0; % An Intial Value
    S.lambda = ones(1,n); % Intial Values For All The Standard Deviations
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Gaussian_2.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'mu','sigma'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');