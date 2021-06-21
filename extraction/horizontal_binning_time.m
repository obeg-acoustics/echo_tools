function [echogram] = horizontal_binning_time(echogram, horizontal_binsize)

% This function will bin the echogram data along the time/horizontal by not modifying the vertical range/depth.

% Input :
%	- echogram : what we want to bin
%	- horizontal_binsize : time of the new time scale (in seconds).
% Output :
%	- binned echogram



% We make sure that all the echograms of all the frequencies have the same size in time

time_length = length(echogram.pings(1).time);
for i=2:length(echogram.pings)
	if length(echogram.pings(i).time) > time_length
		time_length = length(echogram.pings(i).time);
	end
end

for i=1:length(echogram.pings)
	if time_length > size(echogram.pings(i).Sv,2)
		echogram.pings(i).Sv 	= [echogram.pings(i).Sv, NaN*ones( length(echogram.pings(i).range), time_length  - size(echogram.pings(i).Sv,2))];
	end
end


% In the case times are different according to the frequencies, we choose the longest time vector in echogram so that our new grid is as universal as possible
maxtime = max(echogram.pings(1).time)*24*60*60;
for i=2:length(echogram.pings)
	if max(echogram.pings(i).time)*24*60*60 > maxtime
		maxtime = max(echogram.pings(i).time)*24*60*60;
	end
end


% This loop creates a new time vector sized with the horizontal_binsize parameter

if (echogram.pings(1).time(1)~=0)
    xb = echogram.pings(1).time(1)*24*60*60;
else
    xb = echogram.pings(1).time(2)*24*60*60;
end

timebin = [xb];
while xb < maxtime
	xb = xb + horizontal_binsize;
	timebin = [timebin, xb];
end
if timebin(end) ~= maxtime
	timebin = timebin(1:end-1);
end



% This loop finds the groups of indexes corresponding to the Sv vector (via time vector) that will be gathered and averaged in the bins


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



%deltaR1 = (echogram.pings(1).time(2) - echogram.pings(1).time(1))*24*60*60;

for m = 1:length(echogram.pings) % Frequency loop
	Svbin = zeros(length(echogram.pings(m).range), length(timebin)-1)*NaN;

	% First iteration
	var = timebin(1);
	weight_vector = [];
	Svindex = 0;
	j = 0;
	while var < timebin(2)
                deltaR1 = (echogram.pings(m).time(j+2) - echogram.pings(m).time(j+1))*24*60*60;
		var = var + deltaR1;
		j = j+1;
	end
	if var == timebin(2)
		for k=1:j
                        deltaR1 = (echogram.pings(m).time(k+1) - echogram.pings(m).time(k))*24*60*60;
			weight_vector = [weight_vector, deltaR1];
			Svindex = Svindex + 1;
		end
		weight_matrix = repmat(weight_vector, length(echogram.pings(m).range), 1);
                Svbin(:,1) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(:,1:Svindex)/10),2)/(size(echogram.pings(m).Sv(:,1:Svindex),2)));
                %Svbin(:,1) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(:,1:Svindex)/10)),2));
%		Svbin(:,1) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(:,1:Svindex)/10)),2)/horizontal_binsize);
		%Svindex = Svindex + 1;
	else
		for k=1:j-1
                        deltaR1 = (echogram.pings(m).time(k+1) - echogram.pings(m).time(k))*24*60*60;
			weight_vector = [weight_vector, deltaR1];
			Svindex = Svindex + 1;
		end
                deltaR1 = (echogram.pings(m).time(j+1) - echogram.pings(m).time(j))*24*60*60;
		weight_vector = [weight_vector, timebin(2)-(var-deltaR1)];
		Svindex = Svindex + 1;
		weight_matrix = repmat(weight_vector, length(echogram.pings(m).range), 1);
                Svbin(:,1) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(:,1:Svindex)/10),2)/(size(echogram.pings(m).Sv(:,1:Svindex),2)));
                %Svbin(:,1) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(:,1:Svindex)/10)),2));
%		Svbin(:,1) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(:,1:Svindex)/10)),2)/horizontal_binsize);
	end
	Svindex1 = Svindex;
	Svindex2 = Svindex;

	for i=3:length(timebin)
%if i == 135
%	keyboard
%end
		weight_vector = [];
		weight_matrix = [];
		if var ~= timebin(i-1)
			weight_vector = [weight_vector, var-timebin(i-1)];
		end
		j = 0;
		while (var < timebin(i))&&(j+Svindex1+2<time_length)
            deltaR1 = (echogram.pings(m).time(j+Svindex1+2) - echogram.pings(m).time(j+Svindex1+1))*24*60*60;
            var = var + deltaR1;
			j = j+1;
		end
		if (var == timebin(i))&&(j~=0)
%keyboard
			for k=1:j
                                deltaR1 = (echogram.pings(m).time(Svindex1+k+1) - echogram.pings(m).time(Svindex1+k))*24*60*60;
				weight_vector = [weight_vector, deltaR1];
				Svindex2 = Svindex2 + 1;
			end
			weight_matrix = repmat(weight_vector, length(echogram.pings(m).range), 1);
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1+1:Svindex2,:)/10)))/vertical_binsize);
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1:Svindex2-1,:)/10)))/vertical_binsize);
                        Svbin(:,i-1) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10),2)/(size(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2),2)));
                        %Svbin(:,i-1) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10)),2)); 
%			Svbin(:,i-1) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10)),2)/horizontal_binsize);
			%Svindex2 = Svindex2 + 1;
			Svindex1 = Svindex2;
        elseif (j~=0)
			for k=1:j-1
                                deltaR1 = (echogram.pings(m).time(Svindex1+k+1) - echogram.pings(m).time(Svindex1+k))*24*60*60;
				weight_vector = [weight_vector, deltaR1];
				Svindex2 = Svindex2 + 1;
			end
                        deltaR1 = (echogram.pings(m).time(Svindex1+j+1) - echogram.pings(m).time(Svindex1+j))*24*60*60;
			weight_vector = [weight_vector, timebin(i)-(var-deltaR1)];
			Svindex2 = Svindex2 + 1;
			weight_matrix = repmat(weight_vector, length(echogram.pings(m).range),1);
% if m == 1			
% if i == 652
% keyboard
% end
% end
			%Svbin(i-1,:) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(Svindex1:Svindex2,:)/10)))/vertical_binsize);
             Svbin(:,i-1) = 10 * log10(nansum(10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10),2)/(size(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2),2)));
             %Svbin(:,i-1) = 10*log10(nanmean((10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10)),2));
%            Svbin(:,i-1) = 10*log10(nansum(weight_matrix.*(10.^(echogram.pings(m).Sv(:,Svindex2-length(weight_vector)+1:Svindex2)/10)),2)/horizontal_binsize);
			Svindex1 = Svindex2;
		end
	end
	echogram.pings(m).Sv = Svbin;
end



% length(timebin) and length(Svbin(:,1)) have one index of difference, so we create a new range vector that has exactly the same length of Svbin, so that we can use it to plot Svbin

timebinmean = zeros(length(timebin)-1,1);
timebinmean(1:length(timebin)-1) = (timebin(1:length(timebin)-1)+timebin(2:length(timebin)))/2;

for i=1:length(echogram.pings)
	echogram.pings(i).time = timebinmean/24/60/60;
end



