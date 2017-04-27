function [] = waitForSpace(keys,constants,responseHandler)

KbQueueCreate(constants.device, keys.space);
KbQueueStart(constants.device);

while 1
    
    [keys_pressed, ~] = responseHandler(constants.device, '\SPACE');
    
    if ~isempty(keys_pressed)
        break;
    end
end

KbQueueStop(constants.device);
KbQueueFlush(constants.device);
KbQueueRelease(constants.device);
end
