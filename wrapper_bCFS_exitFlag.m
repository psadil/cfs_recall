function [ pas, esc ] = wrapper_bCFS_exitFlag(exitFlag, tType,...
    response, window, keys, constants, responseHandler)

pas = {''};
esc = 0;

switch exitFlag
    case 'ESCAPE'
        esc = 1;
%     case 'CAUGHT'
%         showPromptAndWaitForResp(window, 'Please only hit ''f'' when an image is present!',...
%             keys, constants, responseHandler);
    case 'OK'
        switch tType
            case {'CATCH', 'Not Studied'}
                switch response
                    case 'f'
                        showPromptAndWaitForResp(window, 'Correct! No object was going to appear.',...
                            keys, constants, responseHandler);
                    case 'j'
                        showPromptAndWaitForResp(window, 'Incorrect! No object was going to appear.',...
                            keys, constants, responseHandler);
                    case 'NO RESPONSE'
                        showPromptAndWaitForResp(window, 'There was no item! Please stop searching sooner.',...
                            keys, constants, responseHandler);
                end
            case 'CFS'
                switch response
                    case 'f'
                        showPromptAndWaitForResp(window, 'Incorrect! An object was appearing.',...
                            keys, constants, responseHandler);
                    case 'j'
                        [pas,~,~] = elicitPAS(window, keys.pas, '2', constants, responseHandler);
                        showPromptAndWaitForResp(window, 'Correct! An object was appearing.',...
                            keys, constants, responseHandler);
                    case 'NO RESPONSE'
                        showPromptAndWaitForResp(window, 'There was an item! Please try to find it sooner.',...
                            keys, constants, responseHandler);
                end
        end
end


end

