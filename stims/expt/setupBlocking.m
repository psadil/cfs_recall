

t = readtable('stimPairings.csv');


[Lia, Locb] = ismember(t.pair1,t.pair2)

[tmpia, tmplocb] = arrayfun(@(x,y) ismember(x,y), t.pair2,(1:208)', 'UniformOutput',false);

out = t(t.pair2 > 105,:);


count = 0;
while count < 104

    for item = 1:208
       if t.pair2(item)
           
    end
    
    
    
    count = count+1;
end

out = t(~ismember(t.pair2,t.pair2))