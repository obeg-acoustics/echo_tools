function [echogram] = cut_echogram(echogram,rangelim)
% This function cuts echograms below the range limit

for k = 1:length(echogram.pings)

	ind = find(echogram.pings(k).range<=rangelim); 
	tmp_range = echogram.pings(k).range(ind);
	tmp_Sv    = echogram.pings(k).Sv(ind,:);

 	echogram.pings(k).range = tmp_range;
	echogram.pings(k).Sv = tmp_Sv;
end

return
