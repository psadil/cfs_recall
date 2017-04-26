function domEye = checkOccularDominanceData( data )
%checkOccularDominanceData gives analyis of data: which eye saw the arrow
%more quickly on average

data = data(~strcmp(data.exitFlag, 'CAUGHT'),:);
data.rt = cell2mat(data.rt);

grpmeans = grpstats(data, 'eyePresent','nanmean', 'DataVars','rt');
[~, I] = max(grpmeans.nanmean_rt);
domEye = grpmeans.eyePresent(I);

end

