function [echogram] = remove_falsebottom (echogram, radius)
% keyboard
%Adaptation of the data_removal function. Here, instead of removing data around the detected bottom we remove it around the detected false bottom. The radius of the data removal is chosen by the user.
%Input
%	-echogram
%	-radius: number of meters (if the binning is 1) that we will remove above and below the identified false_bottom
%Output
%	- echogram.pings(i).Sv: backscatter mattrix updated.


false_bottom = echogram.falsebottom.falsebottom_indexes;
ind = find(~isnan(false_bottom));



for i = 1:length(echogram.pings)
	Sv = echogram.mask(i).SvFalseBot;
	[nRows, nCols] = size(Sv);
	for j=1:length(ind)

	
		x = ind(j);
		y = round(false_bottom(x));
        	

		%% Remove upper part
			if (y > radius)
				Sv ( y-radius:y, x) = NaN;
			else
				Sv(1: y, x) = NaN;
			end
		%%Remove lower part
			if (y+radius <nRows)			
				Sv(y:y+radius,x ) = NaN;
			else
				Sv(y:end,x) = NaN;
			end
	end
	echogram.mask(i).SvFalseBot = Sv;	

end

