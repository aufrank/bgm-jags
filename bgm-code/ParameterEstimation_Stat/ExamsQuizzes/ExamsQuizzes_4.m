% Country Quiz

clear;

% Choose Dataset
dset=3;

% Data
switch dset
    case 1, k=[1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            0 1 1 0 0 1 0 0;
            0 1 1 0 0 1 1 0;
            1 0 0 1 1 0 0 1;
            0 0 0 1 1 0 0 1;
            0 1 0 0 0 1 1 0;
            0 1 1 1 0 1 1 0];
    case 2,k=[1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            0 1 1 0 0 1 0 0;
            0 1 1 0 0 1 1 0;
            1 0 0 1 1 0 0 1;
            0 0 0 1 1 0 0 1;
            0 1 0 0 0 1 1 0;
            0 1 1 1 0 1 1 0;
            1 0 0 1 nan nan nan nan;
            0 nan nan nan nan nan nan nan;
            nan nan nan nan nan nan nan nan];
    case 3,k=[1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            1 0 0 1 1 0 0 1;
            0 1 1 0 0 1 0 0;
            0 1 1 0 0 1 1 0;
            1 0 0 1 1 0 0 1;
            0 0 0 1 1 0 0 1;
            0 1 0 0 0 1 1 0;
            0 1 1 1 0 1 1 0;
            1 0 0 1 nan nan nan nan;
            0 nan nan nan nan nan nan nan;
            nan nan nan nan nan nan nan nan];
end;
% Number of people
[np nq] = size(k);

% Sampling Parameters
nchains=1; % number of chains
nburnin=1e3; % number of burn-in samples
nsamples=2e3; % number of samples

% Data to Supply to WinBugs
datastruct = struct('np',np,'nq',nq,'k',k);

% Initial Values to Supply to WinBugs
for i=1:nchains
    S.pz = round(rand(1,np));
    S.qz = round(rand(1,nq));
    S.alpha = 1/2;
    S.beta = 1/2;
    init0(i) = S;
end

switch dset
    case 1,
        [samples, stats] = matbugs(datastruct, ...
            fullfile(pwd, 'ExamsQuizzes_4.txt'), ...
            'init', init0, ...
            'nChains', nchains, ...
            'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
            'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
            'monitorParams', {'pz','qz','alpha','beta'}, ...
            'Bugdir', 'C:/Program Files/WinBUGS14');
    case {2,3}, [samples, stats] = matbugs(datastruct, ...
            fullfile(pwd, 'ExamsQuizzes_4.txt'), ...
            'init', init0, ...
            'nChains', nchains, ...
            'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
            'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
            'monitorParams', {'pz','qz','alpha','beta','k'}, ...
            'Bugdir', 'C:/Program Files/WinBUGS14');
end;



