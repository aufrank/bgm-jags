% Summarizing a Distributions

clear;

% Data 
k=1;n=2;

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=1e4; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('k',k,'n',n);

% Initialize Unobserved Variables
for i=1:nchains
    S.theta = 0.5; % Intial Value
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Rate_5.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'theta','thetaprior'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
figure(1);clf;hold on;
eps=.01;bins=[eps:eps:1-eps];
count=hist(samples.thetaprior,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k--');
count=hist(samples.theta,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k-');
legend('Prior','Posterior','location','north');
set(gca,'box','on','fontsize',14);
xlabel('Rate','fontsize',16);
ylabel('Posterior Density','fontsize',16);
