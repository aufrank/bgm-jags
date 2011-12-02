% Multidimensional Scaling In Euclidean Space

clear;

% Load data
load helm_ind; s=sind;s=s/max(s(:));s=1-s;s=s(:,:,[7:10 15:16 1:6 11:14]);nsubj=16;
% Labels
shortlabs=char('rp','ro','y','gy1','gy2','g','b','pb','p2','p1');
% Set Metric
r=1.8;

% WinBUGS Parameters
nchains=1; % How Many Chains?
nburnin=1e2; % How Many Burn-in Samples?
nsamples=1e3; % How Many Recorded Samples?

% Assign Matlab Variables to the Observed WinBUGS Nodes
datastruct = struct('s',s,'NSTIM',n,'NSUBJ',nsubj,'r',r);

% Initialize Unobserved Variables
for i=1:nchains
	S.z01 = round(rand(nsubj-10,1));
    S.pt = zeros(n,2,2);
    S.sigma = 0.001;
    init0(i) = S;
end;

% Use WinBUGS to Sample
        [samples, stats, structarray] = matbugs(datastruct, ...
            fullfile(pwd, 'MultidimensionalScaling_2.txt'), ...
            'init', init0, ...
            'nChains', nchains, ...
            'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
            'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
            'monitorParams', {'p','z','sigma'}, ...
            'Bugdir', 'C:/Program Files/WinBUGS14');

% Posterior Assignments
disp('Posterior Means of z');
disp(squeeze(mean(samples.z)));
% Plot Posterior Distribution of Points
figure(1);clf;
for g=1:2
	subplot(1,2,g);hold on;
% Some Posterior Points
p=squeeze(samples.p(:,:,:,:,g));
howmany=50;
tmp=randperm(nsamples);
keep=tmp(1:howmany);
for i=1:n
    ph=plot(p(keep,i,1),p(keep,i,2),'k.');
end;
% Labels
x=squeeze(mean(p));
sc=1.5;
for i=1:n
    [theta r]=cart2pol(x(i,1),x(i,2));
    [tx ty]=pol2cart(theta,sc*r);
    th=text(tx,ty,deblank(shortlabs(i,:)));
    set(th,'vert','mid','hor','cen','fontsize',12);
end;
axis([-1 1 -1 1]);
axis square;
set(gca,'xtick',[],'ytick',[],'box','on');
end;