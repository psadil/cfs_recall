function [transparency, sa] =...
    wrapper_SA(data, trial, sa, expParams)

% This function helps implement two pieces of experimental logic.
% First, the transparency on null trials is automatically set to 0.
% Second, the overall data table is filtered so that we're only
% dealing with non-null trials. The SA algorithm doesn't need to
% see those trials for which participants weren't supposed to
% respond!

switch data.tType{trial}
    case {'CATCH', 'NOT STUDIED'}
        transparency = 0;
    case 'BINOCULAR'
        transparency = 1;
    case 'CFS'
        if sa.values.trial == 1
            transparency = sa.params.x1;
        elseif strcmp(sa.results.exitFlag(sa.values.trial-1), 'NOSEE_ON_CFS')
            transparency = sa.results.transparency(sa.values.trial-1);
            sa.values.trial = sa.values.trial - 1;
        else
            [sa, transparency_log] = ...
                SA(log(sa.results.transparency(sa.values.trial-1)),...
                sa.values.trial, sa.results.rt(sa.values.trial-1), sa);
            % need to convert transparency scale
            transparency = exp(transparency_log);
        end
        % but, we can't have transparency greater than 1
        transparency = min(1, transparency);
        % to keep the rate constant, we need to alter the resolution of
        % the value chosen
        %     transparency = transparency + mod(1/expParams.mondrianHertz,transparency);
        % finally can't have value less than 1/mondrianHertz
        transparency = max(transparency, 1/expParams.mondrianHertz);
        sa.results.transparency(sa.values.trial) = transparency;
        
        sa.values.trial = sa.values.trial + 1;
end


end
