%%
% first run Fig2A in Final_computational Results
clc
addpath(fullfile(matlabroot,'toolbox','curvefit','curvefit'),'-begin')

d=[0.15 0.25 0.3 0.4 0.5 0.7]; % jitter levels
bay=All_BayesVar; % bayesian uncertainty
pc=All_OscilVar; % oscillator uncertainty

nData=length(d);

ft=fittype('a+b*x'); % linear model, 2 params
fo_lin_d_bay=fit(d',bay',ft);
fo_lin_d_pc=fit(d',pc',ft);
fo_lin_bay_pc=fit(bay',pc',ft);
nParLin=2;

ft=fittype('a+b*exp(c*x)'); % exponential growth, 3 params
fo_exp_d_bay=fit(d',bay',ft, 'StartPoint', [0.05, 20 20]);

ft=fittype('a+b*exp(-c*x)'); % exponential decay, 3 params
fo_exp_d_pc=fit(d',pc',ft, 'StartPoint', [0.05, 20 20]);
fo_exp_bay_pc=fit(bay',pc',ft, 'StartPoint', [0.05, -20 20]);
nParExp=3;

% bayes ~ jitterLevel
figure('Position', [200 200 1000 500])
errLin=sum((bay-fo_lin_d_bay(d)').^2);
errExp=sum((bay-fo_exp_d_bay(d)').^2);
AIC_lin=nData*log(errLin/nData)+2*nParLin;
AIC_exp=nData*log(errExp/nData)+2*nParExp;
diffAIC=AIC_exp-AIC_lin
subplot(1,3,1); plot(d,bay, '-o'); hold all
plot(d, fo_lin_d_bay(d)', '-or')
plot(d, fo_exp_d_bay(d)', '-og')

% pc ~ jitterLevel
errLin=sum((pc-fo_lin_d_pc(d)').^2);
errExp=sum((pc-fo_exp_d_pc(d)').^2);
AIC_lin=nData*log(errLin/nData)+2*nParLin;
AIC_exp=nData*log(errExp/nData)+2*nParExp;
diffAIC=AIC_exp-AIC_lin
subplot(1,3,2); plot(d,pc, '-o'); hold all
plot(d, fo_lin_d_pc(d)', '-or')
plot(d, fo_exp_d_pc(d)', '-og')

% pc ~ bayes
errLin=sum((pc-fo_lin_bay_pc(bay)').^2)
errExp=sum((pc-fo_exp_bay_pc(bay)').^2)
AIC_lin=nData*log(errLin/nData)+2*nParLin;
AIC_exp=nData*log(errExp/nData)+2*nParExp;
diffAIC=AIC_exp-AIC_lin
subplot(1,3,3); plot(bay,pc, '-o'); hold all
plot(bay, fo_lin_bay_pc(bay)', '-or')
plot(bay, fo_exp_bay_pc(bay)', '-og')

%% direct model comparison for increased fit from exponent term

ft=fittype('a+b*exp(-c*x)+d*x'); % exponential decay + linear, 4 params
fo_both_d_pc=fit(bay',pc',ft, 'StartPoint', [0.05, 20 20, -1]);
nParFull=4;

errLin=sum((pc-fo_lin_bay_pc(bay)').^2);
errFull=sum((pc-fo_both_d_pc(bay)').^2);
AIC_lin=nData*log(errLin/nData)+2*nParLin;
AIC_full=nData*log(errFull/nData)+2*nParFull;
diffAIC=AIC_full-AIC_lin

figure; plot(bay,pc, '-ob'); hold all
plot(bay, fo_lin_bay_pc(bay)', '-or')
plot(bay, fo_both_d_pc(bay)', '-og')



%% isochronous

d=[11 9 7 5]; % length
bay=All_BayesVar_iso; % bayesian uncertainty
pc=All_OscilVar_iso; % oscillator uncertainty

nData=length(d);

ft=fittype('a+b*x'); % linear model, 2 params
fo_lin_d_bay=fit(d',bay',ft);
fo_lin_d_pc=fit(d',pc',ft);
fo_lin_bay_pc=fit(bay',pc',ft);
nParLin=2;

ft=fittype('a+b*exp(c*x)'); % exponential growth, 3 params
fo_exp_d_bay=fit(d',bay',ft, 'StartPoint', [0.1, 10 10]);

ft=fittype('a+b*exp(-c*x)'); % exponential decay, 3 params
fo_exp_d_pc=fit(d',pc',ft, 'StartPoint', [0.1, 10 10]);
fo_exp_bay_pc=fit(bay',pc',ft, 'StartPoint', [0.1, 5 5]);
nParExp=3;

% bayes ~ jitterLevel
figure('Position', [200 200 1000 500])
errLin=sum((bay-fo_lin_d_bay(d)').^2);
errExp=sum((bay-fo_exp_d_bay(d)').^2);
AIC_lin=nData*log(errLin/nData)+2*nParLin;
AIC_exp=nData*log(errExp/nData)+2*nParExp;
diffAIC=AIC_exp-AIC_lin
subplot(1,3,1); plot(d,bay, '-o'); hold all
plot(d, fo_lin_d_bay(d)', '-or')
plot(d, fo_exp_d_bay(d)', '-og')

% pc ~ jitterLevel
errLin=sum((pc-fo_lin_d_pc(d)').^2);
errExp=sum((pc-fo_exp_d_pc(d)').^2);
AIC_lin=nData*log(errLin/nData)+2*nParLin;
AIC_exp=nData*log(errExp/nData)+2*nParExp;
diffAIC=AIC_exp-AIC_lin
subplot(1,3,2); plot(d,pc, '-o'); hold all
plot(d, fo_lin_d_pc(d)', '-or')
plot(d, fo_exp_d_pc(d)', '-og')

% pc ~ bayes
errLin=sum((pc-fo_lin_bay_pc(bay)').^2)
errExp=sum((pc-fo_exp_bay_pc(bay)').^2)
AIC_lin=nData*log(errLin/nData)+2*nParLin;
AIC_exp=nData*log(errExp/nData)+2*nParExp;
diffAIC=AIC_exp-AIC_lin
subplot(1,3,3); plot(bay,pc, '-o'); hold all
plot(bay, fo_lin_bay_pc(bay)', '-or')
plot(bay, fo_exp_bay_pc(bay)', '-og')

%% direct model comparison for increased fit from exponent term

ft=fittype('a+b*exp(-c*x)+d*x'); % exponential decay + linear, 4 params
fo_both_d_pc=fit(bay',pc',ft, 'StartPoint', [0.1, 5 5, -1]);
nParFull=4;

errLin=sum((pc-fo_lin_bay_pc(bay)').^2);
errFull=sum((pc-fo_both_d_pc(bay)').^2);
AIC_lin=nData*log(errLin/nData)+2*nParLin;
AIC_full=nData*log(errFull/nData)+2*nParFull;
diffAIC=AIC_full-AIC_lin

figure; plot(bay,pc, '-o'); hold all
plot(bay, fo_lin_bay_pc(bay)', '-or')
plot(bay, fo_both_d_pc(bay)', '-og')


