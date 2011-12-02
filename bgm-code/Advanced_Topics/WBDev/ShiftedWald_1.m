% WDev shifted Wald
clear;

% load data
load rtdata;
load nrt;

%the data from the first participant

rt = rtdata(1,:);
nrt = nrt(1);

% WinBUGS Parameters
nchains=3; % How Many Chains?
nburnin=1000; % How Many Burn-in Samples?
nsamples=10000; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('rt',rt,'nrt',nrt);

% Initialize Unobserved Variables
for i=1:nchains
    S.v = unifrnd(3,6,1,1);
    S.a = unifrnd(3,6,1,1);
    S.Ter = unifrnd(0.3,0.6,1,1);
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'ShiftedWald_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'v','a','Ter'}, ...
    'Bugdir', 'C:/Program Files/BlackBox Component Builder 1.5');




