function [  ] = drawFixation( window )

for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    Screen('DrawLines', window.pointer, window.fixCrossCoords,...
        2, window.white, window.center, 2);
%     Screen('FillRect',window.pointer,1,CenterRect([0 0 8 8],window.shifts));
end
Screen('DrawingFinished',window.pointer);
end

