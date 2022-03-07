function [slit_hit_error,error_rate1] = SlitHit(fps,raw_hand,trial_count,trial_start,slit_line_x)
TIP2 = movmean(raw_hand(:,22:23),9);
TIP1 = movmean(raw_hand(:,10:11),9);

TIP2_speed = [];
TIP1_speed = [];
for i = 1:length(trial_start)
    for j = 1:0.5*fps
        TIP2_speed = [TIP2_speed;norm(TIP2(max(trial_start(i)-j,1),:)-TIP2(max(trial_start(i)-j+1,2),:)),i,j];
        TIP1_speed = [TIP1_speed;norm(TIP1(max(trial_start(i)-j,1),:)-TIP1(max(trial_start(i)-j+1,2),:)),i,j];
    end       
end
slit_hit_error = [];
for i = 1:length(TIP2_speed)
    if TIP2_speed(i,1) < 5 || TIP1_speed(i,1) < 5 %low speed
        k = max(trial_start(TIP2_speed(i,2))-TIP2_speed(i,3),1);
        if TIP2(k,1) > slit_line_x-20 && TIP2(k,1) < slit_line_x+20 %close to slit
            if sum(TIP2(max(k-0.5*fps,1):max(k-1,2),1) > slit_line_x+20) == 0
                slit_hit_error = [slit_hit_error,TIP2_speed(i,2)];
            end
        elseif TIP1(k,1) > slit_line_x-20 && TIP1(k,1) < slit_line_x+20
            if sum(TIP1(max(k-0.5*fps,1):max(k-1,2),1) > slit_line_x+20) == 0
                slit_hit_error = [slit_hit_error,TIP1_speed(i,2)];
            end
        end
    end
end

slit_hit_error = trial_start(unique(slit_hit_error));
error_rate1 = length(slit_hit_error)/trial_count;

end