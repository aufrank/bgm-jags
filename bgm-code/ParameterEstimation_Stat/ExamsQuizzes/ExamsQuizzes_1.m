% Exam Scores

clear;

% Data
k=[21 17 21 18 22 31 31 34 34 35 35 36 39 36 35];n=40;
% Number of people
p=length(k);

% Sampling Parameters
nchains=1; % number of chains
nburnin=0; % number of burn-in samples
nsamples=1e3; % number of samples

% Data to Supply to WinBugs
datastruct = struct('p',p,'k',k,'n',n);

% Initial Values to Supply to WinBugs
for i=1:nchains
    S.z = round(rand(1,p)); % Initial Random Group Assignments
    init0(i) = S;
end

[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'ExamsQuizzes_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'phi','z'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');



