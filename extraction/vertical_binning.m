function [echogram] = vertical_binning(echogram, vertical_binsize)

% This function will bin the echogram data along the depth/vertical by not modifying the horizontal step (ping)

% Input :
%	- echogram : what we want to bin
%	- vertical_binsize : size (m) of the new range step
% Output :
%	- binned echogram



% We make sure that all the echograms of all the frequencies have the same size in range

depth_length = length(echogram.pings(1).range);
for i=2:length(echogram.pings)
	if length(echogram.pings(i).range) > depth_length
		depth_length = length(echogram.pings(i).range);
	end
end

for i=1:length(echogram.pings)
	if depth_length > size(echogram.pings(i).Sv,1)
		echogram.pings(i).Sv 	= [echogram.pings(i).Sv; NaN*ones(depth_length  - length(echogram.pings(i).Sv(:,1)), length(echogram.pings(i).time))];
	end
end


% In the case ranges are different according to the frequencies, we choose the longest range vector in echogram so that our new grid is as universal as possible
maxrange = max(echogram.pings(1).range);
for i=2:length(echogram.pings)
	if max(echogram.pings(i).range) > maxrange
		maxrange = max(echogram.pings(i).range);
	end
end



% This loop creates a new range vector sized with the vertical_binsize parameter

xb = 0;
rangebin = [xb];
while xb < maxrange
	xb = xb + vertical_binsize;
	rangebin = [rangebin, xb];
end
if rangebin(end) ~= maxrange
	rangebin = rangebin(1:end-1);
end


% This loop finds the groups of indexes corresponding to the Sv vector (via range vector) that will be gathered and averaged in the bins


%for i=1:length(echogram.pings) % Frequency loop
%	Svbin = zeros(length(rangebin)-1, length(echogram.pings(i).time))*NaN; % We initialize the Svbin matrix at the beginning of each frequency loop
%	for j=1:length(echogram.pings(i).time) % Ping loop
%		for k=1:length(rangebin)-1 % Depth/range loop
%			index = [];
%			index = find((echogram.pings(i).range >= rangebin(k))&(echogram.pings(i).range < rangebin(k+1)));
%			Svbin(k,j) = 10*log10(nanmean(10.^(echogram.pings(i).Sv(index,j)/10))); % We mean the sv, not the Sv because it's a logarithmic scale.
%		end
%	end
%	echogram.pings(i).Sv = Svbin
%end



%deltaR1 = echogram.pings(1).range(2) - echogram.pings(1).range(1);

for m = 1:length(echogram.pings) % Frequency loop
	Svbin = zeros(length(rangebin)-1, length(echogram.pings(m).time))*NaN;

	% First iteration
	var = 0;
	weight_vector = [];
	Svindex = 0;
	j = 0;
	while var < rangebin(2)
                deltaR1 = echogram.pings(m).range(j+2) - echogram.pings(m).range(j+1);
		var = var + deltaR1;
		j = j+1;
	end
	if var == rangebin(2)
		for k=1:j
                        deltaR1 = echogram.pings(m).range(k+1) - echogram.pings(m).range(k);
			weight_vector = [weight_vector, deltaR1];
			Svindex = Svindex + 1;
		end
		weight_matrix = repmat(weight_vector', 1, length(echogram.pings(m).time));
% 		Svbin(1,:) = nansum(weight_matrix.*echogram.pings(m).Sv(1:Svindex,:))/vertical_binsize;

%        Svbin(1,:) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(1:Svindex,:)/10))));
        Svbin(1,:) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(1:Svindex,:)/10),1)/(size(echogram.pings(m).Sv(1:Svindex,:),1)));
%        Svbin(1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(1:Svindex,:)/10)))/vertical_binsize);
		%Svindex = Svindex + 1;
	else
		for k=1:j-1
                        deltaR1 = echogram.pings(m).range(k+1) - echogram.pings(m).range(k);      
			weight_vector = [weight_vector, deltaR1];
			Svindex = Svindex + 1;
	 	end
                deltaR1 = echogram.pings(m).range(j+1) - echogram.pings(m).range(j);
		weight_vector = [weight_vector, rangebin(2)-(var-deltaR1)];
		Svindex = Svindex + 1;
		weight_matrix = repmat(weight_vector', 1, length(echogram.pings(m).time));
%         Svbin(1,:) = nansum(weight_matrix.*echogram.pings(m).Sv(1:Svindex,:))/vertical_binsize;
%                Svbin(1,:) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(1:Svindex,:)/10))));
                Svbin(1,:) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(1:Svindex,:)/10),1)/(size(echogram.pings(m).Sv(1:Svindex,:),1)));
%		Svbin(1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(1:Svindex,:)/10)))/vertical_binsize);
	end
	Svindex1 = Svindex;
	Svindex2 = Svindex;

	for i=3:length(rangebin)
%if i == 135
%	keyboard
%end
		weight_vector = [];
		weight_matrix = [];
		if var ~= rangebin(i-1)
			weight_vector = [weight_vector, var-rangebin(i-1)];
		end
		j = 0;
		while (var < rangebin(i))&&(j+Svindex1+2<depth_length)
                        deltaR1 = echogram.pings(m).range(j+Svindex1+2) - echogram.pings(m).range(j+Svindex1+1);
			var = var + deltaR1;
			j = j+1;
		end
		if (var == rangebin(i))&&(j~=0)
%keyboard
			for k=1:j
                                deltaR1 = echogram.pings(m).range(k+Svindex1+1) - echogram.pings(m).range(k+Svindex1);
				weight_vector = [weight_vector, deltaR1];
				Svindex2 = Svindex2 + 1;
			end
			weight_matrix = repmat(weight_vector', 1, length(echogram.pings(m).time));
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1+1:Svindex2,:)/10)))/vertical_binsize);
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1:Svindex2-1,:)/10)))/vertical_binsize);
                        Svbin(i-1,:) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:)/10),1)/(size(echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:),1)));                  
%                        Svbin(i-1,:) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:)/10))));
%			Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:)/10)))/vertical_binsize);
% 			Svbin(i-1,:) = nansum(weight_matrix.*echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:))/vertical_binsize;
            %Svindex2 = Svindex2 + 1;
			Svindex1 = Svindex2;
		elseif (j~=0)
			for k=1:j-1
                                deltaR1 = echogram.pings(m).range(k+Svindex1+1) - echogram.pings(m).range(k+Svindex1);
				weight_vector = [weight_vector, deltaR1];
				Svindex2 = Svindex2 + 1;
			end
                        deltaR1 = echogram.pings(m).range(j+Svindex1+1) - echogram.pings(m).range(j+Svindex1);
			weight_vector = [weight_vector, rangebin(i)-(var-deltaR1)];
			Svindex2 = Svindex2 + 1;
			weight_matrix = repmat(weight_vector', 1, length(echogram.pings(m).time));
% if m == 1			
% if i == 652
% keyboard
% end
% end
                        Svbin(i-1,:) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:)/10),1)/(size(echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:),1)));
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1:Svindex2,:)/10)))/vertical_binsize);
                        %Svbin(i-1,:) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:)/10))));
%			Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:)/10)))/vertical_binsize);
% 			Svbin(i-1,:) = nansum(weight_matrix.*echogram.pings(m).Sv(Svindex2-length(weight_vector)+1:Svindex2,:))/vertical_binsize;

            Svindex1 = Svindex2;
		end
	end
	echogram.pings(m).Sv = Svbin;
end



% length(rangebin) and length(Svbin(:,1)) have one index of difference, so we create a new range vector that has exactly the same length of Svbin, so that we can use it to plot Svbin

rangebinmean = zeros(length(rangebin)-1,1);
rangebinmean(1:length(rangebin)-1) = (rangebin(1:length(rangebin)-1)+rangebin(2:length(rangebin)))/2;

for i=1:length(echogram.pings)
	echogram.pings(i).range = rangebinmean;
        ind = find(isinf(echogram.pings(i).Sv));
        echogram.pings(i).Sv(ind) = -999;
end



