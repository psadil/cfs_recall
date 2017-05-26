function noiseTexes = makeNoiseTex(window)
nNoiseImgs = 50;

noiseTexes(1:nNoiseImgs) = struct('tex',NaN);
for img = 1:nNoiseImgs

    noiseImg = (50*rand(window.noiseTexesRect(3) - window.noiseTexesRect(1),...
        window.noiseTexesRect(3) - window.noiseTexesRect(1)) + 128);
    
    noiseTexes(img).tex = Screen('MakeTexture', window.pointer, noiseImg);
end

end
