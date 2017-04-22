function keys = setupKeys( expt )


codes = zeros(1,256);
keys.escape = codes;
keys.escape(KbName('ESCAPE')) = 1;
keys.enter = codes;
keys.enter(KbName({'Return'})) = 1;

switch expt
    case 'occularDominance'
        keys.arrows = codes;
        keys.arrows(KbName({'4','6'})) = 1;
    
    case 'staircase'
        keys.space = codes;
        keys.space(KbName({'space'})) = 1;        
        keys.pas = codes;
        keys.pas(KbName({'0','1','2','3','0)','1!','2@','3#'})) = 1;
        
    case 'CFSRecall'
        keys.space = codes;
        keys.space(KbName({'space'})) = 1;        
        keys.pas = codes;
        keys.pas(KbName({'0','1','2','3','0)','1!','2@','3#'})) = 1;
end


end

