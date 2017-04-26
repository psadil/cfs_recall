function [roboRT, meanRT] = setupRobotResponses(transparency, sa, tType )
%setupRobotResponses Summary of this function goes here
% NOTE: best resolution of roboResps will be in mondrianHertz.



switch tType
    case 'CFS'
        meanRT = getMeanRT(transparency, sa.params.R, sa.params.K, sa.params.beta);
        wblParams = weibullParams(meanRT, 1);
        
        % sample a value for the robot
        roboRT = wblrnd(wblParams.scale, wblParams.shape) + (sa.params.R/1000);
        %
        %                 % incorporate knowledge of jitter in roboRT
        %                 roboRT = roboRT_raw + jitter;
    otherwise
        roboRT = 0;
        meanRT = NaN;
end

end

function params = weibullParams(mu, sd)

params.shape = (sd/mu) ^ -1.086;
params.scale = mu/(gamma(1+(1/params.shape)));

end

function meanRT = getMeanRT(intensity, R, K, beta)

%{
NOTE: because intensity in this case is fixed to be between [0,1], the max
RT will be (R + K*(exp(1/15)^-beta))/1000 and the min will be
(R + K*(exp(1/15)^-beta))/1000
%}

% meanRT = R + K*(exp(intensity)^-beta);
meanRT_msec = R + K*(intensity^-beta);
meanRT = meanRT_msec/1000;

end
