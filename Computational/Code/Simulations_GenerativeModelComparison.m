clear; clc; close all
parpool('local',64)

%% create the stream
defaultStream = RandStream('mlfg6331_64');
RandStream.setGlobalStream(defaultStream)


n = 300;   %shuffle
pset= 1; %chose the length (11,9,7,5)

%manually chosen Dist params to get exact stream params
%mu = [811, 813, 836, 842]; %ms - mu15
%mu = [818, 813, 836, 869]; %ms - mu25
mu = [836, 825, 836, 942]; %ms - mu50
% %mu = [842, 825, 836, 869]; %ms - mu70 

%sd= [0.14, 0.22, 0.22, 0.135]*mu(pset);% sd15
%sd= [0.27, 0.22, 0.22, 0.21]*mu(pset); %sd30
%sd= [0.35, 0.22, 0.22, 0.21]*mu(pset); %sd40
%sd= [0.225, 0.215, 0.22, 0.22]*mu(pset); % sd25
sd= [0.44, 0.42, 0.42, 0.405]*mu(pset); % sd50
%sd= [0.61, 0.65, 0.65, 0.65]*mu(pset); %sd70

skew = [0.1, 0.15, 0.15, 0.21]; %0.3 for 70% to not get negative intervals 
kurt = skew.^2 +2;
samplingFreq = [9500, 12000, 15000, 20000]; %from longer to shorter streams(11,9,7,5 intervals) 
defaultStream.Substream = 1; %choose the random stream that is not any of the already used ones
d=pearsrnd(mu(pset),sd(pset),skew(pset),kurt(pset),100000,1);
skewness(d);
ds = sort(d);
skewed_dist=round(downsample(ds,samplingFreq(pset)));


% Final stream param check
skewness(skewed_dist)
std(skewed_dist)/mean(skewed_dist)
mean(skewed_dist)
l=length (skewed_dist)

defaultStream.Substream = n+2;
for iang = 1:100
    randinitPhase = 2*pi*rand(80, 1);
    initPhase(iang,:)= randinitPhase;
end

%% loop

parfor ii = 1:n  
    Intervals = Shuffle(skewed_dist);
    Stream = cumsum(Intervals);
    StimSequence_len = round(Stream(end)+ (1*mean(skewed_dist)));
    StimSequence = zeros(1, StimSequence_len);
    StimSequence(Stream) = 1;
    
    allIntervals(:,ii) = Intervals;
    
    %% Oscillator model
    intResolution=0.001; % resolution for the numerical integration
    tspan = [intResolution:intResolution:StimSequence_len/1000]; % create time vector
    
    naturalFrequency=1/(mean(skewed_dist)/1000); % oscillator frequency for mean freq
    modelParams=[100 0.5 -2]; % [phase correction (0, 100, 1000), bifurcation, saturation]    ---> here chosen by me :/ to have 0.5 amplitude and self-sustained


    oscillationDyns = zeros(length(tspan), 2, size(initPhase, 1), size(initPhase, 2));
    for iang = 1:size(initPhase, 1)
        for currPhase = 1:size(initPhase, 2)
            y= ode4(@oscillatorModel, tspan, [initPhase(iang, currPhase) 0.5], naturalFrequency, tspan, StimSequence, modelParams);
            oscillationDyns(:, :, iang,currPhase) = y;
        end
    end

    %% calculate phase coherence
    EndMeanPC = squeeze(mean(circ_r(oscillationDyns(end-50:end-1,1,:,:), [], [] ,4), 1));
    InitMeanPC = circ_r(initPhase, [], [], 2);
    meanPC = EndMeanPC- InitMeanPC;
    allPC(:,ii) = meanPC;
    PC_timecourse = squeeze(circ_r(oscillationDyns(:,1,:,:), [], [] , 4));
    allPC_timecourse (:, :, ii) = PC_timecourse;

    %% Conjugate Prior Bayesian Updating

    % Define the observed data
    observed_data = Intervals;
    measurement_variance_ratio= 0.1;
    
    % Define prior hyperparameters (normal-gamma parameters)
    prior_mu_0_all = [200:200:max(skewed_dist)+200]; 	      % Prior mean
    prior_lambda_0 = 0.01;  %(0, 10, 10000)% Precision (inverse variance) % the higher the lambda, the more the weight of prior beliefs (less flexible)
    prior_alpha = 0.5*mean(observed_data);     % Shape parameter % higher alpha , updated posterior would be more concentrated on the mean
    prior_beta = 1000*mean(observed_data);      % Scale parameter % higher beta, updated posterior more spreded.
    forgetting_factor = 0; %range of 0 to 1
    
    p_len = length(prior_mu_0_all);
    all_postMean = zeros(p_len,l);
    all_postVar = zeros(p_len,l);
    
    % Sequential updating and predicting
    for p = 1: p_len
        prior_mu_0 = prior_mu_0_all(p);
        prior_lambda_0 = 0.01;  % Precision (inverse variance) % the higher the lambda, the more the weight of prior beliefs (less flexible)
        prior_alpha = 0.5*mean(observed_data);     % Shape parameter % higher alpha , updated posterior would be more concentrated on the mean
        prior_beta = 1000*mean(observed_data); 
        for i = 1:l
            % Get the current observed data point
            data_point = observed_data(i);
            
            % Update the hyperparameters using the current data point
            posterior_alpha = prior_alpha + 0.5;
            posterior_beta = prior_beta + 0.5 * (data_point - prior_mu_0)^2 + 0.5 * measurement_variance_ratio*data_point + (0.5 * prior_lambda_0 * (data_point - prior_mu_0)^2) / (prior_lambda_0 + 1);
            posterior_mu = (prior_lambda_0 * prior_mu_0 + data_point) / (prior_lambda_0 + 1);
            posterior_lambda = prior_lambda_0 + 1;
            posterior_lambda = posterior_lambda * (1-forgetting_factor);
            
            % Use the updated parameters to predict the next data point
            predicted_mean = posterior_mu; %sample mean prediction which is the mean of normal distribution
            predicted_variance = posterior_beta / (posterior_alpha - 1); %the sample variance prediction which is the mean of posterior gamma distribution
            
            
            % Update prior hyperparameters for the next iteration
            prior_alpha = posterior_alpha;
            prior_beta = posterior_beta;  
            prior_mu_0 = posterior_mu;
            prior_lambda_0 = posterior_lambda;
            prior_variance = predicted_variance;

    
            all_postMean (p,i)=predicted_mean;
            all_postVar (p,i)=predicted_variance;
        end
    end
       
    all_PostVars (:,:,ii) = all_postVar;
    all_PostMeans (:,:,ii) = all_postMean;
    BayesianEstimate(ii) = round(mean(all_postMean(:,end), 1) + Stream(end));


    %% Prediction diff
    meanAngle = circ_mean(circ_mean(squeeze(oscillationDyns(Stream(end),1,:,:)), [], 2),[], 1);
                        
    if meanAngle <= 0
        OscillatorEstimate(ii)= round(Stream(end)+((abs(meanAngle)/(2*pi))*mean(skewed_dist)));
    else 
        OscillatorEstimate(ii)= round(Stream(end)+((2*pi-meanAngle)/(2*pi)*mean(skewed_dist)));
    end
    
    PredictionDiffmeanAngle(ii) = abs(OscillatorEstimate(ii) - BayesianEstimate(ii));


       
end 