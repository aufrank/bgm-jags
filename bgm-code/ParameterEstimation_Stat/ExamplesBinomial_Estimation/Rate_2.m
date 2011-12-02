% Difference Between Two Rates

clear;

% Data (Observed Variables)
k1=5;n1=10;k2=7;n2=10

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=1e4; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('k1',k1,'n1',n1,'k2',k2,'n2',n2);

% Initialize Unobserved Variables
for i=1:nchains
    S.theta1 = 0.5; % An Intial Value for the Success Rate
    S.theta2 = 0.5; % An Intial Value for the Success Rate
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Rate_2.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'theta1','theta2','delta'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
figure(1);clf;hold on;
eps=.025;bins=[-1:eps:1];
count=hist(samples.delta,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k-');
set(gca,'box','on','fontsize',14,'xtick',[-1:.2:1]);
xlabel('Difference in Rates','fontsize',16);
ylabel('Posterior Density','fontsize',16);

% Summaries of Posterior
% MEAN
disp(sprintf('Mean is %1.2f',mean(samples.delta)));
% MODE
logL=zeros(nsamples,1);
for i=1:nsamples
	logL(i)=logL(i)+k1*log(samples.theta1(i))+(n1-k1)*log(1-samples.theta1(i));
	logL(i)=logL(i)+k2*log(samples.theta2(i))+(n2-k2)*log(1-samples.theta2(i));
end;
[val ind]=max(logL);
disp(sprintf('Mode is %1.2f',samples.delta(ind)));
% MEDIAN
disp(sprintf('Median is %1.2f',median(samples.delta)));
% CREDIBLE INTERVAL
cred=0.95;
b1=(1-cred)/2;b2=1-b1;
val=sort(samples.delta);
disp(sprintf('%d percent credible interval is [%1.2f, %1.2f]',cred*100,val(round(b1*nsamples)),val(round(b2*nsamples))));



