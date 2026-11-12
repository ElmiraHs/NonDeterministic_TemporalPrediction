%% Result Figure 1 

%% Fig 1A : Raw prediction and uncertianties
clear all; clc
stream_data = ["sd25_11_noSkew.mat"];
Uniform_Vars = 9692-2000; % calculated on a unform distribution with length 11
colors = ['r', 'b'];
allylim = [-0.05 0.35];
itpc_threshold = 1.65*(std((circ_r(2*pi*rand(80,100000),[],[], 1))));

my_custom_size = [ 474   342   697   349];
figure ('Position', my_custom_size)

for s = 1:length(stream_data)
    load (stream_data(s))
    
    % Oscil percent variance reduction
    InitPC = mean(circ_r(initPhase, [], [], 2));
    PCinc = mean(allPC,1);
    Oscil_percentDeltaVar = PCinc ./ (1-InitPC);


    % Bayes percent variance reduction
    prior_alpha = 0.5*mean(skewed_dist);     
    prior_beta = 1000*mean(skewed_dist);
    predicted_variance = prior_beta / (prior_alpha - 1);
    initVar = predicted_variance;
    PostVarMean = squeeze(mean(all_PostVars,1));
    Bayes_percentDeltaVar = (PostVarMean(end,:)-initVar)./Uniform_Vars(1);
    lastInterval = mean(skewed_dist); % in ms
    
    %plot
    scatter(OscillatorEstimate-BayesianEstimate+lastInterval, Oscil_percentDeltaVar ,  'MarkerFaceColor', colors(2), 'MarkerFaceAlpha',0.5)
    hold on
    scatter(OscillatorEstimate-BayesianEstimate+lastInterval+800, Oscil_percentDeltaVar ,  'MarkerFaceColor', colors(2), 'MarkerEdgeColor', colors(2),'MarkerFaceAlpha',0.1)
    hold on
    % to get certainty value as in oscillator pc had to do 1-absolotue delta of unceratinty
    scatter(BayesianEstimate-BayesianEstimate+lastInterval, Bayes_percentDeltaVar ,  'MarkerFaceColor', colors(1), 'MarkerEdgeColor', colors(1), 'MarkerFaceAlpha',0.5)
    xlim([-100 1700])
    ylim(allylim)
    yl = ylim; % get current y-limits
    X = [300 500 500 300];
    Y = [yl(1) yl(1) yl(2) yl(2)];
    patch(X, Y, [1 0.85 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    patch(X+800, Y, [1 0.85 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);

    set(gca,'FontWeight','bold')
    xticks([0 800 1600])
    xticklabels({'Last Stimulus', '1st Cycle of Oscillator (2\pi)', '2nd Cycle of Oscillator (4\pi)'})

    % Plot on the left y-axis
    yyaxis left
    ylabel('\Delta Oscillator PC', 'Color', colors(2));
    
    % Plot on the right y-axis
    yyaxis right
    ylim([-0.05 0.35])
    ylabel('\Delta Bayesian Certainty', 'Color',colors(1));
    yline(itpc_threshold, 'k', 'LineWidth', 2)
end


%% Fig 1C : Model prediction differences 

clear all
stream_data = ["sd15_11_noSkew.mat", "sd25_11_noSkew.mat", "sd50_11_noSkew.mat"];

%set a throshold for ITPC (variance of random itpc):
itpc_threshold = 1.65*(std((circ_r(2*pi*rand(80,100000),[],[], 1))));

colors = ['g', 'b', 'm'];
allylim = [-0.05 0.35];

figure ('Position', [59 425 1420 272]); %jitter conditions
for s = 1:length(stream_data)
    subplot(1,4,s+1)
    load (stream_data(s))

    % variance decrease (it is same as PC increase) and we do relative to intial variance
    InitPC = mean(circ_r(initPhase, [], [], 2));
    PCinc = mean(allPC,1);
    Oscil_percentDeltaVar = PCinc ./ (1-InitPC); % here we keep PC increase (delta PC) increase in certainty normalized by uncertainty of flat dist

    % ----- Statistics for this subplot -----
    yData = Oscil_percentDeltaVar;
    xData = PredictionDiffmeanAngle;
    
    aboveThreshold = yData > itpc_threshold;
    inShadedRegion = xData >= 300 & xData <= 500;
    intersection = aboveThreshold & inShadedRegion;
    
    idx = s + 1;    % ISO is plotStats(1)
    
    plotStats(idx).name = sprintf('SD%d', s);
    plotStats(idx).pctAboveThreshold = 100 * mean(aboveThreshold);
    plotStats(idx).pctInShaded = 100 * mean(inShadedRegion);
    plotStats(idx).pctAboveAndShaded = 100 * mean(intersection);
    
    plotStats(idx).nAboveThreshold = sum(aboveThreshold);
    plotStats(idx).nInShaded = sum(inShadedRegion);
    plotStats(idx).nAboveAndShaded = sum(intersection);
    plotStats(idx).nTotal = numel(yData);

    scatter(PredictionDiffmeanAngle, Oscil_percentDeltaVar ,  'MarkerFaceColor', colors(s), 'MarkerFaceAlpha',0.5)
    hold on
    window = 20; % Window Over Which The Moving Average Is Computed
    [aSorted, aIdx] = sort(PredictionDiffmeanAngle);
   
    b =Oscil_percentDeltaVar;

    bSorted = b(aIdx); 
    ymm = movmean(bSorted,window);
    plot( aSorted, ymm, 'DisplayName','Moving Average', 'LineWidth', 2, Color='r')
    yline(itpc_threshold, 'k', 'LineWidth', 2)
    xlabel('Prediction Difference' , 'FontWeight','bold', 'LineWidth', 2)
    ylim(allylim)
    yl = ylim; % get current y-limits
    X = [300 500 500 300];
    Y = [yl(1) yl(1) yl(2) yl(2)];
    patch(X, Y, [1 0.85 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    set(gca,'FontWeight','bold')
    xticks([0 400 800])
    xticklabels({'0', '\pi', '2\pi'})
    xlim([-50 850])
    axis square
    hold on
end

%ISO condition
load('ISo_Ent100Pri0_Mu800.mat')
subplot(1,4,1)
x = [0 800];

% ----- Statistics for ISO subplot -----
yData = allPC(1);
xData = x;

aboveThreshold = yData > itpc_threshold;
inShadedRegion = xData >= 300 & xData <= 500;
intersection = aboveThreshold & inShadedRegion;

plotStats(1).name = 'ISO';
plotStats(1).pctAboveThreshold = 100 * mean(aboveThreshold);
plotStats(1).pctInShaded = 100 * mean(inShadedRegion);
plotStats(1).pctAboveAndShaded = 100 * mean(intersection);

plotStats(1).nAboveThreshold = sum(aboveThreshold);
plotStats(1).nInShaded = sum(inShadedRegion);
plotStats(1).nAboveAndShaded = sum(intersection);
plotStats(1).nTotal = numel(yData);

scatter(x, allPC(1)/(1-InitPC), 'MarkerFaceColor', 'r')
    yline(itpc_threshold, 'k', 'LineWidth', 2)
hold on
ylim(allylim)
yl = ylim; % get current y-limits
X = [300 500 500 300];
Y = [yl(1) yl(1) yl(2) yl(2)];
patch(X, Y, [1 0.85 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
set(gca,'FontWeight','bold')
xticks([0 400 800])
xticklabels({'0', '\pi', '2\pi'})
xlim([-50 850])
ylabel('Relative \Delta PC', 'FontWeight','bold', 'LineWidth', 2)
xlabel('Prediction Difference' , 'FontWeight','bold', 'LineWidth', 2)
axis square


%% Prepare for Fig 1B: example shuffle figure

clear all; clc
filename = 'sd25_11_noSkew.mat';
load(filename);
allchosen_shuffles = [67];
tic
chosen_shuffle = allchosen_shuffles(1);
Intervals = allIntervals(:,chosen_shuffle);

Stream = cumsum(Intervals);
StimSequence_len = 10000;
StimSequence = zeros(1, StimSequence_len);
StimSequence(Stream) = 1;

%
StimSequence_new=[zeros(1,1000), StimSequence];
StimSequence_new (1000) = 1; %first stimuli

intResolution=0.001; % resolution for the numerical integration
tspan = [-1:intResolution:StimSequence_len/1000]; % create time vector
tspan(1001) = [];

naturalFrequency=1/(mean(skewed_dist)/1000); % oscillator frequency for mean freq
modelParams=[0.1 0.5 -2]; % [phase correction, bifurcation, saturation]

oscillationDyns = zeros(length(tspan), 2, size(initPhase, 1), size(initPhase, 2));
s1 = size(initPhase, 1);
s2 = size(initPhase, 2);
parfor iang = 1:s1
    for currPhase = 1:s2
        y= ode4(@oscillatorModel, tspan, [initPhase(iang, currPhase) 0.5], naturalFrequency, tspan, StimSequence_new, modelParams);
        oscillationDyns(:, :, iang,currPhase) = y;
    end
end
toc

% plot
% oscillationDyns: time x 2 x angleSet x osc

angData = squeeze(oscillationDyns(:,1,:,:));   % phase
radData = squeeze(oscillationDyns(:,2,:,:));   % radius


% average across oscillators, keep 100 initial phase sets
angData = circ_mean(angData,[],3);              % time x 100
radData = mean(radData,3);                      % time x 100



%Bayesian updating plot
observed_data = Intervals;

measurement_variance_ratio = 0.1;
nSteps = length(observed_data);

% --- Prior hyperparameters ---
prior_mu_0     = 0;
prior_lambda_0 = 0.01;
prior_alpha    = 0.5 * mean(Intervals);
prior_beta     = 1000 * mean(Intervals);

prior_variance = prior_beta/(prior_alpha - 1)*10;

% --- Storage ---
priorMean = zeros(nSteps,1);
priorVar  = zeros(nSteps,1);
likeMean  = zeros(nSteps,1);
likeVar   = zeros(nSteps,1);
postMean  = zeros(nSteps,1);
postVar   = zeros(nSteps,1);

% x axis for distributions
x = -500:max(Intervals)+500;


for i = 1:nSteps
    
    data_point = observed_data(i);
    
    % --- Store PRIOR before updating ---
    priorMean(i) = prior_mu_0;
    priorVar(i)  = prior_variance;
    
    % --- Likelihood ---
    likeMean(i) = data_point;
    likeVar(i)  = measurement_variance_ratio * data_point;
    
    likelihood = normpdf(x, likeMean(i), sqrt(likeVar(i)));
    prior_pdf  = normpdf(x, priorMean(i), sqrt(priorVar(i)));
    
    % --- Bayesian Update ---
    posterior_alpha = prior_alpha + 0.5;
    posterior_beta  = prior_beta + ...
        0.5*(data_point - prior_mu_0)^2 + ...
        0.5*measurement_variance_ratio*data_point + ...
        (0.5*prior_lambda_0*(data_point - prior_mu_0)^2)/(prior_lambda_0 + 1);
    
    posterior_mu     = (prior_lambda_0*prior_mu_0 + data_point)/(prior_lambda_0 + 1);
    posterior_lambda = prior_lambda_0 + 1;
    
    predicted_mean     = posterior_mu;
    predicted_variance = posterior_beta/(posterior_alpha - 1);
    
    postMean(i) = predicted_mean;
    postVar(i)  = predicted_variance;
    
    posterior_pdf = normpdf(x, postMean(i), sqrt(postVar(i)));
    
    % --- Recursive update ---
    prior_mu_0     = posterior_mu;
    prior_lambda_0 = posterior_lambda;
    prior_alpha    = posterior_alpha;
    prior_beta     = posterior_beta;
    prior_variance = predicted_variance;
    
    x_all{i} = x;
    posterior_pdf_all{i}= posterior_pdf;
    likelihood_all{i} = likelihood;
    prior_pdf_all{i} = prior_pdf;
end




%% Plot Fig 1B

figure('Position', [ 746   314   582   349]); hold on

ymin = -0.5;
ymax = 0.5;

for i = 1:size(angData,2)   % 100 angle sets
    plot(tspan, ymax+1+cos(angData(:,i)) .* radData(:,i), ...
         'LineWidth',0.8);
end
ylim([-5 5])
xlim([-1 10])
yticks([])
yticklabels([])


for s = 1:length(Stream)
    x = Stream(s)/1000;
    plot([x x], [ymin ymax], 'k', 'LineWidth',1.5);
end

plot([0 0], [ymin ymax], 'k', 'LineWidth',1.5);


% add mean angle oscillator for predcition trajectory

meanAngle_currshuff = circ_mean(circ_mean(squeeze(oscillationDyns(Stream(end)+1000,1,:,:)), [], 2),[], 1);
Angle = rem(squeeze(oscillationDyns(Stream(end)+1000,1,:,:)), 2*pi);
Angle_vector = reshape (Angle, [numel(Angle), 1]);


if meanAngle_currshuff < 0
    [minValue,closestIndex] = min(abs(Angle_vector-(meanAngle_currshuff+(2*pi))));
else 
    [minValue,closestIndex] = min(abs(Angle_vector-(meanAngle_currshuff)));
end

[row, col]= find (Angle == Angle(closestIndex));
oscillator_timecourse = squeeze(cos(oscillationDyns(:,1, row, col)).*oscillationDyns(:,2, row, col));
PC_timecourse = squeeze(circ_r(oscillationDyns(:,1,:,:), [], [] , 4));
itpc_timecourse= squeeze(mean(PC_timecourse,2));
inc_itpc= itpc_timecourse-mean(circ_r(initPhase, [], [], 2));

y_place = 3;        % vertical placement 

plot(tspan, y_place + oscillator_timecourse.*inc_itpc/max(inc_itpc) , 'b', 'LineWidth', 1.5);
hold on



if meanAngle_currshuff < 0
    OscillatorEstimate_currshuff= round(Stream(end)+((abs(meanAngle_currshuff)/(2*pi))*(mean(skewed_dist))));
else 
    OscillatorEstimate_currshuff= round(Stream(end)+((2*pi-meanAngle_currshuff)/(2*pi)*(mean(skewed_dist))));
end
plot(OscillatorEstimate_currshuff/1000, y_place+0.5, 'bx', 'MarkerSize',8, 'LineWidth',2)


% Bayesian prediction (mean over priors)
bayes_pred = squeeze(mean(all_PostMeans(:,:,chosen_shuffle),1)); % ms
bayes_x = bayes_pred / 1000;  % seconds

y_arrow = -1;        % vertical placement for arrows
arrow_height = -0.3;    % curvature height

for i = 1:length(bayes_x)

    % start = previous true event
    x_start = Stream(i) / 1000;

    % end = Bayesian prediction
    x_end = bayes_x(i) + Stream(i)/1000;

    % curved arrow (quadratic Bezier)
    t = linspace(0,1,50);
    x_curve = (1-t).^2*x_start + 2*(1-t).*t*((x_start+x_end)/2) + t.^2*x_end;
    y_curve = y_arrow + arrow_height*sin(pi*t);

    if i == length(bayes_x)
        plot(x_curve, y_curve, 'r', 'LineWidth',1.5)
    else
        plot(x_curve, y_curve, 'r:', 'LineWidth',1.5)
    end

    % arrow head
    quiver(x_curve(end-1), y_curve(end-1), ...
           x_curve(end)-x_curve(end-1), ...
           y_curve(end)-y_curve(end-1), ...
           0, 'r', 'LineWidth',1.5, 'MaxHeadSize',0.8)

    % prediction marker (cross)
    if i == length(bayes_x)
        plot(x_end, y_arrow, 'rx', 'MarkerSize',8, 'LineWidth',2)
    end

end
xlabel('Time(s)')
set(gca,'FontWeight','bold')
hold on



% --- Zoomed Bayesian updating boxes ---

steps_to_plot = [1 2 length(Intervals)];

for k = 1:length(steps_to_plot)

    i = steps_to_plot(k);

    % Arrow start time (seconds)
    x_shift = Stream(i)/1000;

    % Create small inset axes (manual positioning)
    ax_pos_x = 0.15 + (k-1)*0.3;   % horizontal placement (adjust if needed)
    if i==2
    ax_pos_x = ax_pos_x - 0.1
    end
    ax_pos_y = 0.18;                % vertical placement
    ax_width = 0.15;
    ax_height = 0.15;

    ax_inset = axes('Position',[ax_pos_x ax_pos_y ax_width ax_height]);
    ax_handles(k) = ax_inset;   % store handle
    box on
    hold on

    % Normalize for clean comparison
    prior_plot = prior_pdf_all{i} / max(prior_pdf_all{i});
    prior_plot = prior_pdf_all{i};
    like_plot  = likelihood_all{i} /3;
    post_plot  = posterior_pdf_all{i};

    % Plot distributions (interval axis in ms)
    plot(x_all{i}, prior_plot, 'g', 'LineWidth',1.5)
    plot(x_all{i}, like_plot,  'k', 'LineWidth',1.5)
    plot(x_all{i}, post_plot,  'r', 'LineWidth',2)

    title(['Interval ' num2str(i)], 'FontWeight','bold')

    set(gca,'FontWeight','bold')
    % Make axis limits identical

    ylim([0 0.02])
    xlim([-500 1500])     
end
% linkaxes(ax_handles,'xy')
set(ax_handles,'YTickLabel','')


%% Result Figure 2

%% Fig 2A : Model uncertainty disscociation across jitter vs iso

clear all
stream_data = ["sd15_11_noSkew.mat", "sd25_11_noSkew.mat", "sd30_11_noSkew.mat", "sd40_11_noSkew.mat", "sd50_11_noSkew.mat", "sd75_11_lowSkew.mat"];

%baseline posterior vars
Uniform_Vars = 9692-2000;
colors = ['g', 'b', 'y', 'r', 'k', 'm'];

figure ('Position', [279   293   966   389]);
subplot(1,2,1)
All_OscilVar = zeros(1,length(stream_data));
All_BayesVar = zeros(1,length(stream_data));
for s = 1:length(stream_data)
    load (stream_data(s))

    % Oscil percent variance reduction
    InitPC = mean(circ_r(initPhase, [], [], 2));
    PCinc = mean(allPC,1);
    Oscil_percentDeltaVar = -PCinc ./ (1-InitPC);
    
    
    % Bayes percent variance reduction
    PostVarMean = squeeze(mean(all_PostVars,1));
    Bayes_percentDeltaVar= (PostVarMean(end,:)./ Uniform_Vars(1))-1;

    scatter(Bayes_percentDeltaVar, Oscil_percentDeltaVar, 'MarkerFaceColor', colors(s), 'MarkerFaceAlpha',0.2, MarkerEdgeColor='flat')
    
    hold on

    % geometric median (sum of distances to all points)
    % function to calculate the sum of Euclidean distances
    median_data = [Bayes_percentDeltaVar', Oscil_percentDeltaVar'];
    distance_sum = @(point) sum(sqrt(sum((median_data - point).^2, 2)));

    % Use fminsearch to minimize the sum of distances
    initial_guess = mean(median_data); % Start with the centroid as the initial guess
    geometric_median = fminsearch(distance_sum, initial_guess);
    plot (geometric_median(1), geometric_median(2), 'o', Color=colors(s), MarkerFaceColor='k', MarkerEdgeColor='black', LineWidth= 1) 
    hold on

    % Compute violin plot for the whole x and y data

    % Estimate kernel density of the y-values (for the entire dataset)
    [f_y, y_values] = ksdensity(Oscil_percentDeltaVar);  % Density estimate for y-values
    
    % Normalize the density and adjust to fit the x-axis range
    f_y = f_y / max(f_y) * range(Bayes_percentDeltaVar) * 0.3;  % Scale to 30% of x-axis range
    
    % Plot the violin plot
    x_center = mean(Bayes_percentDeltaVar);  % Center of the violin plot (mean of x-values)
    fill(x_center + [-f_y, fliplr(f_y)], [y_values, fliplr(y_values)], 'r', 'FaceAlpha', 0.2);



    ylabel('Relative \Delta Oscillator PV', 'FontWeight','bold', 'LineWidth', 2)
    xlabel('Relative \Delta Bayeisan Uncertainty' , 'FontWeight','bold', 'LineWidth', 2)

    set(gca,'FontWeight','bold')
    hold on
    
    All_OscilVar(s)= geometric_median(2);
    All_BayesVar(s)= geometric_median(1);
end
legend('15% SD','', '', '25% SD', '', '', '30% SD', '', '', '40% SD','','', '50% SD','', '',  '70% SD','geometric-median',  'NumColumns',2, 'Location','southeast')
ylim([-0.32 0.06])
xlim([-0.8 0.9])


%ISO figures
InitPC = mean(circ_r(initPhase, [], [], 2)); % just to get the inti PC
load('ISo_Ent100Pri0_Mu800.mat', 'allPC')
load('new_ISo_Ent100Pri0_Mu800.mat', 'allVAR')

subplot(1,2,2)
colors = ['b', 'r', 'k', 'g'];
shape = ['o'; 's'; 'd'; '^' ];
All_OscilVar_iso = zeros(1,4);
All_BayesVar_iso = zeros(1,4);

for s = 1:length(colors)
    scatter (((allVAR(s))./Uniform_Vars(1))-1, -allPC(s)/(1-InitPC), colors(1), shape(s), 'filled')  %nirmlaized to same as jitter uniform var of length 11

    All_OscilVar_iso(s)= -allPC(s)/(1-InitPC);
    All_BayesVar_iso(s)= (allVAR(s)./Uniform_Vars(1))-1;
    hold on
end
ylabel('Relative \Delta Oscillator PV')
xlabel('Relative \Delta Bayeisan Uncertainty')
ylim([-0.32 0.06])
xlim([-0.7235 -0.7210])
set(gca, 'FontWeight', 'bold')
legend ( '11 ISI', '9 ISI', '7 ISI', '5 ISI', 'Location','southeast')

[h, icons, plots, txt] = legend; % or use your stored plot handles
legend(h.PlotChildren(end:-1:1));


%% Fig 2B : Uncertainty timecourse of two models
% downsampled version for inkscape at the end

clear all
Uniform_Vars = 9692-2000;
% List of files to process
fileList = {'sd25_11_noSkew.mat', 'sd50_11_noSkew.mat'};
numFiles = length(fileList);

% Store time-resolved variance across shuffles
shuffleVar_ITPC = cell(numFiles,1);
shuffleVar_PredVar = cell(numFiles,1);
shuffleVar_Uncertainty = cell(numFiles,1);

tspan_store = cell(numFiles,1);

figure('Position',[ 179    76   996   685]);

for f = 1:numFiles
    filename = fileList{f};
    load(filename);
    
    Stream = cumsum(allIntervals(:,1));
    StimSequence_len = round(Stream(end)+ (1*mean(skewed_dist)));
    intResolution=0.001; % resolution for the numerical integration
    tspan = [intResolution:intResolution:StimSequence_len/1000]; % create time vector

    % --- ITPC plot ---
    subplot(3,3,1 + (f-1)*3); 
    itpc= squeeze(mean(allPC_timecourse(:,:,:),2));
    inc_itpc= (itpc-mean(circ_r(initPhase, [], [], 2)))./(1-mean(circ_r(initPhase, [], [], 2)));

    shuffleVar_ITPC{f} = var(inc_itpc,0,2);
    tspan_store{f} = tspan;

    plot(tspan, -inc_itpc, 'LineWidth', 1)
    set(gca,'FontWeight','bold')
    xlabel('Time(s)', 'FontWeight','bold', 'LineWidth', 2)
    ylabel('Relative \Delta PV' , 'FontWeight','bold', 'LineWidth', 2)
    title(['Oscillator Phase Variance'], 'FontWeight','bold', 'FontSize',13)
    ylim([-0.22 0])
    set(gca,'FontWeight','bold')



    % --- initial variance ---
    prior_alpha = 0.5*mean(skewed_dist);     
    prior_beta = 1000*mean(skewed_dist);
    predicted_variance = prior_beta / (prior_alpha - 1);

    mean_all_PostVars = squeeze(mean(all_PostVars,1)); 

    % New last interval
    lastInterval = 800; % in ms
    allIntervals_new = [allIntervals; lastInterval * ones(1, size(allIntervals, 2))]; 

    initialValue = predicted_variance;  
    mean_all_PostVars = [initialValue * ones(1, size(mean_all_PostVars, 2));mean_all_PostVars]; 
    mean_all_PostVars = mean_all_PostVars./Uniform_Vars(1)-1; %normalized
    baselined_mean_all_PostVars = mean_all_PostVars-mean_all_PostVars(1); % to strat from 0
    baselined_mean_all_PostVars = mean_all_PostVars; 
    PostVars_time = zeros(length(BayesianEstimate), length(tspan));

    for shuffle = 1:size(allIntervals_new,2)
        currentTime = 0;
        for interval = 1:size(allIntervals_new,1)
            intervalLength = allIntervals_new(interval, shuffle)/1000; 
            idx = tspan > currentTime & tspan <= (currentTime + intervalLength);
            PostVars_time(shuffle, idx) = baselined_mean_all_PostVars(interval, shuffle);
            currentTime = currentTime + intervalLength;
        end
    end
    shuffleVar_Uncertainty{f} = var(PostVars_time,0,1);

    % --- Posterior Variance plot ---
    subplot(3,3,2 + (f-1)*3);
    plot(tspan(1:end-2), PostVars_time(:,1:end-2), 'LineWidth', 1)
    title(['Bayesian Uncertainty'], 'FontWeight','bold', 'FontSize',13)
    xlabel('Time (s)')
    ylabel(' Relative \Delta Uncertainty')
    set(gca,'FontWeight','bold')
    ylim([-0.8 0.2])


    % --- variance of posterior predictions ---
    all_mean_var= squeeze(var(all_PostMeans,0,1));
    all_mean_var= [all_mean_var(1,:);all_mean_var]; %start from variance after first interval

    rel_all_mean_var = (all_mean_var./all_mean_var(1)) - 1; %normalized

    PostVars_time = zeros(length(BayesianEstimate), length(tspan));

    for shuffle = 1:size(allIntervals_new,2)
        currentTime = 0;
        for interval = 1:size(allIntervals_new,1)
            intervalLength = allIntervals_new(interval, shuffle)/1000; 
            idx = tspan > currentTime & tspan <= (currentTime + intervalLength);
            PostVars_time(shuffle, idx) = rel_all_mean_var(interval, shuffle); 
            currentTime = currentTime + intervalLength;
        end
    end

    shuffleVar_PredVar{f} = var(PostVars_time,0,1);
    
    % --- Posterior predictions variance plot ---
    subplot(3,3,3 + (f-1)*3);
    plot(tspan(1:end-2), PostVars_time(:,1:end-2), 'LineWidth', 1)
    title(['Bayesian Prediction Variance'], 'FontWeight','bold', 'FontSize',13)
    xlabel('Time (s)')
    ylabel('Relative Variance')
    ylim([-1 0])
    set(gca,'FontWeight','bold')
end





% Third row: compare 25% vs 50% jitter


labels = {'25% jitter','50% jitter'};

% ---------- Column 1 : ITPC variance ----------
subplot(3,3,7)
plot(tspan_store{1}, shuffleVar_ITPC{1}, 'LineWidth',2)
hold on
plot(tspan_store{2}, shuffleVar_ITPC{2}, 'LineWidth',2)
xlabel('Time (s)')
ylabel('Variance across shuffles')
legend(labels,'Location','best')
set(gca,'FontWeight','bold')

% ---------- Column 2 : Bayesian uncertainty ----------
subplot(3,3,8)
plot(tspan_store{1}(1:end-2), ...
     shuffleVar_Uncertainty{1}(1:end-2), 'LineWidth',2)
hold on
plot(tspan_store{2}(1:end-2), ...
     shuffleVar_Uncertainty{2}(1:end-2), 'LineWidth',2)
xlabel('Time (s)')
ylabel('Variance across shuffles')
% legend(labels,'Location','best')
set(gca,'FontWeight','bold')

% ---------- Column 3 : Prediction variance ----------
subplot(3,3,9)
plot(tspan_store{1}(1:end-2), ...
     shuffleVar_PredVar{1}(1:end-2), 'LineWidth',2)
hold on
plot(tspan_store{2}(1:end-2), ...
     shuffleVar_PredVar{2}(1:end-2), 'LineWidth',2)
xlabel('Time (s)')
ylabel('Variance across shuffles')
% legend(labels,'Location','best')
set(gca,'FontWeight','bold')


%% Results Figure 3

%% Fig 3A: parameter senssitivity analysis

% Oscillator-ISO--------------------------------------------------------
clear all

load ("sd50_11_noSkew.mat", "initPhase")
InitPC = mean(circ_r(initPhase, [], [], 2)); % just to get the init PC

load("ISo_Ent0Pri10000_Mu800.mat", "allPC")
all_VAR_Ent0= -allPC./(1-InitPC);
load("ISo_Ent100Pri0_Mu800.mat", "allPC")
all_VAR_Ent100 = -allPC./(1-InitPC);
load("ISo_Ent1000Pri10_Mu800.mat", "allPC")
all_VAR_Ent1000 = -allPC./(1-InitPC);

colors = ['b'; 'r'; 'k'];  
shape = ['o'; 's'; 'd'; '^' ];
x = [1, 2, 3];
y = [all_VAR_Ent0(1), all_VAR_Ent100(1), all_VAR_Ent1000(1)];
labels = {'ent 0', 'ent 0.1', 'ent 1'};  % Legend labels
 
figure ('Position', [183 93 1292 646])
subplot(2,4,1)
hold on
for l=1:4
    y = [all_VAR_Ent0(l), all_VAR_Ent100(l), all_VAR_Ent1000(l)];
    for i = 1:length(x)
        scatter(x(i), y(i), [], colors(i), shape(l), 'filled', 'DisplayName', labels{i});
    end
end
hold off

xlim([0 4])
ylabel('Relative \Delta Oscillator PV', 'FontWeight', 'bold', 'LineWidth', 2)
xlabel('', 'FontWeight', 'bold', 'LineWidth', 2)
xticks([1 2 3])
xticklabels({'0', '0.1', '1'})
title('Oscillator Model', 'FontWeight', 'bold', 'FontSize', 12)
set(gca, 'FontWeight', 'bold')

legend show  % Show only explicitly named items
[h, icons, plots, txt] = legend ('11 ISI', '', '', '9 ISI', '', '', '7 ISI ', '', '', '5 ISI', 'Location','southeast'); % or use your stored plot handles
legend(h.PlotChildren(end:-1:1));
 % Show only explicitly named items
axis square
ylim([-1 0.05])

%------------------------------------------------------------------
clear all
load ("sd50_11_noSkew.mat", "initPhase")
InitPC = mean(circ_r(initPhase, [], [], 2)); % just to get the inti PC

load("mindamp_ISo_Ent100Pri0_Mu800.mat", "allPC")
all_VAR_damp0= -allPC./(1-InitPC);
load("middamp_ISo_Ent100Pri0_Mu800.mat", "allPC")
all_VAR_damp1 = -allPC./(1-InitPC);
load("maxdamp_ISo_Ent100Pri0_Mu800.mat", "allPC")
all_VAR_damp10 = -allPC./(1-InitPC);

colors = ['b'; 'r'; 'k'];  
shape = ['o'; 's'; 'd'; '^' ];
x = [1, 2, 3];
y = [all_VAR_damp0(1), all_VAR_damp1(1), all_VAR_damp10(1)];
labels = {'damp 0', 'damp 0.1', 'damp 1'};  % Legend labels

subplot(2,4,3)
hold on
for l=1:4
    y = [all_VAR_damp0(l), all_VAR_damp1(l), all_VAR_damp10(l)];
    for i = 1:length(x)
        scatter(x(i), y(i), [], colors(i), shape(l), 'filled', 'DisplayName', labels{i});
    end
end
hold off

xlim([0 4])
ylabel('Relative \Delta Oscillator PV', 'FontWeight', 'bold', 'LineWidth', 2)
xlabel('', 'FontWeight', 'bold', 'LineWidth', 2)
xticks([1 2 3])
xticklabels({'0', '0.1', '1'})
title('Oscillator Model', 'FontWeight', 'bold', 'FontSize', 12)
set(gca, 'FontWeight', 'bold')
axis square
ylim([-1 0.05])


% Bayeisan-ISO--------------------------------


clear all
Uniform_Vars = 9692-2000;

load("ISo_Ent100Pri10000_Mu800.mat", "allVAR")
all_VAR_Pri10000 = allVAR./Uniform_Vars(1)-1;
load("ISo_Ent100Pri10_Mu800.mat", "allVAR")
all_VAR_Pri10 = allVAR./Uniform_Vars(1)-1;
load("new_ISo_Ent100Pri0_Mu800.mat", "allVAR")
all_VAR_Pri0 = allVAR./Uniform_Vars(1)-1;

colors = ['b'; 'r'; 'k']; 
shape = ['o'; 's'; 'd'; '^' ];
x = [1, 2, 3];
y = [all_VAR_Pri10000(1), all_VAR_Pri10(1), all_VAR_Pri0(1)];
labels = {'pri10000', 'pri10', 'pri0'};  % Legend labels

subplot(2,4,2)
hold on
for l = 1:4
    y = [all_VAR_Pri10000(l), all_VAR_Pri10(l), all_VAR_Pri0(l)];
    for i = 1:length(x)
        scatter(x(i), y(i), [], colors(i), shape(l), 'filled', 'DisplayName', labels{i});
    end
 
end
hold off

xlim([0 4])
ylabel('Relative \Delta Bayesian Uncertainty', 'FontWeight', 'bold', 'LineWidth', 2)
xlabel('', 'FontWeight', 'bold', 'LineWidth', 2)
xticks([1 2 3])
xticklabels({'1', '0.001', '0'})
title('Bayesian Model', 'FontWeight', 'bold', 'FontSize', 12)
set(gca, 'FontWeight', 'bold')
ylim([-1 -0.05])
axis square



clear all
Uniform_Vars = 9692-2000; % length 11, 9, 7, 5

load("new_ISo_Ent100Pri0_Mu800.mat", "allVAR")
all_VAR_forg0= allVAR./Uniform_Vars(1)-1;
load("ISo_Pri0_Mu800_forg05.mat", "allVAR")
all_VAR_forg05 = allVAR./Uniform_Vars(1)-1;
load("ISo_Pri0_Mu800_forg1.mat", "allVAR")
all_VAR_forg1 = allVAR./Uniform_Vars(1)-1;

colors = ['b'; 'r'; 'k'];  
shape = ['o'; 's'; 'd'; '^' ];
x = [1, 2, 3];
y = [all_VAR_forg0(1), all_VAR_forg05(1), all_VAR_forg1(1)];
labels = {'mem 1', 'mem 0.5', 'mem 0'};  % Legend labels

subplot(2,4,4)
hold on
for l=1:4
    y = [all_VAR_forg0(l), all_VAR_forg05(l), all_VAR_forg1(l)];
    for i = 1:length(x)
        scatter(x(i), y(i), [], colors(i), shape(l), 'filled', 'DisplayName', labels{i});
    end
end
hold off

xlim([0 4])
ylabel('Relative \Delta Bayesian Uncertainty', 'FontWeight', 'bold', 'LineWidth', 2)
xlabel('', 'FontWeight', 'bold', 'LineWidth', 2)
xticks([1 2 3])
xticklabels({'1', '0.5', '0'})
title('Bayesian Model', 'FontWeight', 'bold', 'FontSize', 12)
set(gca, 'FontWeight', 'bold')

% legend show
% legend ('11 ISI', '', '', '9 ISI', '', '', '7 ISI', '', '', '5 ISI') % Show only explicitly named items
axis square
ylim([-1 0.05])



%%jitter
% Oscillator-jitter ----------------------------------------
clear all
colors = ['g', 'b', 'y', 'r', 'k', 'm'];
stream_data = ["Ent0Pri10000_Mu800_sd25_11_noSkew", "sd25_11_noSkew_100Ent.mat", "Ent1000Pri10_Mu800_sd25_11_noSkew"];

subplot(2,4,5)
for s = 1:length(stream_data)
    load(stream_data(s)) 

    % Scatter plot with color assignment
    InitPC = mean(circ_r(initPhase, [], [], 2));
    PCinc = mean(allPC,1);
    Oscil_percentDeltaVar = -PCinc ./ (1-InitPC);

    h = scatter(s+((-0.5 + rand(size(allPC, 2), 1)) / 10), Oscil_percentDeltaVar, ...
        'MarkerFaceColor', colors(s), 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeColor', 'flat');
    hold on

    % Assign legend only for representative items
    if s == 1
        set(h, 'DisplayName', '0 ent');  % First item legend
    elseif s == 2
        set(h, 'DisplayName', '0.1 ent');  % Second item legend
    elseif s == 3
        set(h, 'DisplayName', '1 ent');  % Third item legend
    end

    ylabel('Relative \Delta Oscillator PV', 'FontWeight', 'bold', 'LineWidth', 2)
    xlabel('Entrainment Strength', 'FontWeight', 'bold', 'LineWidth', 2)
    xticks([1 2 3])
    xlim([0 4])
    xticklabels({'0', '0.1', '1'})
    set(gca, 'FontWeight', 'bold')
end

legend off
axis square
ylim([-1 0.05])


%--------------------------------------------
clear all
colors = ['g', 'b', 'y', 'r', 'k', 'm'];

% damp param 0, 1, 10 (no damp, medium damp, max damp)
stream_data = ["mindamp_sd25_11_noSkew", "middamp_sd25_11_noSkew.mat", "maxdamp_sd25_11_noSkew"];

subplot(2,4,7)
for s = 1:length(stream_data)
    load(stream_data(s)) 

    % Scatter plot with color assignment
    InitPC = mean(circ_r(initPhase, [], [], 2));
    PCinc = mean(allPC,1);
    Oscil_percentDeltaVar = -PCinc ./ (1-InitPC);

    h = scatter(s+((-0.5 + rand(size(allPC, 2), 1)) / 10), Oscil_percentDeltaVar, ...
        'MarkerFaceColor', colors(s), 'MarkerFaceAlpha', 0.2, ...
        'MarkerEdgeColor', 'flat');
    hold on

    % Assign legend only for representative items
    if s == 1
        set(h, 'DisplayName', '0 ent');  % First item legend
    elseif s == 2
        set(h, 'DisplayName', '0.1 ent');  % Second item legend
    elseif s == 3
        set(h, 'DisplayName', '1 ent');  % Third item legend
    end

    ylabel('Relative \Delta Oscillator PV', 'FontWeight', 'bold', 'LineWidth', 2)
    xlabel('Dampening', 'FontWeight', 'bold', 'LineWidth', 2)
    xticks([1 2 3])
    xlim([0 4])
    xticklabels({'0', '0.1', '1'})
    set(gca, 'FontWeight', 'bold')
end

legend off
axis square
ylim([-1 0.05])


% Bayesian-jitter ----------------------------------------

clear all
% prior param 
stream_data = ["Ent0Pri10000_Mu800_sd25_11_noSkew", "Ent1000Pri10_Mu800_sd25_11_noSkew", "sd25_11_noSkew_100Ent.mat"];
Uniform_Vars = 9692-2000; % length 11, 9, 7, 5
colors = ['g', 'b', 'y', 'r', 'k', 'm'];

subplot(2,4,6)
for s = 1:length(stream_data)
    load (stream_data(s))

    PostVarMean = squeeze(mean(all_PostVars,1));
    Bayes_percentVarReduction= PostVarMean(end,:)./ Uniform_Vars(1)-1;

    h = scatter(s+((-0.5 + rand(size(allPC, 2), 1)) / 10), Bayes_percentVarReduction, ...
        'MarkerFaceColor', colors(s), 'MarkerFaceAlpha',0.2, MarkerEdgeColor='flat');
    hold on

    % Assign legend only for representative items
    if s == 1
        set(h, 'DisplayName', 'pri 1 = full prior dependency');  % First item legend
    elseif s == 2
        set(h, 'DisplayName', 'pri 0.01');  % Second item legend
    elseif s == 3
        set(h, 'DisplayName', 'pri 0');  % Third item legend
    end

    ylabel('Relative \Delta Bayesian Uncertainty', 'FontWeight','bold', 'LineWidth', 2)
    xlabel('Prior Dependency', 'FontWeight', 'bold', 'LineWidth', 2)
    xticks([1 2 3])
    xlim([0 4])
    xticklabels({'1', '0.001', '0'})
    set(gca,'FontWeight','bold')
    hold on
end
% legend show
legend off
ylim([-1 0.05])
axis square

%--------------------------------------------------------------------
clear all
% forgetting param 0, 0.5, 1
stream_data = ["sd25_11_noSkew_100Ent.mat", "sd25_11_noSkew_forg05.mat", "sd25_11_noSkew_forg1.mat"];
Uniform_Vars = 9692-2000;
colors = ['g', 'b', 'y', 'r', 'k', 'm'];

subplot (2,4,8)
for s = 1:length(stream_data)
    load (stream_data(s)) 

    PostVarMean = squeeze(mean(all_PostVars,1));
    Bayes_percentVarReduction= PostVarMean(end,:)./ Uniform_Vars(1)-1;

    h = scatter(s+((-0.5 + rand(size(allPC, 2), 1)) / 10), Bayes_percentVarReduction, ...
        'MarkerFaceColor', colors(s), 'MarkerFaceAlpha',0.2, MarkerEdgeColor='flat');
    hold on

    % Assign legend only for representative items
    if s == 1
        set(h, 'DisplayName', 'mem 1 = full memory');  % First item legend
    elseif s == 2
        set(h, 'DisplayName', 'mem 0.5');  % Second item legend
    elseif s == 3
        set(h, 'DisplayName', 'mem 0');  % Third item legend
    end

    ylabel('Relative \Delta Bayesian Uncertainty', 'FontWeight','bold', 'LineWidth', 2)
    xlabel('Memory', 'FontWeight', 'bold', 'LineWidth', 2)
    xticks([1 2 3])
    xlim([0 4])
    xticklabels({'1', '0.5', '0'})
    set(gca,'FontWeight','bold')
    hold on
end
legend off
ylim([-1 0.05])
axis square


%% Fig. 3B: Best Frequency oscillator (amplitude based selection with dampening oscillators)
% close all;
clear;clc

% time params
sampRate=100;

% oscillator params
modelParams=[1 -1 1]; % [phase correction, bifurcation, saturation]

figure('Position', [302   167   979   471]);

% freqs =[0.7, 1, 1.5]; %~0.5 octaves around 1 hz
freqs =[0.8, 1.25, 2]; 
isoInputFreq=1.25; % in Hz

entrainmentLevels=[0.1 1];

for e = 1:length(entrainmentLevels)

modelParams(1)=entrainmentLevels(e);

for i = 1:length(freqs)

%%% reduce entrainment a bit for the matching oscillator (to be better visible in figure)
if modelParams(1) == 1 && i==2
  modelParams(1) = 0.5;
end
%%%

rng(100)

oscillatorFreq=freqs(i);
nStimuli=11;
emptyIntPre=1.2;
emptyIntPost=1.2;
nTrials=80;

durationSecs=emptyIntPre+(nStimuli-1)*(1/isoInputFreq)+emptyIntPost;
tspan = [1/sampRate:1/sampRate:durationSecs];

stimSequence=zeros(length(tspan),1);
stimTimes=(emptyIntPre+[0:(1/isoInputFreq):(nStimuli-1)*(1/isoInputFreq)]);
stimTimes=round(stimTimes*sampRate)/sampRate;
stimSequence(single(stimTimes*sampRate))=1;

oscResults=zeros(length(tspan),2,nTrials);

parfor k=1:nTrials
    
    startPoint=[2*pi*rand 0.5];
    y= ode4(@oscillatorModel, tspan, startPoint, oscillatorFreq, tspan, stimSequence, modelParams);

    oscResults(:,:,k)=y;
end

angData=mod(squeeze(oscResults(:,1,:)),2*pi);
radData=squeeze(oscResults(:,2,:));

angData(radData<0)=angData(radData<0)+pi;
radData=abs(radData);

subplot(3,2,(i-1)*2+e); hold on
% figure()
plot(tspan, cos(angData).*radData)
plot(tspan, stimSequence/2-0.5,'k','LineWidth',1)

title("Os Freq = " + oscillatorFreq + " Hz")

set(gca,'FontSize',10,'FontWeight','bold')
ylim([-1 1])
set(findobj(gcf, '-property', 'FontName'), 'FontName', 'Arial');
end
end
set(findobj(gcf, '-property', 'FontName'), 'FontName', 'Arial');

sgtitle("1.25 Hz Isochronous Stream",'FontSize',16,'FontWeight','bold')


% column titles
annotation('textbox',[0.20 0.90 0.2 0.05],'String','Ent = 0.1',...
'EdgeColor','none','HorizontalAlignment','center','FontWeight','bold', 'FontSize', 10 )

annotation('textbox',[0.63 0.90 0.2 0.05],'String','Ent = 1',...
'EdgeColor','none','HorizontalAlignment','center','FontWeight','bold', 'FontSize', 10)


%% Fig. 3C ----------------------------------------------------------------------------------------------------------------------------------------------------------

% mean rate oscillator in jitter
stream_data = ["sd15_11_noSkew.mat", "sd25_11_noSkew_100Ent.mat", "sd15_11_noSkew_08Hz.mat", "sd15_11_noSkew_2Hz.mat"];

figure('Position', [452   161   501   384]);
scatterline= [2 5 1 3];
colors =  ['g', 'b', 'y', 'r', 'k', 'm'];
for s = 1:4
    load (stream_data(s))
    % Scatter plot with color assignment
    InitPC = mean(circ_r(initPhase, [], [], 2));
    PCinc = mean(allPC,1);
    Oscil_percentDeltaVar = -PCinc ./ (1-InitPC);

    xscat = repmat(scatterline(s), [length(mean(allPC, 1)), 1])+ ((rand(1, length(mean(allPC,1)))./5 - 0.09)' ) ;
    scatter(xscat, Oscil_percentDeltaVar', 'MarkerFaceColor', colors(s), 'MarkerFaceAlpha',0.2, MarkerEdgeColor='flat')
    hold on
    scatter(scatterline(s), mean(Oscil_percentDeltaVar), 'MarkerFaceColor','k' , 'MarkerEdgeColor', 'k')
end


title({'1.25 Hz Mean Rate Jittered Stream'}, 'FontSize',12,'FontWeight','bold')
xticks([1 2 3 4 5])
ylabel('Relative \Delta PV')
set(gca,'FontWeight','bold')
xlim([0.5 5.5])
ylim([-0.27 0.01])
legend ('individual shuffle', 'mean' , '', '','')

labels = {'15% SD \newline0.8 Hz Os', ...
          '15% SD \newline1.25 Hz Os', ...
          '15% SD \newline2 Hz Os', ...
          '', ...
          '25% SD \newline1.25 Hz Os'};

xticklabels(labels);
set(gca, 'TickLabelInterpreter', 'tex');
