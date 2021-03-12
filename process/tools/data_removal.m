function [echogram] = data_removal(echogram, meters_above_bottom_removal, upper_layer_height)

vertical_binsize = nanmean(diff(echogram.pings(1).range));

% Firstly, we remove all the data that are below the bottom, and a certain height above it. The user chooses this height, it can be zero.

ind = find(~isnan(echogram.bottom.bottom_indexes));

indexes_above_bottom_removal = 0;
variable1 = 0;
while variable1 < meters_above_bottom_removal
	variable1 = variable1 + vertical_binsize;
	indexes_above_bottom_removal = indexes_above_bottom_removal + 1;
end


for i=1:length(echogram.pings)
	for j=1:length(ind)
		echogram.pings(i).Sv(echogram.bottom.bottom_indexes(ind(j))-indexes_above_bottom_removal:end,ind(j)) = NaN;
	end
end

% Then, we remove the very upper layer whose signal is extremely strong.

indexes_upper_layer_removal = 0;
variable2 = 0;

while variable2 < upper_layer_height
	variable2 = variable2 + vertical_binsize;
	indexes_upper_layer_removal = indexes_upper_layer_removal + 1;
end

for i=1:length(echogram.pings)
	for j=1:length(ind)
		echogram.pings(i).Sv(1:indexes_upper_layer_removal,:) = NaN;
	end
end

