function dydt=oscillatorModel(t, y, natFreq, tspan, stimSequence, modelParams, varargin)
% oscillator model for numerical integration, with fixed period natural frquency (f)
% modelParams: [phase correction, bifurcation, saturation]
% must integrated with a fixed step ode solver (e.g. ode4 and not ode45)

f=natFreq;
c=modelParams(1);
a=modelParams(2);
theta=y(1);
r=y(2);
angleNoiseStd=0;
sampRate=1/(tspan(2)-tspan(1));

optimalAngle=0;

if length(modelParams)==2 % if saturation parameter not given, assume attractor at r=1
    b=-a;
else
    b=modelParams(3);
end

c=c*sampRate; % scale by sampling rate

currStimVal=stimSequence(tspan==t);
dydt=zeros(2,1);
if isempty(currStimVal) % just in case
    dydt(1)=2*pi*f;
    dydt(2)=0;
else
    dydt(1)=2*pi*f-currStimVal*c*sin(theta-optimalAngle)/r; % phase
%     dydt(1)=2*pi*f-currStimVal*c*sampRate*sin(theta)/r+angleNoiseStd*randn; % phase
    dydt(2)=r*(a+b*r^2)+c*currStimVal*cos(theta); % amplitude
end
