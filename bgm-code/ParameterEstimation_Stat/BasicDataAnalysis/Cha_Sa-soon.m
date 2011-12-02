%% Cha_sa-Soon

clear;

nattempts=950;
nfails=949;
nquestions=50;
cens=29;
y=[cens*ones(nfails,1);cens+1];
z=[nan*ones(nfails,1);cens+1];

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=2e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('nattempts',nattempts,'nquestions',nquestions,'cens',cens,'z',z,'y',y);

% Initialize Unobserved Variables
for i=1:nchains
    S.theta=rand;
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Cha_Sa-soon.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',1, ...
    'monitorParams', {'theta','z'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');