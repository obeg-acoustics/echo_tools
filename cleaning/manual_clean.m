function echogram = manual_clean(echogram,freq,nfreq)
% This script permit selection of areas to discard and returns coordinates

for k=1:nfreq
    tmp = echogram.pings(freq).Sv.*echogram.mask(k).SvFalseBot.*echogram.mask(k).SvBot.*echogram.mask(k).SvManual;
end

figure, imagesc(tmp)
caxis([-100,-50])
hold on, plot(echogram.bottom.bottom_depth,'r*')
hold on, plot([1,length(echogram.bottom.bottom_depth)],[20,20],'r-')
hold on, plot([1,length(echogram.bottom.bottom_depth)],[520,520],'r:')
hold on, plot([1,length(echogram.bottom.bottom_depth)],[620,620],'r-')
recovery = 0;
if freq == 1
    recovery = input('RECOVERY (1/0) ?');
end
finished = 0;
if recovery == 1
    load('echogram_clean_tmp.mat')
    p_start = clean_tmp.p_start; p_end = clean_tmp.p_end;
    r_start = clean_tmp.r_start; r_end = clean_tmp.r_end;
    echogram.clean(freq).p_start = p_start;
    echogram.clean(freq).p_end = p_end;
    echogram.clean(freq).r_start = r_start;
    echogram.clean(freq).r_end = r_end;
    echogram = remove_clean(echogram,freq,nfreq);
    close all
    for k=1:nfreq
        tmp = echogram.pings(freq).Sv.*echogram.mask(k).SvFalseBot.*echogram.mask(k).SvBot.*echogram.mask(k).SvManual;
    end
    figure, imagesc(tmp)
    caxis([-100,-50])
    hold on, plot(echogram.bottom.bottom_depth,'r*')
    hold on, plot([1,length(echogram.bottom.bottom_depth)],[20,20],'r-')
    hold on, plot([1,length(echogram.bottom.bottom_depth)],[520,520],'r:')
    hold on, plot([1,length(echogram.bottom.bottom_depth)],[620,620],'r-')
    input('ZOOM ?')
else
    p_start = []; r_start = [];
    p_end = []; r_end = [];
    input('ZOOM ?')
end
while finished == 0
    display('SELECT SECTION TO REMOVE')
    [ping,range] = ginput(2);
    keep = input(['REMOVE SECTION ', num2str(ping(1)), ' TO ', num2str(ping(2)), ' (1/0): ']);
    if ~isempty(finished)
        if keep == 1
            if ping(1)<ping(2)
                p_start = [p_start,ping(1)]; p_end = [p_end,ping(2)];
            else
                p_start = [p_start,ping(2)]; p_end = [p_end,ping(1)];
            end
            if range(1)<range(2)
                r_start = [r_start,range(1)]; r_end = [r_end,range(2)];
            else
                r_start = [r_start,range(2)]; r_end = [r_end,range(1)];
            end
        end
    end
    finished = input('MOVE/FINISH(=1)? ');
    if isempty(finished)
        finished = 0;
    end
    if (finished ~=1)
        finished = 0;
    end
    echogram.clean(freq).p_start = p_start;
    echogram.clean(freq).p_end = p_end;
    echogram.clean(freq).r_start = r_start;
    echogram.clean(freq).r_end = r_end;
    clean_tmp = echogram.clean;
    % Save temporary file for recovery
    save('echogram_clean_tmp.mat','clean_tmp','-v7.3')
end
