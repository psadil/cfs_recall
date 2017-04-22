function [ data ] = experimentWrapper( input )
%experimentWrapper receives input about subject and produces that subject's
% data

Screen('DrawTexture', window, arrowTexture);
Screen('DrawingFinished', window);
Screen('Flip', window);
WaitSecs(2);

    

end

function DrawArrowToOffScreen()

arrowTexture = makeArrowTex(screenNumber, winRect(3)/2, winRect(4)/2, winRect(3)/2 - 100, winRect(4)/2);



sca;
end
