% Convergence 
clear;

% load data
load ConjunctionData;
x = ConjunctionData; 

%create data
%Reshape to matrix and transpose
PA = reshape(x(:,1),90,33)'; 
%Remove 30th participant
PA(30,:) = [];
PB = reshape(x(:,2),90,33)'; 
PB(30,:) = [];
PAB = reshape(x(:,3),90,33)'; 
PAB(30,:) = [];

% defines the number of items and number of participants
nsubj = length(PA(:,1));
nitem = length(PA(1,:));

% WinBUGS Parameters
nchains=3; % How Many Chains?
nburnin=1000; % How Many Burn-in Samples?
nsamples=4000; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('PA',PA,'PB',PB,'PAB',PAB,'nitem', nitem, 'nsubj',nsubj);

%vector of starting values for muphi
muphi = [-0.6,0,0.6];

% Initialize Unobserved Variables
for i=1:nchains
    S.betaphi = normrnd(0,1,1,nsubj);
    S.muphi = muphi(i);
    S.sigmaphi = 0.2;
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'ConjunctionModel.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'beta','muphi','mu','sigmaphi'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');




