function [trial_count,time_TIP2,trial_start,slit_line_x] = TrialCount(fps,raw_hand,raw_device)
%hand from left only
%all plot() only for giving explanations

left_top = [nanmean(raw_device(:,1)),nanmean(raw_device(:,2))];
left_bottom = [nanmean(raw_device(:,4)),nanmean(raw_device(:,5))];

DIP2 = movmean(raw_hand(:,19:20),9);
TIP2 = movmean(raw_hand(:,22:23),9);
apple_start = movmean(raw_device(:,7:8),5,'omitnan');
time_list = 1:size(apple_start,1);

%cleaning test
%nanmean(apple_start(:,1))
%nanstd(apple_start(:,1))

%original apple position
figure
plot(time_list,apple_start(:,1),"y.")
hold on

apple_std_x = movstd(apple_start(:,1),9);
apple_std_y = movstd(apple_start(:,2),9);

%data cleaning by x value
for i = 1:length(apple_std_x)
    if apple_std_x(i)>1 || isnan(apple_std_x(i))
        apple_start(i,:) = nan;
    end
end

%data cleaning by y value
for i = 1:length(apple_std_y)
    if apple_std_y(i)>1 || isnan(apple_std_y(i))
        apple_start(i,:) = nan;
    end
end
plot(time_list,apple_start(:,1),"b.")
hold on
%the cleaning cause an 4 frame data lost of apple position(instead by
%NaN) on the start and the end of an independent moving.

start = isoutlier(apple_start,"movmedian",30,1);
for i = 1:size(apple_start,1)
    if start(i,1) == 1 || start(i,2) == 1
        apple_start(i,:) = nan;
    end
end
plot(time_list,apple_start(:,1),"k.")
hold on
plot(time_list,TIP2(:,1))
hold on

%cleaning test
%nanmean(apple_start(:,1))
%nanstd(apple_start(:,1))

slit_line_x = 0.5*(left_top(1)+left_bottom(1));
plot([0,length(time_list)],[slit_line_x,slit_line_x])
hold on

trial_count = 0;
time_TIP2 = [];
trial_start = [];
a=[];
for i = 4:size(apple_start,1)-1
    if TIP2(i,1) < slit_line_x && TIP2(i+1,1) >= slit_line_x %x pass  
        if sum(isnan(apple_start(i-3:i,1))) < 4 %apple on position
            if TIP2(i,2) > left_top(2) && TIP2(i,2) < left_bottom(2) %y in range
                if isempty(find(TIP2(i+1:end,1) < slit_line_x,1)+i) == 0 && find(TIP2(i+1:end,1) < slit_line_x,1) > 0.25*fps %record an end
                    if sum(isnan(TIP2(i:find(TIP2(i+1:end,1) < slit_line_x,1)+i))) == 0 %no lost data 
                        if norm(TIP2(i,:)-DIP2(i,:)) > 5 && norm(TIP2(i,:)-DIP2(i,:)) < 20 %correct hand with a correct length
                            time_end = find(TIP2(i+1:end,1) < slit_line_x,1)+i;
                            if isempty(time_end) == 0
                                trial_count = trial_count+1;
                                time_start = i;
                                time_TIP2(end+1) = (time_end - time_start)/fps;
                                trial_start(end+1) = time_start;
                            end
                        end
                    end
                end
            end
        end
    end
end

end