% tTest 
clear;

% read data Dr. Smith
Winter = [-0.05 0.41 0.17 -0.13 0.00 -0.05 0.00 0.17 0.29 0.04 0.21 0.08 0.37 0.17 0.08 -0.04 -0.04 0.04 -0.13 -0.12 0.04 0.21 0.17 0.17 0.17 0.33 0.04 0.04 0.04 0.00 0.21 0.13 0.25 -0.05 0.29 0.42 -0.05 0.12 0.04 0.25 0.12];
Summer = [0.00 0.38 -0.12 0.12 0.25 0.12 0.13 0.37 0.00 0.50 0.00 0.00 -0.13 -0.37 -0.25 -0.12 0.50 0.25 0.13 0.25 0.25 0.38 0.25 0.12 0.00 0.00 0.00 0.00 0.25 0.13 -0.25 -0.38 -0.13 -0.25 0.00 0.00 -0.12 0.25 0.00 0.50 0.00];

n1 = length(Winter);
n2 = length(Summer);

group2 = Summer;
group1 = Winter;

%Rescale
group2 = group2-mean(group1);
group2 = group2/std(group1);
group1 = (group1-mean(group1))/std(group1); 

% WinBUGS Parameters
nchains=3; % How Many Chains?
nburnin=1000; % How Many Burn-in Samples?
nsamples=10000; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('group1',group1,'group2', group2, 'n1', n1, 'n2',n2);


% Initialize Unobserved Variables
for i=1:nchains
    S.delta = normrnd(0,1,1);
    S.mu = normrnd(0,1,1);
    S.sigma = unifrnd(0,5,1,1);
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Ttest_2.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'delta'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');


% Plot Posterior
figure(1);clf;hold on;
eps=.01;bins=[-3:eps:3-eps];
count=hist(samples.delta,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k-');
set(gca,'box','on','fontsize',14);
xlabel('Delta','fontsize',16);
ylabel('Posterior Density','fontsize',16);

% Plot Prior: we have not yet implemented the code to plot the prior. If
% you want to inspect it, change the model file so that WinBUGS can sample
% from the prior.
