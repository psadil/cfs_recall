function [  ] = kludgeStart( varargin )
%kludgeStart Superstititious workaround for VBLSyncTest failures


screenNumber=max(Screen('Screens'));
window = Screen('OpenWindow',screenNumber);

% test refresh rate
fps=Screen('FrameRate',window);
if abs(fps - 120) > 2
    instr = 1;
else
    instr = 0;
end

sca;

% if error in refresh rate, correct now
if instr
    errordlg('Please set the refresh rate to 120');
end


end

