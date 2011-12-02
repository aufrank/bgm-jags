% Prior and Posterior Predictive

clear;

% Data 
k=[3 1 4 5];n=10;
% Derived Variables
m=length(k);

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=0; % How Many Burn-in Samples?
nsamples=5e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('k',k,'n',n,'m',m);

% Initialize Unobserved Variables
for i=1:nchains
    S.theta = 0.5; % Intial Value
    init0(i) = S;
end

% Use WinBUGS to Sample
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Rate_4.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 1, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'theta','thetaprior','postpredk','priorpredk'}, ...
    'Bugdir', 'C:/Program Files/WinBUGS14');

% Analysis
figure(1);clf;
% Parameter Space
subplot(211);hold on;
eps=.01;bins=[eps:eps:1-eps];
count=hist(samples.thetaprior,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k--');
count=hist(samples.theta,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k-');
legend('Prior','Posterior');
set(gca,'box','on','fontsize',14);
xlabel('Rate','fontsize',16);
ylabel('Posterior Density','fontsize',16);
% Data Space
subplot(212);hold on;
kbins=[0:n];
count1=histc(samples.priorpredk,kbins);
count1=count1/sum(count1);
ph=bar(kbins,count1,.6);
set(ph,'facecolor','none','linewidth',1.5,'linestyle','--')
count2=histc(samples.postpredk,kbins);
count2=count2/sum(count2);
ph=bar(kbins,count2);set(ph,'facecolor','none')
%ph=bar(kbins,[count1;count2]');
legend('Prior','Posterior');
set(gca,'xlim',[-1 n+1],'box','on','fontsize',14);
xlabel('Success Count','fontsize',16);
ylabel('Posterior Mass','fontsize',16);