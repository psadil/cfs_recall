function [ output ] = demographics(directory)
%--------------------------------------------------------%
% Onscreen script to record race/ethnic/sex demographics %
% for Matlab                                             %
% Updated 1/22/2016                                      %
%--------------------------------------------------------%

%{
A Matlab script which will generate a set of dialog boxes that ask 
participants an assortment of questions regarding demographics (in 
compliance with NIH requirements).

Requirements:
An installation of Matlab

Outputs:
return a cell array with the participants answers as well as writing them to 
% a text file called 'demographics.csv'

Authors: 
Kevin Potter & Will Hopper
%}

try
    dims = get( groot, 'Screensize' ); % works in > 2014b
catch 
    dims = get( 0, 'Screensize' ); 
end

button_size = [100, 30];
fields = struct;
padding_top = 30;
padding_side = 50;
width = 500;
height = 600;
rect = [dims(3)/2 - width/2, dims(4)/2 - height/2, width, height]; % left top width height
fig = dialog('Name', 'NIH Demographics', 'Position', rect, ... 
             'ToolBar','None','MenuBar','none', 'NumberTitle','off', 'Visible','off');
% initial message regarding the NIH
instructions = {'The National Institute of Health requests basic demographic information (sex, ethnicity, and race) for clinical or behavioral studies, to the extent that this information is provided by research participants.', ...
    '', ...
    'You are under no obligation to provide this information. If you would rather not answer these questions, you will still receive full compensation for your participation in this study and the data you provide will still be useful for our research.'};
uicontrol(fig, 'Style', 'text', 'String', instructions, 'Position', [padding_side height - padding_top - 200, width-padding_side*(1.5), 200], ...
    'HorizontalAlignment','left', 'FontSize', 13);

%%% Sex at birth %%%
uicontrol(fig, 'Style', 'text', 'String', '1) Sex at birth:', 'Position', [padding_side height - padding_top - 230, width-padding_side*(1.5), 30], ...
    'HorizontalAlignment','left', 'FontSize', 13);
fields.sex = uicontrol(fig, 'Style', 'listbox', 'String', {'Female', 'Male','Other','Rather not say'}, ...
    'Position', [padding_side height - padding_top + 5 - 290, width-padding_side*(1.5), 60]);

%%% Ethnicity %%%
uicontrol(fig, 'Style', 'text', 'String', '2) Ethnicity:', 'Position', [padding_side height - padding_top - 330, width-padding_side*(1.5), 30], ...
    'HorizontalAlignment','left', 'FontSize', 13);
fields.eth = uicontrol(fig, 'Style', 'listbox', 'String', {'Hispanic or Latino', 'Not Hispanic or Latino', 'Rather not say'}, ...
    'Position', [padding_side height - padding_top + 5 - 375, width-padding_side*(1.5), 45]);

%%% Race %%%
races = {'American Indian/Alaska Native', 'Asian', 'Native Hawaiian or Other Pacific Islander', 'Black or African American', 'White'};
uicontrol(fig, 'Style', 'text', 'String', '3) Race:', 'Position', [padding_side height - padding_top - 405, width-padding_side*(1.5), 30], ...
    'HorizontalAlignment','left', 'FontSize', 13);
fields.race = uicontrol(fig, 'Style', 'listbox', 'String', [races,{'Rather not say'}], ...
    'Position', [padding_side height - padding_top + 5 - 495, width-padding_side*(1.5), 90]);

% Continue Button
uicontrol(fig, 'Style','pushbutton', 'String', 'Continue', 'Tag', 'RunBtn', 'Callback', @(varargin) uiresume(gcbf), ...
          'Pos', [(width/2) - button_size(1)/2, height-(height-20), button_size(1), button_size(2)]);

% Show the dialog and wait for intput
set(fig, 'Visible', 'on')
uiwait(fig);

% Write the outout to disk
if ishghandle(fig)
    input = extract(fields);
    output = { strjoin(fieldnames(input), ','); strjoin(struct2cell(input), ',')};
    % Record output to a text file
    fid = fopen( fullfile(directory,['demographics_', input.id, '.csv']), 'wt' );
    for i = 1:size(output,1)
      fprintf( fid, [ output{i} '\n' ]);
    end
    fclose(fid);
else
    output = [];
end
delete(gcbf)

end

function input =  extract(fields)
    input = structfun(@(s) cell2mat(s.String(s.Value)), fields, 'UniformOutput', false);
    
    if usejava('jvm')
        input.id = char(java.util.UUID.randomUUID());
    else
        id = num2str(randperm(1000));
        id = strrep(id, '  ', '');
        input.id = id(randperm(36));
    end
end
