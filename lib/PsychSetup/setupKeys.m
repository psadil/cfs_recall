function keys = setupKeys( expt )


codes = zeros(1,256);
keys.escape = codes;
keys.escape(KbName('ESCAPE')) = 1;
keys.bCFS = codes;
keys.bCFS(KbName({'f','j'})) = 1;
keys.space = codes;
keys.space(KbName({'space'})) = 1;

switch expt
    case 'occularDominance'
        keys.arrows = codes;
        keys.arrows(KbName({'4','6','RightArrow','LeftArrow'})) = 1;
        
    case 'staircase'
        keys.pas = codes;
        keys.pas(KbName({'0','1','2','3','0)','1!','2@','3#'})) = 1;
        
    case 'CFSRecall'
        keys.enter = codes;
        keys.enter(KbName({'return'})) = 1;
        keys.pas = codes;
        keys.pas(KbName({'0','1','2','3','0)','1!','2@','3#'})) = 1;
        keys.mmm = codes;
        keys.mmm(KbName({'q','p'})) = 1;
        keys.name = codes;
        keys.name(KbName({'a','b','c','d','e','f','g','h','i','j','k','l','m', ...
            'n','o','p','q','r','s','t','u','v','w','x','y','z'})) = 1;
        keys.bkspace = codes;
        keys.bkspace(KbName({'BackSpace'})) = 1;
    case 'CFSgonogo'
        keys.enter = codes;
        keys.enter(KbName({'return'})) = 1;
        keys.pas = codes;
        keys.pas(KbName({'0','1','2','3','0)','1!','2@','3#'})) = 1;
        keys.name = codes;
        keys.name(KbName({'a','b','c','d','e','f','g','h','i','j','k','l','m', ...
            'n','o','p','q','r','s','t','u','v','w','x','y','z'})) = 1;
        keys.bkspace = codes;
        keys.bkspace(KbName({'BackSpace'})) = 1;
end


end

