function [echogram] = remove_bottom(echogram, radius)

remove_bottom = echogram.bottom.bottom_indexes;
ind = find(~isnan(echogram.bottom.bottom_indexes));


for i = 1:length(echogram.pings)
	Sv = echogram.mask(i).SvBot;
	[nRows, nCols] = size(Sv);
	for j=1:length(ind)

	
		x = ind(j);
		y = round(remove_bottom(x));
        	

		%% Remove upper part
			if (y > radius)
				Sv ( y-radius:y, x) = NaN;
			else
				Sv(1: y, x) = NaN;
            end
	end
	echogram.mask(i).SvBot = Sv;	

end

