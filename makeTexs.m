function stims = makeTexs(item, window, type, varargin)


switch type
    case 'ARROW'
        offset_tip = 10;
        offset_inner = 100;
        window.shifts([1,3]) = window.shifts([1,3]) + [offset_inner, - offset_inner];
        
        fromY = window.yCenter;
        toY = window.yCenter;
        penWidth = 10;
        
        stims(1:2) = struct('tex',NaN([window.res.width, window.res.height]));
        for tex = 1:2
            
            if tex == 1 % right-facing
                fromX = window.shifts(1);
                toX = window.shifts(3);
                tipTopX = toX - offset_tip;
            else % left-facing
                fromX = window.shifts(3);
                toX = window.shifts(1);
                tipTopX = toX + offset_tip;
            end
            
            stims(tex).tex = Screen('OpenOffScreenWindow', window.screenNumber, ...
                window.bgColor);
            
            % horizontal part
            Screen('DrawLine', stims(tex).tex, BlackIndex(window.screenNumber),...
                fromX, fromY, ...
                toX, toY, penWidth);
            
            % upper head
            Screen('DrawLine', stims(tex).tex, BlackIndex(window.screenNumber), ...
                tipTopX, toY - offset_tip, ...
                toX, toY, penWidth);
            
            % lower head
            Screen('DrawLine', stims(tex).tex, BlackIndex(window.screenNumber), ...
                tipTopX, toY + offset_tip, ...
                toX, toY, penWidth);
        end
    case 'staircase'
        stims = struct('id', item);
        % grab all images
        [im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'staircase', ['Object', num2str(x.id)]), 'png'), ...
            stims, 'UniformOutput', 0);
        im_lowRes = cellfun(@(x) im2uint8(x), im, 'UniformOutput', false);
        alpha_lowRes = cellfun(@(x) im2uint8(x), alpha, 'UniformOutput', false);
        stims.image = cellfun(@(x, y) cat(3,x,y), im_lowRes, alpha_lowRes, 'UniformOutput', false);
        
        % make textures of images
        stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);
        
    case 'STUDY'
        stims = struct('id', item);
        % grab all images
        [im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'expt', 'whole', ['object', num2str(x.id), '_noBkgrd']), 'png'), ...
            stims, 'UniformOutput', 0);
        stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);
        
        % make textures of images
        stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);
    case 'NAME'
        stims = struct('id', item);
        stims.pair = varargin{1};
        
        % grab all images
        [im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'expt', 'apertures', ['object', num2str(x.id), '_paired', num2str(x.pair),'_ap1']), 'png'), ...
            stims, 'UniformOutput', 0);
        stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);
        
        % make textures of images
        stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);
    case 'NOISE'
        stims = struct('id', item);
        stims.pair = varargin{1};
        
        % grab all images
        [im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'expt', 'bullets', ['object', num2str(x.id), '_paired', num2str(x.pair),'_ap1']), 'png'), ...
            stims, 'UniformOutput', 0);
        stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);
        
        % make textures of images
        stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);
    case 'INSTRUCTION_CUE'
        stims = struct('id', item);
        stims.pair = varargin{1};
        
        % grab all images
        [im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'instructions', ['object', num2str(x.id), '_paired', num2str(x.pair),'_ap1']), 'png'), ...
            stims, 'UniformOutput', 0);
        stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);
        
        % make textures of images
        stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);
    case 'INSTRUCTION_NOISE'
        stims = struct('id', item);
        stims.pair = varargin{1};
        
        % grab all images
        [im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
            'stims', 'instructions', ['object', num2str(x.id), '_bullet']), 'png'), ...
            stims, 'UniformOutput', 0);
        stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);
        
        % make textures of images
        stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);
end


end