function drawMaskedStimulus(window, prompt, eyes,...
    imageTex, mondrianTex, alpha_mondrian, alpha_tex, where, maskEye)

for eye = 1:2
    Screen('SelectStereoDrawBuffer',window.pointer,eye-1);
    
    if all(eyes)
        Screen('DrawTexture', window.pointer, mondrianTex,[],[],[],[],alpha_mondrian);
        Screen('DrawTexture', window.pointer, imageTex,[],where,[],[],alpha_tex);
    elseif eyes(eye)
        Screen('DrawTexture', window.pointer, imageTex,[],where,[],[],alpha_tex);
    elseif any(eyes) && ~eyes(eye)
        % draw Mondrians
        Screen('DrawTexture', window.pointer, mondrianTex,[],[],[],[],alpha_mondrian);
    elseif ~any(eyes)
        if eye == 2 && strcmp(maskEye,'right')
            Screen('DrawTexture', window.pointer, mondrianTex,[],[],[],[],alpha_mondrian);
        end
    end
    
    % small white fixation square
    Screen('DrawLines', window.pointer, window.fixCrossCoords,...
        2, window.white, window.center, 2);
    
    % prompt participant to respond
    DrawFormattedText(window.pointer, prompt, 'center', window.winRect(4)*.8);
end
Screen('DrawingFinished',window.pointer);

end