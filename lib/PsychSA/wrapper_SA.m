function [transparency, trial_SA] = wrapper_SA(data, trial, sa, trial_SA, expParams)

% This function helps implement two pieces of experimental logic.
% First, the transparency on null trials is automatically set to 0.
% Second, the overall data table is filtered so that we're only
% dealing with non-null trials. The SA algorithm doesn't need to
% see those trials for which participants weren't supposed to
% respond!

if strcmp(data.tType{trial},'NULL')
    transparency = 0;
elseif strcmp(data.tType{trial},'CFS')
    data_SA = data(~strcmp(data.tType,'NULL'),:);
    if trial_SA == 1
        transparency = sa.params.x1;
    elseif strcmp(data_SA.exitFlag{trial_SA-1}, 'SPACE')
        transparency = data_SA.transparency(trial_SA-1);
    else
        transparency_log = ...
            SA(log(data_SA.transparency(trial_SA-1)),...
            trial_SA, data_SA.rt(trial_SA-1), sa);
        % need to convert transparency scale
        transparency = exp(transparency_log);
    end
    trial_SA = trial_SA + 1;
    % but, we can't have transparency greater than 1
    transparency = min(1, transparency);
    % to keep the rate constant, we need to alter the resolution of
    % the value chosen
    %     transparency = transparency + mod(1/expParams.mondrianHertz,transparency);
    % finally can't have value less than 1/mondrianHertz
    transparency = max(transparency, 1/expParams.mondrianHertz);
end

end
