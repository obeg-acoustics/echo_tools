function [Svmatrix_candidatepeaks, rangematrix_candidatepeaks] = iteration_bottom_function(Svmatrix_candidatepeaks, rangematrix_candidatepeaks, window_radius, bottom_threshold, current_ping, window_beginning, window_ending,j,k)

if nanmax(current_ping(window_beginning:window_ending)) >= bottom_threshold
	Svmatrix_candidatepeaks(k,j) = nanmax(current_ping(window_beginning:window_ending));
	candidaterange = find(current_ping == Svmatrix_candidatepeaks(k,j));
        tmp            = candidaterange(find((candidaterange>=window_beginning).*(candidaterange<=window_ending))); 
	rangematrix_candidatepeaks(k,j) = tmp(1);
else
	Svmatrix_candidatepeaks(k,j) = current_ping(rangematrix_candidatepeaks(k,j-1));
	rangematrix_candidatepeaks(k,j) = rangematrix_candidatepeaks(k,j-1);
end
