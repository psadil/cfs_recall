function stims = makeTexs(item, window)

stims = struct('id', item);

% grab all images
[im, ~, alpha] = arrayfun(@(x) imread(fullfile(pwd,...
    'stims', 'expt', 'whole', ['object', num2str(x.id), '_noBkgrd']), 'png'), ...
    stims, 'UniformOutput', 0);
stims.image = cellfun(@(x, y) cat(3,x,y), im, alpha, 'UniformOutput', false);

% make textures of images
stims.tex = arrayfun(@(x) Screen('MakeTexture',window.pointer,x.image{:}), stims);

end