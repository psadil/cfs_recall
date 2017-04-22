function overwriteChecker = makeSubjectOverwriteChecker(directory, extension, debugLevel)
    % makeSubjectDataChecker function closer factory, used for the purpose
    % of enclosing the directory where data will be stored. This way, the
    % function handle it returns can be used as a validation function with getSubjectInfo to 
    % prevent accidentally overwritting any data. 
    function [valid, msg] = subjectDataChecker(value, ~)
        % the actual validation logic
        
        if ischar(value)
            subnum = str2double(value);
        else
            subnum = value;
        end
        if  isnan(subnum) || (subnum <= 0  && debugLevel <= 2);
            valid = false;
            msg = 'Subject Number must be greater than 0';
            return
        end
        
        filePathGlob = fullfile(directory, ['*Subject_', num2str(subnum), '*', extension]);
        if ~isempty(dir(filePathGlob)) && debugLevel <= 2
            valid= false;
            msg = strjoin({'Data file for Subject',  num2str(subnum), 'already exists!'}, ' ');                   
        else
            valid= true;
            msg = 'ok';
        end
    end

overwriteChecker = @subjectDataChecker;
end