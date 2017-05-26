function handlerFcn = makeInputHandlerFcn(handlerName)

valid_types = {'user','namingRobot_good', 'simpleKeypressRobot'};
assert(ismember(handlerName, valid_types),...
    ['"handlerType" argument must be one of the following: ' strjoin(valid_types,', ')])

if ~strcmp(handlerName, 'user')
    
    rob = java.awt.Robot;
    switch handlerName
        case 'freeResponseRobot'
            n = 1;
            handlerFcn = @namingRobot_good;
            
        case 'simpleKeypressRobot'
            handlerFcn = @SimpleKeypressRobot;
            
        otherwise
            error(['Unknown handlerName "' handlerName '"']);
    end
    
else
    handlerFcn = @checkKeys;
end

    function [keys_pressed, press_times] = checkKeys(device, varargin)
        % The response string and RT vector are returned (updated with any input
        % given by the participant) as well as the advance and redraw flags.
        
        % Check the KbQueue for presses
        [ pressed, press_times]=KbQueueCheck(device);
        if pressed
            % find the keycode for the keys pressed since last check
            keys_pressed = find(press_times);
            % sort the recorded press time to find their linear position
            [~, ind] = sort(press_times(press_times~=0));
            % Arrange the keycodes according to the order they were pressed
            keys_pressed = keys_pressed(ind);
        else
            keys_pressed = [];
        end
    end

    function [keys_pressed, press_times] = namingRobot_good(device, answer)
        
        % This function is a wrapper around checkKeys, which provides
        % automatic keyboard input by simulating a keypress of each character in the given response string
        % with Java Robot object instead of waiting for a human.
        %
        % The tricky bit here is that it doesn't loop over each character in
        % the string. We want the chance to poll the keyboard queue in between
        % keypresses, in order to support incremental drawing of the text
        % string, the way the user would expect it to work. If we did loop over
        % the answer to "type in", the word would show up all at once, which is
        % not the way we would want it to work with a human typing responses
        % in real experiment.
        % Instead, this function is a closure and we share a stateful indexing variable n
        % with the parent function, makeInputHandlerFcn. n starts off set to 1 in the
        % parent function. If n is less than or equal to  the length of the answer,
        % we construct the robot press and release calls for that character, hand off
        % to the actual input handler function to record it, and increment the indexing
        % variable n (e.g. n = n + 1 =2). This increment is remembered the next
        % time we enter the function, because this function is a closure.
        %
        % When n grows larger than the length of the answer string, we press
        % and release the Enter key to confirm the previously recorded input
        % and advance. Before returning, n is reset to 1, and this reset is
        % remembered the next time we enter this function (which should be for
        % a new answer to input) and so we begin with inputing the first character of
        % the new answer.
        
        
        if strcmp(answer, 'SPACE')
            rob.keyPress(java.awt.event.KeyEvent.VK_SPACE);
            rob.keyRelease(java.awt.event.KeyEvent.VK_SPACE);
            n = 1;
        elseif n <= length(answer)
            WaitSecs(1/10);
            eval([ 'rob.keyPress(java.awt.event.KeyEvent.VK_', upper(answer(n)), ');' ]);
            eval([ 'rob.keyRelease(java.awt.event.KeyEvent.VK_', upper(answer(n)), ');' ]);
            n = n + 1;
        else
            rob.keyPress(java.awt.event.KeyEvent.VK_ENTER);
            rob.keyRelease(java.awt.event.KeyEvent.VK_ENTER);
            n = 1;
        end
        
        [keys_pressed, press_times] = checkKeys(device);
    end

    function [keys_pressed, press_times] = SimpleKeypressRobot(device, answer, varargin)
        
        switch nargin
            case 3
                if varargin{1}
                    inputemu('key_normal',answer);
                end
            case 2
                inputemu('key_normal',answer);
        end
        
        %         if strcmp(answer, 'SPACE')
        %             rob.keyPress(java.awt.event.KeyEvent.VK_SPACE);
        %             rob.keyRelease(java.awt.event.KeyEvent.VK_SPACE);
        %         elseif strcmp(answer, 'LeftArrow')
        %             %             rob.keyPress(java.awt.event.KeyEvent.VK_LEFT);
        %             %             rob.keyRelease(java.awt.event.KeyEvent.VK_LEFT);
        %             inputemu('\LEFT');
        %         elseif strcmp(answer, 'RightArrow')
        %             %             rob.keyPress(java.awt.event.KeyEvent.VK_RIGHT);
        %             %             rob.keyRelease(java.awt.event.KeyEvent.VK_RIGHT);
        %             inputemu('\RIGHT');
        %         else
        %             eval([ 'rob.keyPress(java.awt.event.KeyEvent.VK_', upper(answer(1)), ');' ]);
        %             eval([ 'rob.keyRelease(java.awt.event.KeyEvent.VK_', upper(answer(1)), ');' ]);
        %         end
        
        [keys_pressed, press_times] = checkKeys(device);
    end


end