%% Block design

%%isochronous -> ID = 0
% 1. mean (1) %here only rate
% 2. length (1=11 , 2=9, 3=7, 4=5)
% 3. shuffle ID (1 = iso)
% 4. targets ( 1= early, 2= on beat, 3= late, 5= catch)

% blockConds0 = {[1] [1 2 3 4] [1] [1 2 2 2 3 5]}; %factor levels
% [BlockTrialList_0,BlockLength_0]=createTrialList(blockConds0);


%%sd 25% -> ID = 1
% 1. mean (1) %here only one rate
% 2. length (1= short, 2= long)-> now (1=5 , 2=7, 3=9, 4=11)
% 3. shuffle ID (1 = first , 2= second, 3 = third) choose from the list of actual IDs
% 4. targets ( 1= oscil, 2= median, 3= bayes, 4= hazard , 5 =catch)
% blockConds1 = {[1] [1 2 3 4] [1] [1 1 2 2 3 3 4 4 5]}; %factor levels ->1/9 catch
% [BlockTrialList_1,BlockLength_1]=createTrialList(blockConds1);


%%sd 50% -> ID = 2
% 1. mean (1) %here only one rate
% 2. length (1= short , 2= long)-> now (1=5 , 2=7, 3=9, 4=11)
% 3. shuffle ID (1 = first , 2= second, 3 = third) choose from the list of actual IDs
% 4. targets ( 1= oscil, 2= bayes, 3= hazard , 5=catch)

% blockConds2 = {[1] [1 2 3 4] [1] [1 1 2 2 3 3 5]}; %factor levels -> 1/7 catch
% [BlockTrialList_2,BlockLength_2]=createTrialList(blockConds2);


%% results 

clear all
clc

folderPath = '...\Project 1\Experiment 1\Behavioral data'; %put folder path to data

% Get a list of all files in the folder
fileList = dir(fullfile(folderPath, '*.mat'));
rejectedsubj= [];
fileList([rejectedsubj]) = [];

outlierCrit=2.5;
minAcceptedRT=0.1; %in seconds
maxAcceptedRT=1;
rejectOutliers=2; %0=no, 1=across conditions, 2=within condition 
% logTransform=0;

%length analysis choose
is = [1, 2, 3, 4]; % iso taget code (length 11, 9,7,5)
% is = [4]; %choose one length to look at
nis = [1, 2, 3 , 4]; %non iso target code
% nis = [4]; %chosse one length to look at


% Loop through each file in the folder
for f = 1:length(fileList)
    filePath = fullfile(folderPath, fileList(f).name);
    load(filePath);

            allblockstriallist  =[];
            for i = 1:length(all_shuffled_blocks)
                allblockstriallist = [allblockstriallist; all_shuffled_blocks{i}{:}];
            end
            
            blockorder = [];
            RTorder = [];
            RespCond = [];
            for n = 1:size(experimentResults, 1)
                blockorder = [blockorder ; experimentResults{n,2}];
                RTorder = [RTorder; experimentResults{n,7}];
                RespCond = [RespCond; experimentResults{n,6}];
            end
             Finalblockstriallist = [blockorder, allblockstriallist, RTorder, RespCond];
             

            %blockIso RTs
            EarlyRT1 =[];
            onbeatRT1 =[];
            lateRT1 = [];
            
            %block25 RTs
            OscilRT2 =[];
            midRT2 = [];
            BayesRT2 =[];
            HazardRT2 =[];
            
            %block50 RTs
            OscilRT3 =[];
            midRT3 = [];
            BayesRT3 =[];
            HazardRT3 =[];
            
            
            for t = 1:size(Finalblockstriallist, 1)
            if Finalblockstriallist(t, 7) >= 0 && Finalblockstriallist(t, 6)> minAcceptedRT && Finalblockstriallist(t, 6)< maxAcceptedRT
                if Finalblockstriallist(t,1) == 1
                    if Finalblockstriallist(t,5) == 1 && any(Finalblockstriallist(t,3) == is)
                       EarlyRT1 = [EarlyRT1 ; Finalblockstriallist(t,6)];
                    elseif Finalblockstriallist(t,5) == 2 && any(Finalblockstriallist(t,3) == is)
                           onbeatRT1 = [onbeatRT1 ; Finalblockstriallist(t,6)];
                    elseif Finalblockstriallist(t,5) == 3 && any(Finalblockstriallist(t,3) == is)
                           lateRT1 = [lateRT1 ; Finalblockstriallist(t,6)];
                    end
            
                elseif Finalblockstriallist(t,1) == 2
                        if Finalblockstriallist(t,5) == 1 && any(Finalblockstriallist(t,3) == nis)
                           OscilRT2 = [OscilRT2 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 2 && any(Finalblockstriallist(t,3) == nis)
                               midRT2 = [midRT2 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 3 && any(Finalblockstriallist(t,3) == nis)
                               BayesRT2 = [BayesRT2 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 4 && any(Finalblockstriallist(t,3) == nis)
                               HazardRT2 = [HazardRT2 ; Finalblockstriallist(t,6)];
                        end
            
            
                elseif Finalblockstriallist(t,1) == 3
                        if Finalblockstriallist(t,5) == 1 && any(Finalblockstriallist(t,3) == nis)
                           OscilRT3 = [OscilRT3 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 2 && any(Finalblockstriallist(t,3) == nis)
                               midRT3 = [midRT3 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 3 && any(Finalblockstriallist(t,3) == nis)
                               BayesRT3 = [BayesRT3 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 4 && any(Finalblockstriallist(t,3) == nis)
                               HazardRT3 = [HazardRT3 ; Finalblockstriallist(t,6)];
                        end
            
            
            
                end
            end
            end

            % Outlier rejection

             if rejectOutliers==2 % outlier rejection within condition
                ZS_EarlyRT1=zscore(EarlyRT1);
                EarlyRT1=EarlyRT1(abs(ZS_EarlyRT1)<outlierCrit);

                ZS_onbeatRT1=zscore(onbeatRT1);
                onbeatRT1=onbeatRT1(abs(ZS_onbeatRT1)<outlierCrit);

                ZS_lateRT1=zscore(lateRT1);
                lateRT1=lateRT1(abs(ZS_lateRT1)<outlierCrit);

                ZS_OscilRT2=zscore(OscilRT2);
                OscilRT2=OscilRT2(abs(ZS_OscilRT2)<outlierCrit);

                ZS_midRT2=zscore(midRT2);
                midRT2=midRT2(abs(ZS_midRT2)<outlierCrit);

                ZS_BayesRT2=zscore(BayesRT2);
                BayesRT2=BayesRT2(abs(ZS_BayesRT2)<outlierCrit);

                ZS_HazardRT2=zscore(HazardRT2);
                HazardRT2=HazardRT2(abs(ZS_HazardRT2)<outlierCrit);

                ZS_OscilRT3=zscore(OscilRT3);
                OscilRT3=OscilRT3(abs(ZS_OscilRT3)<outlierCrit);

                ZS_midRT3=zscore(midRT3);
                midRT3=midRT3(abs(ZS_midRT3)<outlierCrit);

                ZS_BayesRT3=zscore(BayesRT3);
                BayesRT3=BayesRT3(abs(ZS_BayesRT3)<outlierCrit);

                ZS_HazardRT3=zscore(HazardRT3);
                HazardRT3=HazardRT3(abs(ZS_HazardRT3)<outlierCrit);


             end

            

            %iso
            all_Mu_EarlyRT1(f) =nanmean(EarlyRT1);
            all_Mu_onbeatRT1(f) =nanmean(onbeatRT1);
            all_Mu_lateRT1(f) = nanmean(lateRT1);

            %25 SD
            all_Mu_OscilRT2(f) =nanmean(OscilRT2);
            all_Mu_midRT2(f) = nanmean(midRT2);
            all_Mu_BayesRT2(f) =nanmean(BayesRT2);
            all_Mu_HazardRT2(f) =nanmean(HazardRT2) ;

            %50 SD
            all_Mu_OscilRT3(f) =nanmean(OscilRT3);
            all_Mu_midRT3(f) = nanmean(midRT3);
            all_Mu_BayesRT3(f) =nanmean(BayesRT3);
            all_Mu_HazardRT3(f) =nanmean(HazardRT3);


end

% iso
Mu_EarlyRT1 =nanmean(all_Mu_EarlyRT1);
Mu_onbeatRT1 =nanmean(all_Mu_onbeatRT1);
Mu_lateRT1 = nanmean(all_Mu_lateRT1);

%25 SD
Mu_OscilRT2 =nanmean(all_Mu_OscilRT2);
Mu_midRT2 = nanmean(all_Mu_midRT2);
Mu_BayesRT2 =nanmean(all_Mu_BayesRT2);
Mu_HazardRT2 =nanmean(all_Mu_HazardRT2) ;

%50 SD
Mu_OscilRT3 =nanmean(all_Mu_OscilRT3);
Mu_midRT3 = nanmean(all_Mu_midRT3);
Mu_BayesRT3 =nanmean(all_Mu_BayesRT3);
Mu_HazardRT3 =nanmean(all_Mu_HazardRT3);





% iso
ste_Mu_EarlyRT1 =nanstd(all_Mu_EarlyRT1)./ sqrt(length(all_Mu_EarlyRT1));
ste_Mu_onbeatRT1 =nanstd(all_Mu_onbeatRT1)./ sqrt(length(all_Mu_onbeatRT1));
ste_Mu_lateRT1 = nanstd(all_Mu_lateRT1)./ sqrt(length(all_Mu_lateRT1));

%25 SD
ste_Mu_OscilRT2 =nanstd(all_Mu_OscilRT2)./ sqrt(length(all_Mu_OscilRT2));
ste_Mu_midRT2 = nanstd(all_Mu_midRT2)./ sqrt(length(all_Mu_midRT2));
ste_Mu_BayesRT2 =nanstd(all_Mu_BayesRT2)./ sqrt(length(all_Mu_BayesRT2));
ste_Mu_HazardRT2 =nanstd(all_Mu_HazardRT2)./ sqrt(length(all_Mu_HazardRT2));

%50 SD
ste_Mu_OscilRT3 =nanstd(all_Mu_OscilRT3)./ sqrt(length(all_Mu_OscilRT3));
ste_Mu_midRT3 = nanstd(all_Mu_midRT3)./ sqrt(length(all_Mu_midRT3));
ste_Mu_BayesRT3 =nanstd(all_Mu_BayesRT3)./ sqrt(length(all_Mu_BayesRT3));
ste_Mu_HazardRT3 =nanstd(all_Mu_HazardRT3)./ sqrt(length(all_Mu_HazardRT3));

%% Main Figure - average
ystep = 0.05;
ylimits = [0.24 0.32];
figure()

%Jittered 
%block2 RTs
            
subplot(1,2,1)
errorbar([1, 2, 3, 4], [Mu_OscilRT2, Mu_midRT2, Mu_BayesRT2, Mu_HazardRT2], [-ste_Mu_OscilRT2, -ste_Mu_midRT2, -ste_Mu_BayesRT2, -ste_Mu_HazardRT2], ...
    [ste_Mu_OscilRT2, ste_Mu_midRT2, ste_Mu_BayesRT2, ste_Mu_HazardRT2], 'LineWidth', 1, 'CapSize', 4 , Color =[0.5 0.5 0.5]);
hold on
plot([1, 2, 3, 4], [Mu_OscilRT2, Mu_midRT2, Mu_BayesRT2, Mu_HazardRT2], 'b', 'LineWidth', 2)

hold on
errorbar([1, 2, 3, 4], [Mu_OscilRT3, Mu_midRT3, Mu_BayesRT3, Mu_HazardRT3], [-ste_Mu_OscilRT3, -ste_Mu_midRT3, -ste_Mu_BayesRT3, -ste_Mu_HazardRT3], ...
    [ste_Mu_OscilRT3, ste_Mu_midRT3, ste_Mu_BayesRT3, ste_Mu_HazardRT3], 'LineWidth', 1, 'CapSize', 4 , Color =[0.5 0.5 0.5]);
hold on
plot([1, 2, 3, 4], [Mu_OscilRT3, Mu_midRT3, Mu_BayesRT3, Mu_HazardRT3],'r',  'LineWidth', 2)

title('Jittered')
xticks([1 2 3 4])
xticklabels({'Oscillator', 'Mid point', 'Bayesian', 'Hazard'})
ymin = min(get (gca, 'YLim'));
ymax = max(get (gca, 'YLim'));
ymean = (ymin+ymax)./2;

ylim(ylimits)

xlim([0.5 4.5])
ylabel ('Rt(s)')
set(gca,'FontWeight','bold')
axis square
legend('', '25% jitter', ...
    '', '50% jitter')

%Iso

subplot(1,2,2)
errorbar([1, 2, 3] , [Mu_EarlyRT1, Mu_onbeatRT1, Mu_lateRT1], [-ste_Mu_EarlyRT1, -ste_Mu_onbeatRT1, -ste_Mu_lateRT1], ...
    [ste_Mu_EarlyRT1, ste_Mu_onbeatRT1, ste_Mu_lateRT1], 'LineWidth', 1, 'CapSize', 4 , Color =[0.5 0.5 0.5]);
hold on
plot([1, 2, 3] , [Mu_EarlyRT1, Mu_onbeatRT1, Mu_lateRT1],'k', 'LineWidth', 2)

title('Isochronous')
xticks([1 2 3])
xticklabels({'early', 'onbeat', 'late'})
ymin = min(get (gca, 'YLim'));
ymax = max(get (gca, 'YLim'));
ymean = (ymin+ymax)./2;
ylim(ylimits)
ylabel ('Rt(s)')
xlim([0.5 3.5])
set(gca,'FontWeight','bold')
axis square

%% all participants Difference 25-50
ylimits = [-0.08 0.04];
figure()
subplot(1,2,1)
for s = 1 : length (all_Mu_EarlyRT1)
scatter([1 2 3 4] , [all_Mu_OscilRT2(s)-all_Mu_OscilRT3(s), all_Mu_midRT2(s)- all_Mu_midRT3(s), all_Mu_BayesRT2(s)-all_Mu_BayesRT3(s), all_Mu_HazardRT2(s)- all_Mu_HazardRT3(s)], 'MarkerFaceColor', 'k', 'MarkerFaceAlpha',0.2, 'MarkerEdgeColor','none')
hold on 
end
plot([1, 2, 3, 4], [mean(all_Mu_OscilRT2-all_Mu_OscilRT3), mean(all_Mu_midRT2- all_Mu_midRT3), mean(all_Mu_BayesRT2-all_Mu_BayesRT3), mean(all_Mu_HazardRT2- all_Mu_HazardRT3)], 'k', 'LineWidth', 1.5)
hold on
yline(0, 'LineStyle','--', 'LineWidth',1)

title('Condition Diff (25% - 50%)')
xticks([1 2 3 4])
xticklabels({'Oscillator', 'Mid point', 'Bayesian', 'Hazard'})
ylim(ylimits)
xlim([0.5 4.5])
ylabel ('\Delta Rt(s)')
set(gca,'FontWeight','bold')
axis square

subplot(1,2,2)
for s = 1 : length (all_Mu_EarlyRT1)
scatter([1 2 3] , [all_Mu_EarlyRT1(s), all_Mu_onbeatRT1(s), all_Mu_lateRT1(s)], 'MarkerFaceColor', 'k', 'MarkerFaceAlpha',0.2, 'MarkerEdgeColor','none')
hold on
plot([1, 2, 3] , [Mu_EarlyRT1, Mu_onbeatRT1, Mu_lateRT1],'k', 'LineWidth', 1.5)
hold on
end

title('')
xticks([1 2 3])
xticklabels({'early', 'onbeat', 'late'})


ylabel ('Rt(s)')
xlim([0.5 3.5])
set(gca,'FontWeight','bold')
axis square


%% statistics

% Anova 2 * 4
% columns: 25-oscil, 25mid, 25-bayes, 25-hazard, 50oscil, 50mid, 50,bayes, 50hazard 
% rows : subjects
Anova_Matrix = [all_Mu_OscilRT2; all_Mu_midRT2; all_Mu_BayesRT2; all_Mu_HazardRT2; ...
    all_Mu_OscilRT3; all_Mu_midRT3; all_Mu_BayesRT3; all_Mu_HazardRT3];

[fValues, dfValues, pValues]=repeated2WayANOVA(Anova_Matrix', 2, 4)

%effetc sizes
eta_A  = (fValues.A  * dfValues.A(1))  / (fValues.A  * dfValues.A(1)  + dfValues.A(2))
eta_B  = (fValues.B  * dfValues.B(1))  / (fValues.B  * dfValues.B(1)  + dfValues.B(2))
eta_AB = (fValues.AB * dfValues.AB(1)) / (fValues.AB * dfValues.AB(1) + dfValues.AB(2))


%t-tests

%jitter
[~,p,~,stats]=ttest(all_Mu_OscilRT2-all_Mu_HazardRT2-(all_Mu_OscilRT3-all_Mu_HazardRT3))% oscil 25% vs 50% (compared to hazard)
cohen_d = stats.tstat / sqrt(stats.df + 1)

[~,p,~,stats]=ttest(all_Mu_OscilRT2-all_Mu_OscilRT3)% oscil 25% vs 50% (no hazard)
cohen_d = stats.tstat / sqrt(stats.df + 1)

[~,p,~,stats]=ttest((all_Mu_BayesRT2-all_Mu_HazardRT2)-(all_Mu_BayesRT3-all_Mu_HazardRT3))% bayes 25% vs 50% (compared to hazard)
cohen_d = stats.tstat / sqrt(stats.df + 1)

[~,p,~,stats]=ttest(all_Mu_BayesRT2-all_Mu_BayesRT3)% bayes 25% vs 50% (WO control for Hazard)
cohen_d = stats.tstat / sqrt(stats.df + 1)



%iso
[~,p,~,stats]=ttest(all_Mu_onbeatRT1-0.5*(all_Mu_EarlyRT1+all_Mu_lateRT1)) %isochronous on-beat vs off-beat
cohen_d = stats.tstat / sqrt(stats.df + 1)

[~,p,~,stats]=ttest(all_Mu_onbeatRT1-all_Mu_EarlyRT1) %isochronous on-beat vs early
cohen_d = stats.tstat / sqrt(stats.df + 1)




% Anova 2 * 2 -> Oscil, Bayes with hazard correction
% columns: 25-oscil, 25bayes, 50oscil, 50bayes
% rows : subjects
Anova_Matrix = [all_Mu_OscilRT2-all_Mu_HazardRT2; all_Mu_BayesRT2-all_Mu_HazardRT2; ...
    all_Mu_OscilRT3-all_Mu_HazardRT3; all_Mu_BayesRT3-all_Mu_HazardRT3];

[fValues, dfValues, pValues]=repeated2WayANOVA(Anova_Matrix', 2, 2)
%effetc sizes
eta_A  = (fValues.A  * dfValues.A(1))  / (fValues.A  * dfValues.A(1)  + dfValues.A(2))
eta_B  = (fValues.B  * dfValues.B(1))  / (fValues.B  * dfValues.B(1)  + dfValues.B(2))
eta_AB = (fValues.AB * dfValues.AB(1)) / (fValues.AB * dfValues.AB(1) + dfValues.AB(2))


