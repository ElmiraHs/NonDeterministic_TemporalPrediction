%% Block design
% % create block structure
% blocks = [2, 3, 2, 3, 2, 3, 2, 3]; 
% 
% % create design matrix
% 
% %%sd 25% 
% % 1. mean (1 = fast(600), 2 = slow(1000))
% % 2. length (1= long(11))
% % 3. shuffle ID (1 = first , 2= second) choose from the list of actual IDs
% % 4. targets ( 1= oscil, 2= median, 3= bayes, 4= hazard , 5 =catch)
% blockConds1 = {[1 2] [1] [1 2] [1 2 3 4 5 5]}; %24 trials (+9 fillers)
% [BlockTrialList_1,BlockLength_1]=createTrialList(blockConds1);
% 
% 
% %%sd 50%
% % 1. mean (1 = fast, 2 = slow)
% % 2. length (1= long(11))
% % 3. shuffle ID (1 = first , 2= second) choose from the list of actual IDs
% % 4. targets ( 1= oscil, 2= median, 3= bayes, 4= hazard , 5 =catch)
% 
% blockConds2 = {[1 2] [1] [1 2] [1 2 3 4 5 5]};
% [BlockTrialList_2,BlockLength_2]=createTrialList(blockConds2);
% 
% 
% % filler trials length= (13, 7, 5)
% blockConds_filler = {[1 2] [2 3 4] [1 1 1] [1 2 3 4]}; %72 trials
% [BlockTrialList_filler,BlockLength_filler]=createTrialList(blockConds_filler);
% 
% %add filler trials
% splitsize = floor(BlockLength_filler/length(blocks));
% shuff_fillertrial= BlockTrialList_filler(randperm(BlockLength_filler), :);
% m = splitsize*(length(blocks));
% c = reshape(shuff_fillertrial(1:m,:)', [], splitsize, length(blocks));
% shuff_fillertrial = permute(c, [2,1,3]);
% 
% % max number of consecutives
% maxRepAnyTarCond=[3, 3, 3, 3]; 
% maxRepBayesTarCond = 4;
% maxRepAnyRateCond=[4, 4, 4, 4];
% maxRepAnyLenCond=[3, 3, 3, 3];
% maxRepAnyShufCond=[3, 3, 3, 3];

%% results all subjects
clearvars -except oscil2_rate1 oscil3_rate1 oscil2_rate2 oscil3_rate2
folderPath = '...\Project 1\Experiment 2\Behavioral data';%path to subject data

% Get a list of all files in the folder
fileList = dir(fullfile(folderPath, '*.mat'));
rejectedsubj= []; %input the number of subject 2, 3
fileList([rejectedsubj]) = [];

outlierCrit=2.5;
minAcceptedRT=0.1; %in seconds
maxAcceptedRT=1;
rejectOutliers=2; %0=no, 1=across conditions, 2=within condition 
logTransform=0;

%length analysis choose
nis_all = [1]; %long
nis = [1];

%rate analysis choose
r1 = [1, 2]; % rate index for fast and slow respectively
r2 = [2]; % input here either both numbers or choose the rate specific number

%shuffle analysis choose
s1 = [1, 2];
s2 = [1, 2]; %both shuffles


% Loop through each file in the folder
for f = 1:length(fileList)
    % Construct the full file path
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
            
            
            allblockstriallist_new = [];
            blockorder_new = [];
            RTorder_new = [];
            RespCond_new = [];
            for l = 1:size(allblockstriallist, 1) %take out filler trials
                if any(allblockstriallist(l,2)==nis_all)
                   allblockstriallist_new = [allblockstriallist_new; allblockstriallist(l,:)];
                end

             end
             if size(allblockstriallist, 1) == size(experimentResults,1)
                for l = 1:size(allblockstriallist, 1) %take out filler trials
                    if any(allblockstriallist(l,2)==nis_all)
                       blockorder_new = [blockorder_new; blockorder(l)];
                       RTorder_new = [RTorder_new; RTorder(l)];
                       RespCond_new = [RespCond_new; RespCond(l)];
                    end
                end
             else

                   blockorder_new = blockorder;
                   RTorder_new = RTorder;
                   RespCond_new = RespCond;
                
             end
           
            Finalblockstriallist = [blockorder_new, allblockstriallist_new, RTorder_new, RespCond_new];

             % Finalblockstriallist columns are: block number(1), meanfreq(2), length(3), stream type(4), target type(5), RT(6), hasTarget(7)
            
            
            %block2 RTs
            OscilRT2 =[];
            midRT2 = [];
            BayesRT2 =[];
            HazardRT2 =[];
            
            %block3 RTs
            OscilRT3 =[];
            midRT3 = [];
            BayesRT3 =[];
            HazardRT3 =[];
            
            
            for t = 1:size(Finalblockstriallist, 1)
            if Finalblockstriallist(t, 7) >= 0 && Finalblockstriallist(t, 6)> minAcceptedRT && Finalblockstriallist(t, 6)< maxAcceptedRT && ~isnan (Finalblockstriallist(t, 6))

            
                if Finalblockstriallist(t,1) == 2 && any(Finalblockstriallist(t,2) == r2) &&...
                        any(Finalblockstriallist(t,3) == nis) && any(Finalblockstriallist(t,4) == s2)
                        if Finalblockstriallist(t,5) == 1 
                           OscilRT2 = [OscilRT2 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 2 
                               midRT2 = [midRT2 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 3 
                               BayesRT2 = [BayesRT2 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 4 
                               HazardRT2 = [HazardRT2 ; Finalblockstriallist(t,6)];
                        end
            
            
                elseif Finalblockstriallist(t,1) == 3 && any(Finalblockstriallist(t,2) == r2) &&...
                        any(Finalblockstriallist(t,3) == nis) && any(Finalblockstriallist(t,4) == s2)
                        if Finalblockstriallist(t,5) == 1 
                           OscilRT3 = [OscilRT3 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 2
                               midRT3 = [midRT3 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 3 
                               BayesRT3 = [BayesRT3 ; Finalblockstriallist(t,6)];
                        elseif Finalblockstriallist(t,5) == 4 
                               HazardRT3 = [HazardRT3 ; Finalblockstriallist(t,6)];
                        end
            
            
            
                end
            end
            end



            % Log-transform before outlier rejection
            if logTransform
            
                OscilRT2 = log(OscilRT2);
                midRT2 = log(midRT2);
                BayesRT2 = log(BayesRT2);
                HazardRT2 = log(HazardRT2);
            
                OscilRT3 = log(OscilRT3);
                midRT3 = log(midRT3);
                BayesRT3 = log(BayesRT3);
                HazardRT3 = log(HazardRT3);
            
            end


            % Outlier rejection

             if rejectOutliers==2 % outlier rejection within condition

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



%for rate specific anova stats run the script two times with choosing each rate at r2 variable
if r2==1
    oscil2_rate1 = all_Mu_OscilRT2;
%     mid2_rate1 = all_Mu_midRT2; 
%     bayes2_rate1 = all_Mu_BayesRT2; 
%     hazard2_rate1 = all_Mu_HazardRT2;
    oscil3_rate1 = all_Mu_OscilRT3;
%     mid3_rate1 = all_Mu_midRT3; 
%     bayes3_rate1 = all_Mu_BayesRT3; 
%     hazard3_rate1 = all_Mu_HazardRT3;
end
if r2==2 
    oscil2_rate2 = all_Mu_OscilRT2;
%     mid2_rate2 = all_Mu_midRT2; 
%     bayes2_rate2 = all_Mu_BayesRT2; 
%     hazard2_rate2 = all_Mu_HazardRT2;
    oscil3_rate2 = all_Mu_OscilRT3;
%     mid3_rate2 = all_Mu_midRT3; 
%     bayes3_rate2 = all_Mu_BayesRT3; 
%     hazard3_rate2 = all_Mu_HazardRT3;
end


%% Figures - average

figure()
subplot(1,2,1)
ylimits = [0.32 0.4];


%block2 RTs
errorbar([1, 2, 3, 4], [Mu_OscilRT2, Mu_midRT2, Mu_BayesRT2, Mu_HazardRT2], [-ste_Mu_OscilRT2, -ste_Mu_midRT2, -ste_Mu_BayesRT2, -ste_Mu_HazardRT2], ...
    [ste_Mu_OscilRT2, ste_Mu_midRT2, ste_Mu_BayesRT2, ste_Mu_HazardRT2], 'LineWidth', 1, 'CapSize', 4 , Color =[0.5 0.5 0.5]);
hold on
plot([1, 2, 3, 4], [Mu_OscilRT2, Mu_midRT2, Mu_BayesRT2, Mu_HazardRT2], 'b', 'LineWidth', 2)

hold on

errorbar([1, 2, 3, 4], [Mu_OscilRT3, Mu_midRT3, Mu_BayesRT3, Mu_HazardRT3], [-ste_Mu_OscilRT3, -ste_Mu_midRT3, -ste_Mu_BayesRT3, -ste_Mu_HazardRT3], ...
    [ste_Mu_OscilRT3, ste_Mu_midRT3, ste_Mu_BayesRT3, ste_Mu_HazardRT3], 'LineWidth', 1, 'CapSize', 4, Color =[0.5 0.5 0.5]);
hold on
plot([1, 2, 3, 4], [Mu_OscilRT3, Mu_midRT3, Mu_BayesRT3, Mu_HazardRT3], 'r', 'LineWidth', 2)

% title('')
xticks([1 2 3 4])
xticklabels({'Oscillator', 'Mid point', 'Bayesian', 'Hazard'})
ylim(ylimits)
xlim([0.5 4.5])
ylabel ('Rt(s)')
set(gca,'FontWeight','bold')
axis square;
legend('', '25% jitter', ...
    '', '50% jitter')

set(findobj(gcf, '-property', 'FontName'), 'FontName', 'Arial');
hold on

% all participants Difference 25-50
% ylimits = [-0.08 0.04]; % across rate
ylimits = [-0.13 0.09]; % single rate
% figure()
subplot(1,2,2)
for s = 1 : 4
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
set(findobj(gcf, '-property', 'FontName'), 'FontName', 'Arial');


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

[~,p,~,stats]=ttest(all_Mu_OscilRT2-all_Mu_OscilRT3)% oscil 25% vs 50% (no hazard correction)
cohen_d = stats.tstat / sqrt(stats.df + 1)

[~,p,~,stats]=ttest(all_Mu_BayesRT2-all_Mu_BayesRT3)% bayes 25% vs 50% (no hazard correction)
cohen_d = stats.tstat / sqrt(stats.df + 1)

%

[~,p,~,stats]=ttest(all_Mu_OscilRT2-all_Mu_HazardRT2-(all_Mu_OscilRT3-all_Mu_HazardRT3))% oscil 25% vs 50% (compared to hazard)
cohen_d = stats.tstat / sqrt(stats.df + 1)

[~,p,~,stats]=ttest((all_Mu_BayesRT2-all_Mu_HazardRT2)-(all_Mu_BayesRT3-all_Mu_HazardRT3))% bayes 25% vs 50% (compared to hazard)
cohen_d = stats.tstat / sqrt(stats.df + 1)

%one-tailed t-test for oscillator:
% Oscillator target: 25% faster than 50% (one-tailed)

[~,p,~,stats] = ttest(all_Mu_OscilRT2 - all_Mu_OscilRT3, 0, 'Tail','left')  %25%<50% -> negative -> left tail
cohen_d = stats.tstat / sqrt(stats.df + 1)


[~,p,~,stats] = ttest((all_Mu_OscilRT2 - all_Mu_HazardRT2) -  (all_Mu_OscilRT3 - all_Mu_HazardRT3), 0,  'Tail','left')
cohen_d = stats.tstat / sqrt(stats.df + 1)


% Anova 2 * 2 -> Oscil and Bayesian with correction for hazard
% columns: 25-oscil, 25bayes, 50oscil, 50bayes
% rows : subjects
Anova_Matrix = [all_Mu_OscilRT2-all_Mu_HazardRT2; all_Mu_BayesRT2-all_Mu_HazardRT2; ...
    all_Mu_OscilRT3-all_Mu_HazardRT3; all_Mu_BayesRT3-all_Mu_HazardRT3];

[fValues, dfValues, pValues]=repeated2WayANOVA(Anova_Matrix', 2, 2)
%effetc sizes
eta_A  = (fValues.A  * dfValues.A(1))  / (fValues.A  * dfValues.A(1)  + dfValues.A(2))
eta_B  = (fValues.B  * dfValues.B(1))  / (fValues.B  * dfValues.B(1)  + dfValues.B(2))
eta_AB = (fValues.AB * dfValues.AB(1)) / (fValues.AB * dfValues.AB(1) + dfValues.AB(2))


%% Posthoc anova for rates
%run the script two times with different r2

%Anova columns: 25oscil_rate1, 25oscil_rate2, 50oscil_rate1, 50oscil_rate2 
% rows : subjects
Anova_Matrix = [oscil2_rate1; oscil2_rate2; oscil3_rate1; oscil3_rate2];

[fValues, dfValues, pValues]=repeated2WayANOVA(Anova_Matrix', 2, 2)

%effetc sizes
eta_A  = (fValues.A  * dfValues.A(1))  / (fValues.A  * dfValues.A(1)  + dfValues.A(2))
eta_B  = (fValues.B  * dfValues.B(1))  / (fValues.B  * dfValues.B(1)  + dfValues.B(2))
eta_AB = (fValues.AB * dfValues.AB(1)) / (fValues.AB * dfValues.AB(1) + dfValues.AB(2))



