function [response, rt, exitFlag] = ...
    wrapper_keyLogic(keys_pressed, press_times, tStart)
% There should ideally be only one, keypress ever. If there happens
% to be more than one keypress, only take the first one.
% Add the direction just pressed to the input
% string, and record the timestamp of its keypress.
% For arrow response, this will produce either 'left' or 'right'
% rt = NaN;
exitFlag = {'OK'};

if any(keys_pressed == 102)
    key = 39; %RightArrow
    rt = press_times(102) - tStart;
elseif any(keys_pressed == 100)
    key = 37; %LeftArrow
    rt = press_times(100) - tStart;
else
    key = keys_pressed(1);
    rt = press_times(key) - tStart;
end
response = {KbName(key)};
if any(keys_pressed==KbName('ESCAPE'))
    exitFlag = {'ESCAPE'};
elseif any(keys_pressed==KbName('SPACE'))
    exitFlag = {'SPACE'};
end
end
