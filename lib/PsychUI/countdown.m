function countdown(text, start, speed, window, constants)
    times = start:-1:1;
    wakeup = Screen('Flip', window);
    for i = times
        message = strjoin({text, num2str(i)}, '\n\n');
        DrawFormattedText(window, message, 'center', 'center');
        vbl = Screen('Flip', window, wakeup + (constants.ifi/2));
        wakeup = WaitSecs('UntilTime', vbl + speed - constants.ifi);
    end
end