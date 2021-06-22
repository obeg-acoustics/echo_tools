function [echogram] = horizontal_binning_distance(echogram, horizontal_binsize)

% This function will bin the echogram data along the distance/horizontal by not modifying the vertical range/depth.

% Input :
%	- echogram : what we want to bin
%	- horizontal_binsize : distance of the new distance scale (in m).
% Output :
%	- binned echogram


% We make sure that all the echograms of all the frequencies have the same size in distance

distance_length = length(echogram.pings(1).distance);
for i=2:length(echogram.pings)
	if length(echogram.pings(i).distance) > distance_length
		distance_length = length(echogram.pings(i).distance);
	end
end

for i=1:length(echogram.pings)
	if distance_length > size(echogram.pings(i).Sv,2)
		echogram.pings(i).Sv 	= [echogram.pings(i).Sv, NaN*ones( length(echogram.pings(i).range), distance_length  - size(echogram.pings(i).Sv,2))];
	end
end


% In the case distances are different according to the frequencies, we choose the longest distance vector in echogram so that our new grid is as universal as possible
maxdistance = max(echogram.pings(1).distance);
for i=2:length(echogram.pings)
	if max(echogram.pings(i).distance) > maxdistance
		maxdistance = max(echogram.pings(i).distance);
	end
end


% This loop creates a new distance vector sized with the horizontal_binsize parameter

if ~isnan(echogram.pings(1).distance(1))
    xb = echogram.pings(1).distance(1);
else
    xb = 0;
    for m = 1:length(echogram.pings) % ATT Patch to correct NaN at first distance
        echogram.pings(m).distance(1)=0;
    end
end

distancebin = [xb];
while xb < maxdistance
	xb = xb + horizontal_binsize;
	distancebin = [distancebin, xb];
end
if distancebin(end) ~= maxdistance
	distancebin = distancebin(1:end-1);
end



% This loop finds the groups of indexes corresponding to the Sv vector (via distance vector) that will be gathered and averaged in the bins


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



for m = 1:length(echogram.pings) % Frequency loop
	Svbin = zeros(length(echogram.pings(m).range), length(distancebin)-1)*NaN;
        velobin = zeros(1, length(distancebin)-1)*NaN;
 
	% First iteration
	var = distancebin(1);
	weight_vector = [];
	Svindex = 0;
	j = 0;
	while var < distancebin(2)
                deltaR1 = (echogram.pings(m).distance(j+2) - echogram.pings(m).distance(j+1));
		var = var + deltaR1;
		j = j+1;
	end
	if var == distancebin(2)
		for k=1:j
                        deltaR1 = (echogram.pings(m).distance(k+1) - echogram.pings(m).distance(k));
			weight_vector = [weight_vector, deltaR1];
			Svindex = Svindex + 1;
		end
		weight_matrix = repmat(weight_vector, length(echogram.pings(m).range), 1);
                %Svbin(:,1) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(:,1:Svindex)/10)),2));
                Svbin(:,1) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(:,1:Svindex)/10),2)/(size(echogram.pings(m).Sv(:,1:Svindex),2)));
%		Svbin(:,1) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(:,1:Svindex)/10)),2)/horizontal_binsize);
% 		Svbin(:,1) = nansum(weight_matrix.*echogram.pings(m).Sv(:,1:Svindex),2)/horizontal_binsize;
        %Svindex = Svindex + 1;
                velobin(1,1) = nanmean(echogram.features.velocity(1,1:Svindex));
	else
		for k=1:j-1
                        deltaR1 = (echogram.pings(m).distance(k+1) - echogram.pings(m).distance(k));
			weight_vector = [weight_vector, deltaR1];
			Svindex = Svindex + 1;
		end
                deltaR1 = (echogram.pings(m).distance(j+1) - echogram.pings(m).distance(j));
		weight_vector = [weight_vector, distancebin(2)-(var-deltaR1)];
		Svindex = Svindex + 1;
		weight_matrix = repmat(weight_vector, length(echogram.pings(m).range), 1);
                %Svbin(:,1) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(:,1:Svindex)/10)),2));
                Svbin(:,1) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(:,1:Svindex)/10),2)/(size(echogram.pings(m).Sv(:,1:Svindex),2)));
%		Svbin(:,1) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(:,1:Svindex)/10)),2)/horizontal_binsize);
% 		Svbin(:,1) = nansum(weight_matrix.*echogram.pings(m).Sv(:,1:Svindex),2)/horizontal_binsize;
                velobin(1,1) = nanmean(echogram.features.velocity(1,1:Svindex));
    end
	Svindex1 = Svindex;
	Svindex2 = Svindex;

	for i=3:length(distancebin)
%if i == 135
%	keyboard
%end
		weight_vector = [];
		weight_matrix = [];
		if var ~= distancebin(i-1)
			weight_vector = [weight_vector, var-distancebin(i-1)];
		end
		j = 0;
		while (var < distancebin(i))&&(j+Svindex1+2<distance_length)
            deltaR1 = (echogram.pings(m).distance(j+Svindex1+2) - echogram.pings(m).distance(j+Svindex1+1));
            var = var + deltaR1;
			j = j+1;
		end
		if (var == distancebin(i))&&(j~=0)
%keyboard
			for k=1:j
                                deltaR1 = (echogram.pings(m).distance(Svindex1+k+1) - echogram.pings(m).distance(Svindex1+k));
				weight_vector = [weight_vector, deltaR1];
				Svindex2 = Svindex2 + 1;
			end
			weight_matrix = repmat(weight_vector, length(echogram.pings(m).range), 1);
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1+1:Svindex2,:)/10)))/vertical_binsize);
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1:Svindex2-1,:)/10)))/vertical_binsize);
                        Svbin(:,i-1) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10),2)/(size(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2),2)));
                        %Svbin(:,i-1) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10)),2));                       
%			Svbin(:,i-1) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10)),2)/horizontal_binsize);
% 			Svbin(:,i-1) = nansum(weight_matrix.*echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2),2)/horizontal_binsize;

%Svindex2 = Svindex2 + 1;
			Svindex1 = Svindex2;
                        velobin(1,i-1) = nanmean(echogram.features.velocity(1,Svindex2-length(weight_vector)+1:Svindex2));
        elseif (j~=0)
			for k=1:j-1
                                deltaR1 = (echogram.pings(m).distance(Svindex1+k+1) - echogram.pings(m).distance(Svindex1+k));
				weight_vector = [weight_vector, deltaR1];
				Svindex2 = Svindex2 + 1;
			end
                        deltaR1 = (echogram.pings(m).distance(Svindex1+j+1) - echogram.pings(m).distance(Svindex1+j));
			weight_vector = [weight_vector, distancebin(i)-(var-deltaR1)];
			Svindex2 = Svindex2 + 1;
			weight_matrix = repmat(weight_vector, length(echogram.pings(m).range),1);
% if m == 1			
% if i == 652
% keyboard
% end
% end
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1:Svindex2,:)/10)))/vertical_binsize);
             Svbin(:,i-1) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10),2)/(size(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2),2)));
            % Svbin(:,i-1) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10)),2));
%            Svbin(:,i-1) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10)),2)/horizontal_binsize);
%             Svbin(:,i-1) = nansum(weight_matrix.*echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2),2)/horizontal_binsize;

            Svindex1 = Svindex2;
            velobin(1,i-1) = nanmean(echogram.features.velocity(1,Svindex2-length(weight_vector)+1:Svindex2));
		end
	end
	echogram.pings(m).Sv = Svbin;
end



% length(timebin) and length(Svbin(:,1)) have one index of difference, so we create a new range vector that has exactly the same length of Svbin, so that we can use it to plot Svbin
% and estimate corresponding time vector

distancebinmean = zeros(length(distancebin)-1,1);
distancebinmean(1:length(distancebin)-1) = (distancebin(1:length(distancebin)-1)+distancebin(2:length(distancebin)))/2;

for i=1:length(echogram.pings)
        [refdistance, ia, ic] = unique(echogram.pings(i).distance);
        reftimetmp = echogram.pings(i).time;
        reftime    = reftimetmp(ia);
	    echogram.pings(i).distance = distancebinmean;
        echogram.pings(i).time = interp1(refdistance(2:end), reftime(2:end), distancebinmean);
end

% Correct velocity
echogram.features.velocity = velobin;
echogram.features.time     = echogram.pings(1).time;

