function [echogram] = falsebottom_detection(echogram, ratio_threshold, window_radius, start_depth, Sv_max_chunks_threshold, warning_falsebottom_threshold, falsebottom_threshold, SvLim)
% keyboard
% Script whose goal is to detect the false bottom in our data. Made from a variation of the bottom detection method, where instead of using the data of one frequency we will use the ratio between two frequncies.

% Input :
%	- echogram
%	- ratio : each max value of all the pings will be compared to this threshold. Under it, we consider that there's no false bottom in the studied ping.
%	- window_radius : When the algorithm detects a potential false bottom at the beginning of a context, we look for the false bottom's following in the next ping into a window centered on the previous potential fasle bottom range, whose radius is window_radius value
%	- start_depth : this is the depth where the algorithm starts looking for a false bottom. Like that we avoid the surface Sv values that are really high, and can be considered as false bottom.
%	- Sv_max_chunks_threshold : when we have identified potential false bottom chunks, we take the max Sv value of each chunk. If this max value is below the threshold, we remove the chunk, considering it as a fish school (interesting signal to analyze)
%	- warning_falsebottom_threshold : this is a security threshold. If the difference between the end of a false bottom chunk and the beginning of the next one is too large, we tell the user that there might have some problem for the false bottom detection. The user should then verify himself the consistency of the false botton detected by the algorithm. 

% Output :
%	- echogram.falsebottom.falsebottom_indexes : a vector whose length is the same as echogram.pings(j).time, containing the range indexes of the false bottom
%	- echogram.falsebottom.falsebottom_depth : a vector whose length is the same as echogram.pings(j).time, containing the depth of the false bottom
%	- echogram.falsebottom.falsebottom_discontinuity : a vector whose containing numbers. These numbers are ping numbers, where our algorithm has detected discontinuities in the false bottom. The user should watch on the echogram (plotted with the falsebottom_indexes vector) if the false bottom is well detected. If not, tune the parameters.


l = [1,2]; % Choose with this parameter the frequencies in your echogram whose ratio you want to use to detect the false bottom. Normally, false bottoms tend to be stronger in the lowest frequencies, which can also go deeper. 

data = echogram.pings(l(2)).Sv ./ echogram.pings(l(1)).Sv .* echogram.mask(l(2)).SvBot .* echogram.mask(l(2)).SvFalseBot;

%When doing the ratio some infinity values appeared, which then caused a
%crash on iteration_bottom_function. We will replace them by -999.
data(find(isinf(data)))=-999;

fullrange_candidatepeak = []; % Create a vector that will be updated at each i loop with the range of the potential false bottom, or by NaNs if no false bottom has been detected
localrange_candidatepeak = []; % Range vector inside a context.
fullSv_candidatepeak = []; % Create a vector that will be updated at each i loop with the Sv values of the potential false bottom, or by NaNs if no false bottom has been detected
localSv_candidatepeak = []; % Sv vector inside a context.

pingi = 1;


while pingi < length(echogram.pings(l(1)).time)
	context_size = 64; % The size of the context (number of pings) in which the algorithm will look for a false bottom chunk. This size is divided by 2 each time the algorithm doesn't find any false bottom chunk, until falsebottom_size = 1, then the algorithm adds a NaN in fullrange_candidatepeak vector, meaning that no falsebottom has been detected. It then goes to the next ping and starts again with a context_size = 64.
	criteria = 0; % When this criteria is updated to one, it means that the algorithm has finished to find a false bottom chunk into the current context. It then goes to the next context. Or it didn't find any potential false bottom, a NaN is then added to the fullrange_candidatepeak vector.
	while criteria == 0 

		init = 0;

		if pingi + context_size < length(echogram.pings(l(1)).time) % This "if" condition is just to make a special case of the last context which must fit length(echogram.pings(l).time)
			for j=1:context_size % Loop upon the current context
				current_ping = data(:,pingi+j-1);
				surface_ranges = find(echogram.pings(l(1)).range <= start_depth);  % In the current ping, all the values that are above the start_depth are settled to -999
				current_ping(surface_ranges) = -999; % NaNs would be a problem for the sort() function
				if init == 0 % This condition is necessary to initialize the false bottom chunk in the current context. We need a special case for the first ping because it will be the starting point to find the rest of the false bottom chunk.
					ind = find(current_ping > ratio_threshold); % Find the max Sv values in the current ping and see if they can by considered as false bottom
					if ~isempty(ind)
						Sv_candidatepeaks = sort(current_ping(ind), 'descend');
						if length(Sv_candidatepeaks) > 6
							Sv_candidatepeaks = Sv_candidatepeaks(1:6);
						end
						Svmatrix_candidatepeaks = -999*ones(length(Sv_candidatepeaks), context_size);
						Svmatrix_candidatepeaks(:,j) = Sv_candidatepeaks;

						rangematrix_candidatepeaks = -999*ones(length(Sv_candidatepeaks), context_size);
						for k=1:length(Sv_candidatepeaks)
							rangematrix_candidatepeaks(k,j) = find(current_ping == Sv_candidatepeaks(k)); % Pay attention to the values of Sv which can be equal in different ranges
						end
						init = 1;
					else
						Svmatrix_candidatepeaks = -999;
				                rangematrix_candidatepeaks =[];
						localrange_candidatepeak = [localrange_candidatepeak, NaN];
						localSv_candidatepeak = [localSv_candidatepeak, NaN];
					end
				else % If the context has been initialized with a ping, then we look at the next pings in a "searching window" centered on the range of the potential detected false bottom to see if the potential false bottom continues or not.
					for k=1:length(rangematrix_candidatepeaks(:,1))
						if rangematrix_candidatepeaks(k,j-1)-window_radius < 1 % Surface case
							window_beginning = 1;
							window_ending = rangematrix_candidatepeaks(k,j-1)+window_radius;

%							if nanmax(current_ping(1:rangematrix_candidatepeaks(k,j-1)+window_radius)) >= ratio_threshold
%								Svmatrix_candidatepeaks(k,j) = nanmax(current_ping(1:rangematrix_candidatepeaks(k,j-1)+window_radius));
%								rangematrix_candidatepeaks(k,j) = find(current_ping == Svmatrix_candidatepeaks(k,j));
%							else
%								Svmatrix_candidatepeaks(k,j) = current_ping(rangematrix_candidatepeaks(k,j-1));
%								rangematrix_candidatepeaks(k,j) = rangematrix_candidatepeaks(k,j-1);
%							end

						elseif rangematrix_candidatepeaks(k,j-1)+window_radius > length(current_ping) % false bottom case
							window_beginning = rangematrix_candidatepeaks(k,j-1)-window_radius;
							window_ending = length(echogram.pings(l(1)).range);
						else
							window_beginning = rangematrix_candidatepeaks(k,j-1)-window_radius;
							window_ending = rangematrix_candidatepeaks(k,j-1)+window_radius;			
	                end

					[Svmatrix_candidatepeaks, rangematrix_candidatepeaks] = iteration_bottom_function(Svmatrix_candidatepeaks, rangematrix_candidatepeaks, window_radius, ratio_threshold, current_ping, window_beginning, window_ending,j,k);

	            end
				end
			end
			% Test to keep the largest Sv sum
			Sv_sum = nansum(Svmatrix_candidatepeaks,2); % Sum each line vector, along time
			Sv_sum_max = max(Sv_sum); % Find the maximum of the Sv sums
			range_Sv_sum_max = find(Sv_sum == Sv_sum_max);

		else % Last context whose size is not the same as context_size. The method is exactly the same as before. Just a specific case.
			for j=1:length(echogram.pings(l(1)).time) - pingi +1
				current_ping = data(:,pingi+j-1);
				surface_ranges = find(echogram.pings(l(1)).range <= start_depth);  % In the current ping, all the values that are above the start_depth are settled to -999
				current_ping(surface_ranges) = -999; % NaNs would be a problem for the sort() function
				if init == 0
					ind = find(current_ping > ratio_threshold);
					if ~isempty(ind)
						Sv_candidatepeaks = sort(current_ping(ind), 'descend');
						if length(Sv_candidatepeaks) > 6
							Sv_candidatepeaks = Sv_candidatepeaks(1:6);
						end
						Svmatrix_candidatepeaks = -999*ones(length(Sv_candidatepeaks), length(echogram.pings(l(1)).time)-floor(length(echogram.pings(l(1)).time)/context_size)*context_size);
						Svmatrix_candidatepeaks(:,j) = Sv_candidatepeaks;

						rangematrix_candidatepeaks = -999*ones(length(Sv_candidatepeaks), length(echogram.pings(l(1)).time)-floor(length(echogram.pings(l(1)).time)/context_size)*context_size);
						for k=1:length(Sv_candidatepeaks)
							rangematrix_candidatepeaks(k,j) = find(current_ping == Sv_candidatepeaks(k)); % Attention aux valeurs de Sv qui peuvent etre egales a des ranges differents
						end
						init = 1;
					else
						Svmatrix_candidatepeaks = -999;
						rangematrix_candidatepeaks =[];
						localrange_candidatepeak = [localrange_candidatepeak, NaN];
						localSv_candidatepeak = [localSv_candidatepeak, NaN];
					end
				else
					for k=1:length(rangematrix_candidatepeaks(:,1))
						if rangematrix_candidatepeaks(k,j-1)-window_radius < 1 % Surface case
							window_beginning = 1;
							window_ending = rangematrix_candidatepeaks(k,j-1)+window_radius;
						elseif rangematrix_candidatepeaks(k,j-1)+window_radius > length(current_ping) % False bottom case
							window_beginning = rangematrix_candidatepeaks(k,j-1)-window_radius;
							window_ending = length(echogram.pings(l(1)).range);
						else
							window_beginning = rangematrix_candidatepeaks(k,j-1)-window_radius;
							window_ending = rangematrix_candidatepeaks(k,j-1)+window_radius;				
						end
						[Svmatrix_candidatepeaks, rangematrix_candidatepeaks] = iteration_bottom_function(Svmatrix_candidatepeaks, rangematrix_candidatepeaks, window_radius, ratio_threshold, current_ping, window_beginning, window_ending,j,k);
					end
				end
			end
			% Test to keep the largest Sv sum
			Sv_sum = nansum(Svmatrix_candidatepeaks,2); % Sum each line vector, along time
			Sv_sum_max = max(Sv_sum); % Find the maximum of the Sv sums
			range_Sv_sum_max = find(Sv_sum == Sv_sum_max);
		end







		if ~isempty(find(Svmatrix_candidatepeaks(range_Sv_sum_max,:)<ratio_threshold)) % Here we look all the Sv values of a potential false bottom chunk. They all must be above the ratio_threshold for the chunk to be considered. Otherwise, context_size is divided by two, and the loop starts again.
			if context_size == 1
				criteria = 1 ;
				fullrange_candidatepeak = [fullrange_candidatepeak, NaN];
				fullSv_candidatepeak = [fullSv_candidatepeak, NaN];
			else
				localrange_candidatepeak=[];
				localSv_candidatepeak=[];
				context_size = context_size/2;
			end
		else
			criteria = 1 ;
			if length(fullrange_candidatepeak) >= 1 % This loop doesn't work for the first context
				if ~isnan(fullrange_candidatepeak(end))% Here, we make sure that if it is detected as falsebottom, it is in the window radius with the last falsebottom part detected
					if abs(rangematrix_candidatepeaks(range_Sv_sum_max,1) - fullrange_candidatepeak(end))<= window_radius
						fullrange_candidatepeak = [fullrange_candidatepeak, rangematrix_candidatepeaks(range_Sv_sum_max,:)];
						fullSv_candidatepeak = [fullSv_candidatepeak, Svmatrix_candidatepeaks(range_Sv_sum_max,:)];
					else
						for i=1:length(rangematrix_candidatepeaks(range_Sv_sum_max,:))
							fullrange_candidatepeak = [fullrange_candidatepeak, NaN];
							fullSv_candidatepeak = [fullSv_candidatepeak, NaN];
						end
					end
				else
					fullrange_candidatepeak = [fullrange_candidatepeak, rangematrix_candidatepeaks(range_Sv_sum_max,:)];
					fullSv_candidatepeak = [fullSv_candidatepeak, Svmatrix_candidatepeaks(range_Sv_sum_max,:)];
				end
			else
				fullrange_candidatepeak = [fullrange_candidatepeak, rangematrix_candidatepeaks(range_Sv_sum_max,:)];
				fullSv_candidatepeak = [fullSv_candidatepeak, Svmatrix_candidatepeaks(range_Sv_sum_max,:)];
			end
		end
	end
	pingi = pingi + context_size;
end



% Creating vectors with the beginning/end (range and index) of each falsebottom chunk

Sv_max_falsebottom_chunks = [];
falsebottom_chunks_beginning_range = [];
falsebottom_chunks_ending_range = [];
falsebottom_chunks_beginning_ind = [];
falsebottom_chunks_ending_ind = [];



for i=1:length(fullrange_candidatepeak)
	if ~isnan(fullrange_candidatepeak(i))
		if i == 1
			if isnan(fullrange_candidatepeak(i+1))
				falsebottom_chunks_ending_range = [falsebottom_chunks_ending_range, fullrange_candidatepeak(i)];
				falsebottom_chunks_beginning_range = [falsebottom_chunks_beginning_range, fullrange_candidatepeak(i)];
				falsebottom_chunks_beginning_ind = [falsebottom_chunks_beginning_ind, i];
				falsebottom_chunks_ending_ind = [falsebottom_chunks_ending_ind, i];
			else
				falsebottom_chunks_beginning_range = [falsebottom_chunks_beginning_range, fullrange_candidatepeak(i)];
				falsebottom_chunks_beginning_ind = [falsebottom_chunks_beginning_ind, i];
			end

		elseif i == length(fullrange_candidatepeak)
			if isnan(fullrange_candidatepeak(i-1))
				falsebottom_chunks_ending_range = [falsebottom_chunks_ending_range, fullrange_candidatepeak(i)];
				falsebottom_chunks_beginning_range = [falsebottom_chunks_beginning_range, fullrange_candidatepeak(i)];
				falsebottom_chunks_beginning_ind = [falsebottom_chunks_beginning_ind, i];
				falsebottom_chunks_ending_ind = [falsebottom_chunks_ending_ind, i];
			else
				falsebottom_chunks_ending_range = [falsebottom_chunks_ending_range, fullrange_candidatepeak(i)];
				falsebottom_chunks_ending_ind = [falsebottom_chunks_ending_ind, i];
			end
		else
			if isnan(fullrange_candidatepeak(i-1))
				falsebottom_chunks_beginning_range = [falsebottom_chunks_beginning_range, fullrange_candidatepeak(i)];
				falsebottom_chunks_beginning_ind = [falsebottom_chunks_beginning_ind, i];
			end
			if isnan(fullrange_candidatepeak(i+1))
				falsebottom_chunks_ending_range = [falsebottom_chunks_ending_range, fullrange_candidatepeak(i)];
				falsebottom_chunks_ending_ind = [falsebottom_chunks_ending_ind, i];
			end
		end
	end
end



% Here we remove the false bottom candidate peaks that actually are fish schools/or not the false bottom

for i=1:length(falsebottom_chunks_beginning_ind)
	if max(fullSv_candidatepeak(falsebottom_chunks_beginning_ind(i):falsebottom_chunks_ending_ind(i))) < Sv_max_chunks_threshold
		fullrange_candidatepeak(falsebottom_chunks_beginning_ind(i):falsebottom_chunks_ending_ind(i)) = NaN;
		falsebottom_chunks_beginning_range(i) = NaN;
		falsebottom_chunks_ending_range(i) = NaN;
		falsebottom_chunks_beginning_ind(i) = NaN;
		falsebottom_chunks_ending_ind(i) = NaN;
	end
end


% We remove the NaNs from the four previous vectors.

ind = find(isnan(falsebottom_chunks_beginning_range));


for i=length(ind):-1:1
	if ind(i)==1
		falsebottom_chunks_beginning_range = falsebottom_chunks_beginning_range(2:end);
		falsebottom_chunks_ending_range = falsebottom_chunks_ending_range(2:end);
		falsebottom_chunks_beginning_ind = falsebottom_chunks_beginning_ind(2:end);
		falsebottom_chunks_ending_ind = falsebottom_chunks_ending_ind(2:end);
	elseif ind(i)==length(falsebottom_chunks_beginning_ind)
		falsebottom_chunks_beginning_range = falsebottom_chunks_beginning_range(1:end-1);
		falsebottom_chunks_ending_range = falsebottom_chunks_ending_range(1:end-1);
		falsebottom_chunks_beginning_ind = falsebottom_chunks_beginning_ind(1:end-1);
		falsebottom_chunks_ending_ind = falsebottom_chunks_ending_ind(1:end-1);
	else
		falsebottom_chunks_beginning_range = [falsebottom_chunks_beginning_range(1:ind(i)-1), falsebottom_chunks_beginning_range(ind(i)+1:end)];
		falsebottom_chunks_ending_range = [falsebottom_chunks_ending_range(1:ind(i)-1), falsebottom_chunks_ending_range(ind(i)+1:end)];
		falsebottom_chunks_beginning_ind = [falsebottom_chunks_beginning_ind(1:ind(i)-1), falsebottom_chunks_beginning_ind(ind(i)+1:end)];
		falsebottom_chunks_ending_ind = [falsebottom_chunks_ending_ind(1:ind(i)-1), falsebottom_chunks_ending_ind(ind(i)+1:end)];
	end
end



% Once we have our fullrange_candidatepeak vector, we want to smooth it and take the upper values of the false bottom.



for i=1:length(fullrange_candidatepeak)
%if i == 4054
%keyboard
%end
	if ~isnan(fullrange_candidatepeak(i))
		while echogram.pings(l(1)).Sv(fullrange_candidatepeak(i),i) > ratio_threshold
			fullrange_candidatepeak(i) = fullrange_candidatepeak(i) - 1;
			if fullrange_candidatepeak(i) == 1
				echogram.pings(l(1)).Sv(fullrange_candidatepeak(i),i) = ratio_threshold;
			end
		end
		if fullrange_candidatepeak(i) < length(echogram.pings(l(1)).range)
			fullrange_candidatepeak(i) = fullrange_candidatepeak(i)+1; % We take the range that is just after the ratio_threshold. But there is a problem if the range is the last one, hence if loop.
		end
		fullSv_candidatepeak(i) = echogram.pings(l(1)).Sv(fullrange_candidatepeak(i),i);
	end
end






falsebottom_discontinuity = [];
for i=1:length(falsebottom_chunks_beginning_range)-1
	if (falsebottom_chunks_beginning_range(i+1) > falsebottom_chunks_ending_range(i) + warning_falsebottom_threshold) || (falsebottom_chunks_beginning_range(i+1) < falsebottom_chunks_ending_range(i) - warning_falsebottom_threshold)
		disp('Be careful, false bottom detection might be wrong');
		falsebottom_discontinuity = [falsebottom_discontinuity, falsebottom_chunks_ending_ind(i)];
	end
end


% Here, fullrange_candidatepeak contains the indexes of the false bottom, not the depth in meters (yes, the name of the vector can be confusing). The indexes could be useful, but the depth as well. So we will create another vector that contains the depth of the false bottom.

ind = find(~isnan(fullrange_candidatepeak));
falsebottom_depth = nan(size(fullrange_candidatepeak));

for i=1:length(ind)
	%Now we check if the false bottom detected has a strong enough signal or it's just noise, and if so we save it.
	x = ind(i);
	y = round(echogram.pings(l(1)).range(fullrange_candidatepeak(ind(i))));
	
	if (echogram.pings(l(1)).Sv (y, x) > falsebottom_threshold)
		falsebottom_depth(ind(i)) = echogram.pings(l(1)).range(fullrange_candidatepeak(ind(i)));
	end
end


for k = 1:length(fullrange_candidatepeak)
    if ~isnan(fullrange_candidatepeak(k))
        val = echogram.pings(1).Sv(fullrange_candidatepeak(k),k);
        if val < SvLim
            fullrange_candidatepeak(k) = NaN;
            falsebottom_depth(k) = NaN;
        end
    end
end



echogram.falsebottom.falsebottom_indexes = fullrange_candidatepeak;
echogram.falsebottom.falsebottom_depth = falsebottom_depth;
echogram.falsebottom.falsebottom_discontinuity = falsebottom_discontinuity;



