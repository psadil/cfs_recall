function [] = giveInstruction(window, keys, responseHandler, constants, expt, expParams)


%%
switch expt
    case 'occularDominance'
        showPromptAndWaitForResp(window, 'This first phase is to get you comfortable wearing the glasses',...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, 'Use the arrow keys to say which direction you think the arrow faced.',...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, 'Keep your eyes focused on the center white cross',...
            keys,constants,responseHandler);
        %%
    case 'staircase'
        showPromptAndWaitForResp(window, 'This next part of the experiment is practice',...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, 'In this phase, you will see hidden objects emerge from flashing squares',...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, ['When you are certain that an object has emerged, press the ''j'' key.\n',...
            'Please press the key as soon as you are certain that an object has appeared.\n',...
            'But, do NOT wait until you can identify the object.'],...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, ['After each trial, you will be asked about how well you could see the object.\n\n',...
            'no image detected - 0\n',...
            'possibly saw, couldn''t name - 1\n',...
            'definitely saw, but unsure what it was (could possibly guess) - 2\n',...
            'definitely saw, could name - 3\n',...
            '\nYou should wait until you can give a response of 2\n',...
            'but respond before you would give a response of 3\n', ...
            '\nUse the keypad to indicate your response\n'],...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, ['On some trials, there will be no object\n',...
            'If you think that there is no object, press ''f'''],...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, 'Finally, always keep your eyes focused on the center white cross',...
            keys,constants,responseHandler);
        %%
    case 'CFSRecall'
        showPromptAndWaitForResp(window, 'This is the beginning of the main experiment.',...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, 'As before, you will see hidden objects emerge from flashing squares.',...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, ['When you are certain that an object has emerged, press the ''j'' key.\n',...
            'Please press the key as soon as you are certain that an object has appeared.\n',...
            'But, do NOT wait until you can identify the object.'],...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, ['HOWEVER, some objects will be easier to see.\n',...
            'Please study the details of these objects, as your memory for the details of these objects will be tested.\n',...
            'To help your memory, you will see all objects twice.'],...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, 'Finally, always keep your eyes focused on the center white cross.',...
            keys,constants,responseHandler);
        %%
    case 'TEST'
        
        showPromptAndWaitForResp(window, ['This is your first memory test in the experiment!\n',...
            'There are two sections.'],...
            keys,constants,responseHandler);
        showPromptAndWaitForResp(window, ['You will first see a part of an object\n',...
            'Some of these parts will come from objects that you studied, but others will be new\n',...
            'Your task will be to name the object that the part comes from.\n',...
            'Feel free to use your memory from the study list if you think it will help.\n',...
            '\nAn example will be shown on the next slide.'],...
            keys,constants,responseHandler);
        
        stims = makeTexs(212, window, 'INSTRUCTION_CUE',215);
        
        elicitCueName(window, responseHandler, stims.tex, keys.enter+keys.escape+keys.name+keys.bkspace+keys.space, constants, '\ENTER');
        Screen('Close', stims.tex);
        
        showPromptAndWaitForResp(window, ['In that case, the correct answer would have been ''lightswitch''\n',...
            'Type your responses with the keyboard, and press Enter when you have finished typing.'],...
            keys,constants,responseHandler);
        
        showPromptAndWaitForResp(window, ['You will then see an object emerge from visual noise.\n',...
            'The emerging object may or may not be the object whose part you will have just tried to name.\n',...
            'Your task is simply to indicate as soon as you can whether the objects are matching or mismatching.\n',...
            '\nAn Example will be shown on the next slide'],...
            keys,constants,responseHandler);
        
        noiseRect = ScaleRect(window.imagePlace, 2, 2);
        res = repelem(noiseRect(3) - noiseRect(1),2);
        noisetex = CreateProceduralNoise(window.pointer, res(1), res(2), 'Perlin', [0.5 0.5 0.5 1]);
        stims = makeTexs(212, window, 'INSTRUCTION_NOISE',215);
        elicitNoise(window, responseHandler, stims.tex, keys.mmm+keys.escape, expParams,...
            constants, 0, 1, 0, 'p', noisetex);
        Screen('Close', stims.tex);
        Screen('Close', noisetex);
        
        showPromptAndWaitForResp(window, ['When you think that the two objects are matching, press the ''p'' key\n',...
            'When you think that the two objects are mismatching, press the ''q'' key\n',...
            '\n(The correct answer to this example was ''p'', for matching)'],...
            keys,constants,responseHandler);
        
        showPromptAndWaitForResp(window, 'The first test phase will begin after you press SPACE',...
            keys,constants,responseHandler);
        
end

iti(window, 1);


end