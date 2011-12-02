% Inferring A Rate

clear;

% Data
k=5;n=10;

% WinBUGS Parameters
nchains=2; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=2e4;  %How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('k',k,'n',n);

% Initialize Unobserved Variables
start.theta= [0.1 0.9];

for i=1:nchains
    S.theta = start.theta(i); % An Intial Value for the Success Rate
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Rate_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'theta'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
figure(1);clf;hold on;
eps=.01;bins=[eps:eps:1-eps];
count=hist(samples.theta,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k-');
set(gca,'box','on','fontsize',14);
xlabel('Rate','fontsize',16);
ylabel('Posterior Density','fontsize',16);


