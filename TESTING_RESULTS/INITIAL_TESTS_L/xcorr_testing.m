% Compute cross-correlation

% can be used on any dataset
% need to run the seperate test file to get hr time etc.
time = linspace(2,9,700);

% now find the signals betwwen 2 and 9 mins might have to change to 8 some
HR_temp = HR_filt(HR_time > 1.9 & HR_time < 9.1);
HR_time_temp = HR_time(HR_time > 1.9 & HR_time < 9.1);

SPM_temp = SPM_filt_med(SPM_time > 1.9 & SPM_time < 9.1);
SPM_time_temp = SPM_time(SPM_time > 1.9 & SPM_time < 9.1);

test_HR = interp1(HR_time_temp,HR_temp,time);
% subtract my the mean to eliminate 'dv' value
test_HR = test_HR - mean(test_HR);
test_SPM = interp1(SPM_time_temp,SPM_temp,time);
% subtract my the mean
test_SPM = test_SPM - mean(test_SPM);

[correlation, lag] = xcorr(test_HR,test_SPM, 'normalized');

% Plot cross-correlation
figure(15);
plot(lag*0.01*60, correlation);
xlabel(' Time (s) ');
xlim([0 60]);
ylabel('Cross-correlation');
title('Cross-correlation between HR and SPM');
