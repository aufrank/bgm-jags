% Take The Best With Known Search Order

clear;

% Load Data
 load citworld; % German cities and their populations (83 objects and 9 cues)
%load prfworld; % Professors and their salaries (51 objects and 5 cues)

% Number of Cities and Cues
c=cues;
[n nc]=size(cues);

% Order cue validities (worst to best)
[val ind]=sort(v);
vo=zeros(1,nc);
for i=1:nc
    vo(i)=find(ind==i);
end;

% Correct decisions for all possible questions
cc=1;
for i=1:n-1
    for j=i+1:n
        % Record two object in cc-th question
        p(cc,1)=i;
        p(cc,2)=j;
        % Record correct answer (1=first object; 0=second)
        k(cc)=(pop(i)>pop(j));
        cc=cc+1;
    end;
end;
% Total number of questions
nq=cc-1;

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=1e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('c',c,'p',p,'k',k,'nc',nc,'vo',vo,'nq',nq);

% Initialize Unobserved Variables
for i=1:nchains
    S.gamma = 0.5;
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'TakeTheBest_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'gamma','sc'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');