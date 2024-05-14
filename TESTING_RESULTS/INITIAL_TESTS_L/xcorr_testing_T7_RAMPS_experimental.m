% Compute cross-correlation
% can be used on any dataset
% need to run the seperate test file to get hr time etc.

% EXPERIMENTING SUBTRACTING MY MEAN OF ENTIRE SIGNAL
% DONT KNOW ABOUT THIS AT ALL
test_HR = interp1(HR_time_temp,HR_temp,time);
test_SPM = interp1(SPM_time_temp,SPM_temp,time);


time_up = linspace(1,3.5,250);

% seperate the run into the ramp up, stay, and ramp down sections
% now find the signals betwwen 2 and 9 mins might have to change to 8 some
HR_up = HR_filt(HR_time > 0.9 & HR_time < 3.6);
HR_time_up = HR_time(HR_time > 0.9 & HR_time < 3.6);

SPM_up = SPM_filt_med(SPM_time > 0.9 & SPM_time < 3.6);
SPM_time_up = SPM_time(SPM_time > 0.9 & SPM_time < 3.6);

% subtract my the mean to eliminate 'dc' value
test_HR_up = interp1(HR_time_up,HR_up,time_up);
test_HR_up = test_HR_up - mean(test_HR);%mean(test_HR_up);

% subtract my the mean
test_SPM_up = interp1(SPM_time_up,SPM_up,time_up);
test_SPM_up = test_SPM_up - mean(test_SPM);%mean(test_SPM_up);

[correlation_up, lag_up] = xcorr(test_HR_up,test_SPM_up, 'normalized');

% Plot cross-correlation
figure(20);
plot(lag_up*0.01*60, correlation_up);
xlabel(' Time (s) ');
%xlim([0 60]);
ylabel('Cross-correlation');
title('Normalized Cross-correlation between HR and SPM For Up Ramp');

%% Now for the steady 165 hr part
% need to run the seperate test file to get hr time etc.
time_stay = linspace(3.5,5.5,200);

% seperate the run into the ramp up, stay, and ramp down sections
% now find the signals betwwen 2 and 9 mins might have to change to 8 some
HR_stay = HR_filt(HR_time > 3.4 & HR_time < 5.6);
HR_time_stay = HR_time(HR_time > 3.4 & HR_time < 5.6);

SPM_stay = SPM_filt_med(SPM_time > 3.4 & SPM_time < 5.6);
SPM_time_stay = SPM_time(SPM_time > 3.4 & SPM_time < 5.6);

% subtract my the mean to eliminate 'dc' value
test_HR_stay = interp1(HR_time_stay,HR_stay,time_stay);
test_HR_stay = test_HR_stay - mean(test_HR);%mean(test_HR_stay);

% subtract my the mean
test_SPM_stay = interp1(SPM_time_stay,SPM_stay,time_stay);
test_SPM_stay = test_SPM_stay - mean(test_SPM);%mean(test_SPM_stay);

[correlation_stay, lag_stay] = xcorr(test_HR_stay,test_SPM_stay, 'normalized');

% Plot cross-correlation
figure(21);
plot(lag_stay*0.01*60, correlation_stay);
xlabel(' Time (s) ');
xlim([0 60]);
ylabel('Cross-correlation');
title('Normalized Cross-correlation between HR and SPM For Flat');

%% Now for the ramp down
% need to run the seperate test file to get hr time etc.
time_down = linspace(5.5,8,250);

% seperate the run into the ramp up, stay, and ramp down sections
% now find the signals betwwen 2 and 9 mins might have to change to 8 some
HR_down = HR_filt(HR_time > 5.4 & HR_time < 8.1);
HR_time_down = HR_time(HR_time > 5.4 & HR_time < 8.1);

SPM_down = SPM_filt_med(SPM_time > 5.4 & SPM_time < 8.1);
SPM_time_down = SPM_time(SPM_time > 5.4 & SPM_time < 8.1);

% subtract my the mean to eliminate 'dc' value
test_HR_down = interp1(HR_time_down,HR_down,time_down);
test_HR_down = test_HR_down - mean(test_HR);%mean(test_HR_down);

% subtract my the mean
test_SPM_down = interp1(SPM_time_down,SPM_down,time_down);
test_SPM_down = test_SPM_down - mean(test_SPM);%mean(test_SPM_down);

[correlation_down, lag_down] = xcorr(test_HR_down,test_SPM_down, 'normalized');

% Plot cross-correlation
figure(22);
plot(lag_down*0.01*60, correlation_down);
xlabel(' Time (s) ');
xlim([0 60]);
ylabel('Cross-correlation');
title('Normalized Cross-correlation between HR and SPM For Down Ramp');
