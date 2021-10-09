function echogram = remove_clean_track(echogram,freq,nfreq,window)

p_start = echogram.clean(freq).p_start;
p_end   = echogram.clean(freq).p_end;
r_start = echogram.clean(freq).r_start;
r_end   = echogram.clean(freq).r_end;

[m,n] = size(echogram.pings(1).Sv);

p_start(find(p_start<1))=1;
p_start(find(p_start>n))=n;
p_end(find(p_end<1))=1;
p_end(find(p_end>n-1))=n-1;

r_start(find(r_start<1))=1;
r_start(find(r_start>m))=m;
r_end(find(r_end<1))=1;
r_end(find(r_end>m))=m;

for f = 1:nfreq
    for k = 1:length(p_start)
        a = (r_start(k)-r_end(k)) / (p_start(k)-p_end(k));
        b = r_start(k) - a*p_start(k);
        X = [floor(p_start(k)):floor(p_end(k))+1];
        Y = a*X+b;
        for p = 1:length(X)
            if (floor(Y(p))-window)<1
                echogram.mask(f).SvManual(1:floor(Y(p))+1+window,X(p))=NaN;
            elseif (floor(Y(p))+1+window)>m
                echogram.mask(f).SvManual(floor(Y(p))-window:m,X(p))=NaN;
            elseif ((floor(Y(p))-window)<1)&&((floor(Y(p))+1+window)>m)
                echogram.mask(f).SvManual(1:m,X(p))=NaN;
            else
                echogram.mask(f).SvManual(floor(Y(p))-window:floor(Y(p))+1+window,X(p))=NaN;
            end
        end
    end
end



   