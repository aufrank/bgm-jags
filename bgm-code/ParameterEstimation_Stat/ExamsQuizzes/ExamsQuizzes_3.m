% Twenty Questions

clear;

% Choose The Dataset
dset=2;

% Data
switch dset
  case 1,k=[1 1 1 1 0 0 1 1 0 1 0 0 1 0 0 1 0 1 0 0
   0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
   0 0 1 0 0 0 1 1 0 0 0 0 1 0 0 0 0 0 0 0
   0 0 0 0 0 0 1 0 1 1 0 0 0 0 0 0 0 0 0 0
   1 0 1 1 0 1 1 1 0 1 0 0 1 0 0 0 0 1 0 0
   1 1 0 1 0 0 0 1 0 1 0 1 1 0 0 1 0 1 0 0
   0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0
   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
   0 1 1 0 0 0 0 1 0 1 0 0 1 0 0 0 0 1 0 1
   1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0];
 case 2,k=[1 1 1 1 0 0 1 1 0 1 0 0 nan 0 0 1 0 1 0 0
   0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
   0 0 1 0 0 0 1 1 0 0 0 0 1 0 0 0 0 0 0 0
   0 0 0 0 0 0 1 0 1 1 0 0 0 0 0 0 0 0 0 0
   1 0 1 1 0 1 1 1 0 1 0 0 1 0 0 0 0 1 0 0
   1 1 0 1 0 0 0 1 0 1 0 1 1 0 0 1 0 1 0 0
   0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0
   0 0 0 0 nan 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
   0 1 1 0 0 0 0 1 0 1 0 0 1 0 0 0 0 1 0 1
   1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 0 0 nan 0 0];
end;
% Number of people and questions
[np nq] = size(k);

% Sampling Parameters
nchains=1; % number of chains
nburnin=0; % number of burn-in samples
nsamples=1e4; % number of samples

% Data to Supply to WinBugs
datastruct = struct('np',np,'nq',nq,'k',k);

% Initial Values to Supply to WinBugs
for i=1:nchains
 S.p = rand(1,np);
 S.q = rand(1,nq);
 init0(i) = S;
end

switch dset
 case 1, [samples, stats] = matbugs(datastruct, ...
 fullfile(pwd, 'ExamsQuizzes_3.txt'), ...
 'init', init0, ...
 'nChains', nchains, ...
 'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
 'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
 'monitorParams', {'p','q'}, ...
 'Bugdir', 'C:/Program Files/WinBUGS14');
 case 2, [samples, stats] = matbugs(datastruct, ...
 fullfile(pwd, 'ExamsQuizzes_3.txt'), ...
 'init', init0, ...
 'nChains', nchains, ...
 'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
 'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
 'monitorParams', {'p','q','k'}, ...
 'Bugdir', 'C:/Program Files/WinBUGS14');
end;



