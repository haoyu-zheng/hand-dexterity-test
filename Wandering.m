function [wandering_error,error_rate2] = Wandering(fps,raw_hand,trial_count,time_TIP2,trial_start)
TIP2 = movmean(raw_hand(:,22:23),9);
TIP1 = movmean(raw_hand(:,10:11),9);
    
TIP_distance = ones(size(TIP2,1),3)*nan;
for i = 1:length(trial_start)
    for j = 1:time_TIP2(i)*fps
        TIP_distance(trial_start(i)+j-1,:) = [norm(TIP2(trial_start(i)+j-1,:)-TIP1(trial_start(i)+j-1,:)),i,j];
    end       
end
%plot(TIP_distance(:,1))
%hold on
TIP_distance = movmean(TIP_distance(:,1),9);
plot(TIP_distance(:,1))
hold on

[~,peak_locs] = findpeaks(TIP_distance);
[~,trough_locs] = findpeaks(-TIP_distance);

team = [];
for i = 1:length(peak_locs)
    team = [team;find(trial_start < peak_locs(i),1,'last')];
end
peak_locs = [peak_locs,team];

team = [];
for i = 1:length(trough_locs)
    team = [team;find(trial_start < trough_locs(i),1,'last')];
end
trough_locs = [trough_locs,team];

wandering_error=[];
for i = 1:trial_count
    [peak_row,~] = find(peak_locs(:,2) == i);
    [trough_row,~] = find(trough_locs(:,2) == i);
    if isempty(peak_row) || isempty(trough_row)
        continue
    elseif peak_locs(peak_row(end),1) > trough_locs(trough_row(1),1)
        wandering_error = [wandering_error,i];
    end
end

wandering_error = trial_start(wandering_error);
error_rate2 = length(wandering_error)/trial_count;

end
