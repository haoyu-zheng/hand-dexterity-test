close all
clear 
fps = 60;

file_list = dir('D:\Code\HandDexterity\FullData\*.csv');
% filename_likely = 'D:\Code\HandDexterity\Data\137-mm-dd-class.csv';
time_list = [];
time_list_g = [];
x_label = [];

for i = 1:length(file_list)/2
    filename_raw_hand = file_list(2*i).name;
    filename_raw_device = file_list(2*i-1).name;

    raw_hand = table2array(readtable(['D:\Code\HandDexterity\FullData\',filename_raw_hand]));
    raw_device = table2array(readtable(['D:\Code\HandDexterity\FullData\',filename_raw_device]));

    %1. trial_count, time and basic details
    raw_hand(find(raw_hand(:,21)<0.0001),19:21) = nan;
    raw_hand(find(raw_hand(:,24)<0.0001),22:24) = nan;

    raw_device(find(raw_device(:,9)<0.90),7:9) = nan;

    raw_device(find(raw_device(:,3)<0.90),1:3) = nan;
    raw_device(find(raw_device(:,6)<0.90),4:6) = nan;

    [trial_count,time_TIP2,trial_start,slit_line_x] = TrialCount(fps,raw_hand,raw_device);
    %for labels in boxplot
    if trial_count > 0
        label = strsplit(string(filename_raw_hand),"-");
        x_label = [x_label,label(1)];
    end
    time_list = [time_list,time_TIP2];
    time_list_g = [time_list_g,i*ones(size(time_TIP2))];
    
    %1. errors
    raw_hand(find(raw_hand(:,12)<0.0001),10:11) = nan;
    %1.1 slit-hit error
    
    [slit_hit_error,error_rate1] = SlitHit(fps,raw_hand,trial_count,trial_start,slit_line_x)
    
    %1.2 wandering error
    
    [wandering_error,error_rate2] = Wandering(fps,raw_hand,trial_count,time_TIP2,trial_start)
    
    hold off    
end


figure
boxplot(time_list,time_list_g)
xticklabels(x_label)
ylabel("time/s")
