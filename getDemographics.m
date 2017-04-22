function [out] = getDemographics(constants)

%--------------------------------------------------------%
% Onscreen script to record race/ethnic/sex demographics %
% for Matlab                                             %
% Updated 09/21/2015                                     %
%--------------------------------------------------------%

%{
Purpose:
A Matlab script which will generate a set of dialog boxes that ask
participants an assortment of questions regarding demographics (in
compliance with NIH requirements).

Requirements:
An installation of Matlab

Outputs:
A text file 'Demographics.txt'

Notes:
Forthcoming

%%% TO DO %%%
- Forthcoming
%}

% Set the width and height of the dialog box
boxSize = [ 250, 100 ];
% Create a cellstring array to store the answers
output = [ {'Sex'} {'Ethnicity'} {'Race'} ];
out = output;

% Display an initial message regarding the NIH
headerNIH = sprintf('The National Institute of Health requests basic demographic information (sex, ethnicity, and race) for clinical or behavioral studies, to the extent that this information is provided by research participants.\n\nYou are under no obligation to provide this information. If you would rather not answer these questions, you will still receive full compensation for your participation in this study and the data you provide will still be useful for our research.');
waitfor( msgbox(headerNIH,'Demographics') ); % Must close message to continue

%%% Sex at birth %%%

% Define the initial prompt
stringPrompt = [ {sprintf('1) Sex at birth:')} {''} ];

% Define the choices that can be selected
Choices = [ {'Female'} {'Male'} {'Other'} ];

% Create a list dialog box and determine the selection
sel = listdlg('PromptString',stringPrompt,...
    'SelectionMode','single',... % So people can only pick one option
    'ListString',Choices,...
    'ListSize',boxSize,...
    'CancelString','Rather not say');

% Save output
if ( isempty(sel) )
    output{1} = 'Sex, Rather not say';
    out{1} = {'Rather not say'};
else
    output{1} = [ 'Sex, ' Choices{sel} ];
    out{1} = Choices{sel};
end

%%% Ethnicity %%%

% Define the initial prompt
stringPrompt = [ {sprintf('2) Ethnicity:')} {''} ];

% Define the choices that can be selected
Choices = [ {'Hispanic or Latino'} {'Not Hispanic or Latino'} ];

% Create a list dialog box and determine the selection
sel = listdlg('PromptString',stringPrompt,...
    'SelectionMode','single',...
    'ListString',Choices,...
    'ListSize',boxSize,...
    'CancelString','Rather not say');

% Save output
if ( isempty(sel) )
    output{2} = 'Ethnicity, Rather not say';
    out{2} = 'rather not say';
else
    output{2} = [ 'Ethnicity, ' Choices{sel} ];
    out{2} = Choices{sel};
end

%%% Race %%%

% Define the initial prompt
stringPrompt = [ {sprintf('3) Race:')} {''} ];

% Define the choices that can be selected
Choices = [ {'American Indian/Alaska Native'} {'Asian'} {'Native Hawaiian or Other Pacific Islander'} {'Black or African American'} {'White'} ];

% Create a list dialog box and determine the selection
sel = listdlg('PromptString',stringPrompt,...
    'SelectionMode','single',...
    'ListString',Choices,...
    'ListSize',boxSize,...
    'CancelString','Rather not say');

% Save output
if ( isempty(sel) )
    output{3} = 'Race, Rather not say';
    out{3} = 'rather not say';
else
    output{3} = [ 'Race, ' Choices{sel} ];
    out{3} = Choices{sel};
end

% Record output to a text file
fid = fopen([constants.subDir,  '\demographics.txt'], 'wt' );
for i = 1:3
    fprintf( fid, sprintf( [ output{i} '\n' ] ) );
end
fclose(fid);

% Cleans up workspace
% clear boxSize output headerNIH stringPrompt Choices sel output i ans fid

end
