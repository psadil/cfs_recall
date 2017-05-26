function [ pas, sa, esc ] = wrapper_bCFS_exitFlag(exitFlag, tType, rt,...
    response, sa, window, keys, constants, responseHandler)

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
%                         sa.results.exitFlag(sa.values.trial-1) = {'OK'};
                        showPromptAndWaitForResp(window, 'Correct! No object was going to appear.',...
                            keys, constants, responseHandler);
                    case 'j'
%                         sa.results.exitFlag(sa.values.trial-1) = {'SAW_CATCH'};
                        showPromptAndWaitForResp(window, 'Incorrect! No object was going to appear.',...
                            keys, constants, responseHandler);
                    case 'NO RESPONSE'
%                         sa.results.exitFlag(sa.values.trial-1) = {'NO_RESP_CATCH'};
                        showPromptAndWaitForResp(window, 'There was no item! Please stop searching sooner.',...
                            keys, constants, responseHandler);
                end
            case 'CFS'
                switch response
                    case 'f'
                        sa.results.exitFlag(sa.values.trial-1) = {'NOSEE_ON_CFS'};
                        showPromptAndWaitForResp(window, 'Incorrect! An object was appearing.',...
                            keys, constants, responseHandler);
                    case 'j'
%                         sa.results.exitFlag(sa.values.trial-1) = {'OK'};
                        sa.results.rt(sa.values.trial-1) = rt;
                        [pas,~,~] = elicitPAS(window, keys.pas, '2', constants, responseHandler);
                        showPromptAndWaitForResp(window, 'Correct! An object was appearing.',...
                            keys, constants, responseHandler);
                    case 'NO RESPONSE'
%                         sa.results.exitFlag(sa.values.trial-1) = {'NO_RESP_CFS'};
                        sa.results.rt(sa.values.trial-1) = 30;
                        showPromptAndWaitForResp(window, 'There was an item! Please try to find it sooner.',...
                            keys, constants, responseHandler);
                end
        end
end


end

