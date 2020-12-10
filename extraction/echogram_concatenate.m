function [echogram1] = echogram_concatenate(echogram1, echogram2, option)
% Input :
%   - echogram1 : the echogram we want to add another one
%   - echogram2 : the echogram that will be concatenated to the first one
%   - option : This option parameter is to distinguish when the concatenation has to include the noise matrices or not. Put zero when no need to concatenate SvNoise and SvIN, 1 if needed. 
% Output :
%   - echogram1 : the concatenated echogram
%
% This function concatenates two echograms into a single one.


for j=1:length(echogram1.pings)   % We loop upon the frequencies
	sizeecho1 = size(echogram1.pings(j).Sv);
	sizeecho2 = size(echogram2.pings(j).Sv);
	if sizeecho1(1) > sizeecho2(1)   % We need to have all the Sv matrices with the same size. 						 % Given a single frequency, as the range/depth can vary, we 						 % need to be careful about the size of it. If the size vary, 						 % we complete the smallest ping vectors in Sv matrices with 						 % NaN, so that each Sv matrix has the same size.
		echogram2.pings(j).Sv 	= [echogram2.pings(j).Sv; NaN*ones(sizeecho1(1)  - sizeecho2(1), sizeecho2(2))];
	elseif sizeecho1(1) < sizeecho2(1)
		echogram1.pings(j).Sv 	= [echogram1.pings(j).Sv ; NaN*ones(sizeecho2(1) - sizeecho1(1) , sizeecho1(2) )];
		for i=1:length(echogram1.pings)  % Here, we also change the range vector, so that we
						 % have the longest range vector to plot the data at 
						 % the end.
			echogram1.pings(i).range = echogram2.pings(i).range;
		end
	end
	% We then add the other informations. Size is not problem anymore because we concatenate along
	% the time dimension.
	echogram1.pings(j).Sv 		= [echogram1.pings(j).Sv, echogram2.pings(j).Sv];
	echogram1.pings(j).time 	= [echogram1.pings(j).time, echogram2.pings(j).time];
    echogram1.pings(j).roll 	= [echogram1.pings(j).roll, echogram2.pings(j).roll];
    echogram1.pings(j).pitch 	= [echogram1.pings(j).pitch, echogram2.pings(j).pitch];
    echogram1.pings(j).soundvelocity   = [echogram1.pings(j).soundvelocity, echogram2.pings(j).soundvelocity];
	echogram1.pings(j).transducerdepth = [echogram1.pings(j).transducerdepth, echogram2.pings(j).transducerdepth];
	if option==1

		sizeSvNoise1 = size(echogram1.pings(j).SvNoise);
		sizeSvNoise2 = size(echogram2.pings(j).SvNoise);
		if sizeSvNoise1(1) > sizeSvNoise2(1) 
			echogram2.pings(j).SvNoise 	= [echogram2.pings(j).SvNoise; NaN*ones(sizeSvNoise1(1)  - sizeSvNoise2(1), sizeSvNoise2(2))];
		elseif sizeSvNoise1(1) < sizeSvNoise2(1)
			echogram1.pings(j).SvNoise 	= [echogram1.pings(j).SvNoise ; NaN*ones(sizeSvNoise2(1) - sizeSvNoise1(1), sizeSvNoise1(2) )];

		end

		sizeSvIN1 = size(echogram1.pings(j).SvIN);
		sizeSvIN2 = size(echogram2.pings(j).SvIN);
		if sizeSvIN1(1) > sizeSvIN2(1)   
			echogram2.pings(j).SvIN 	= [echogram2.pings(j).SvIN ; NaN*ones(sizeSvIN1(1) - sizeSvIN2(1), sizeSvIN2(2))];
		elseif sizeSvIN1(1) < sizeSvIN2(1)
			echogram1.pings(j).SvIN 	= [echogram1.pings(j).SvIN ; NaN*ones(sizeSvIN2(1) - sizeSvIN1(1), sizeSvIN1(2))];

		end

		echogram1.pings(j).SvNoise 		= [echogram1.pings(j).SvNoise, echogram2.pings(j).SvNoise];
		echogram1.pings(j).SvIN 		= [echogram1.pings(j).SvIN, echogram2.pings(j).SvIN];

	end
end

%if option == 1
%	echogram1.bottom.bottom_indexes		= [echogram1.bottom.bottom_indexes, echogram2.bottom.bottom_indexes];
%	echogram1.bottom.bottom_depth 		= [echogram1.bottom.bottom_depth, echogram2.bottom.bottom_depth];
%	echogram1.bottom.bottom_discontinuity	= [echogram1.bottom.bottom_discontinuity, echogram2.bottom.bottom_discontinuity];
%end

% We finally add the gps coordinates
if size(echogram2.gps.time,1)==1
   echogpstime2 = echogram2.gps.time';
   echogpslat2 = echogram2.gps.lat';
   echogpslon2 = echogram2.gps.lon';
else
   echogpstime2 = echogram2.gps.time;
   echogpslat2 = echogram2.gps.lat;
   echogpslon2 = echogram2.gps.lon;
end

if size(echogram1.gps.time,1)==1
   echogpstime1 = echogram1.gps.time';
   echogpslat1 = echogram1.gps.lat';
   echogpslon1 = echogram1.gps.lon';
else
   echogpstime1 = echogram1.gps.time;
   echogpslat1 = echogram1.gps.lat;
   echogpslon1 = echogram1.gps.lon;
end

echogram1.gps.time      = [echogpstime1; echogpstime2];
echogram1.gps.lat       = [echogpslat1; echogpslat2];
echogram1.gps.lon       = [echogpslon1; echogpslon2];

