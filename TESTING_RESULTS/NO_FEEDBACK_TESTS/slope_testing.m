% FIRST TEST AFTER UPDATING HARDWARE
% This test is a step from 150bpm to 180bpm
% using PREVIOUS SPM, not current

% this test is to view the effect that slope has on the HR-cadence
% relationship, two tests
%   1 with zero incline
%   1 with 7.5 deg incline to emphasize slope effect

% step function with cadence by being on a treadmill and timing walk to run

load("NF_No_slope.mat");
load("NF_W_Slope.mat");


% everyhting worked, nothing got disconnected
% begin getting the data

% load in T1.mat which contains
% 1. LHR1 - inst. HR with time stamps
% 2. LSPM1 - inst. cadence with time stamps
% 3. LCAD1 - desired cadence
HR_time_1 = NFHR1(2:2:end);
HR_time_1 = HR_time_1 / 60000; % converting to mins
HR_1 = NFHR1(1:2:end); % is in bpm

SPM_time_1 = NFSPM1(2:2:end);
SPM_time_1 = SPM_time_1 / 60000; % also converting to mins
SPM_1 = NFSPM1(1:2:end); % is in steps per min (SPM)

HR_time_2 = NFHR2(2:2:end);
HR_time_2 = HR_time_2 / 60000; % converting to mins
HR_2 = NFHR2(1:2:end); % is in bpm

SPM_time_2 = NFSPM2(2:2:end);
SPM_time_2 = SPM_time_2 / 60000; % also converting to mins
SPM_2 = NFSPM2(1:2:end); % is in steps per min (SPM)


% now have HR, SPM, and desired CAD with corresponding times

%% Filtering the inst. HR and SPM 
% Median filter HR with nbh of 15 values 
% 15 b/c extra noisy at the beginning, but the median filter cleans it up
HR_filt_1 = medfilt1(HR_1, 11); 
HR_filt_2 = medfilt1(HR_2, 9);

% average filt SPM and median filt to see what is better
SPM_filt_1 = medfilt1(SPM_1, 11);
SPM_filt_2 = medfilt1(SPM_2, 9);


%% last graphs of everything together
figure;
plot(HR_time_1, HR_filt_1);
xlabel("Time (min)", 'FontSize',14);
ylabel("HR (BPM) and Cadence (SPM)", 'FontSize',14);
title("HR and CAD for No Slope with No Feedback", 'FontSize',14);
hold on;
plot(SPM_time_1, SPM_filt_1);
lgd = legend("HR","CAD");
lgd.FontSize = 11;
xlim([0 10]);
ylim([0 200]);
hold off;

figure;
plot(HR_time_2, HR_filt_2);
xlabel("Time (min)", 'FontSize',14);
ylabel("HR (BPM) and Cadence (SPM)", 'FontSize',14);
title("HR and CAD for 7.5 Deg Slope with No Feedback", 'FontSize',14);
hold on;
plot(SPM_time_2, SPM_filt_2);
lgd = legend("HR","CAD");
lgd.FontSize = 11;
xlim([0 10]);
ylim([0 200]);
hold off;

figure;
plot(HR_time_1, HR_filt_1);
xlabel("Time (min)", 'FontSize',14);
ylabel("HR (BPM) and Cadence (SPM)", 'FontSize',14);
title("HR and CAD for No Slope and 7.5 Deg Slope", 'FontSize',14);
hold on;
plot(SPM_time_1, SPM_filt_1);
plot(HR_time_2, HR_filt_2);
plot(SPM_time_2, SPM_filt_2);
lgd = legend("HR Flat","CAD Flat", "HR Slope", "CAD Slope");
lgd.FontSize = 11;
xlim([0 10]);
ylim([0 200]);
hold off;

%% post-processing data metrics
% HR beginning part (slow) 
HR_b1 = HR_filt_1(HR_time_1 > 0.6 & HR_time_1 < 4.5);
HR_time_b1 = HR_time_1(HR_time_1 > 0.6 & HR_time_1 < 4.5);
HR_b2 = HR_filt_2(HR_time_2 > 0.6 & HR_time_2 < 4.5);
HR_time_b2 = HR_time_2(HR_time_2 > 0.6 & HR_time_2 < 4.5);

% CAD beginning part (slow) 
CAD_b1 = SPM_filt_1(SPM_time_1 > 0.6 & SPM_time_1 < 4.5);
CAD_time_b1 = SPM_time_1(SPM_time_1 > 0.6 & SPM_time_1 < 4.5);
CAD_b2 = SPM_filt_2(SPM_time_2 > 0.6 & SPM_time_2 < 4.5);
CAD_time_b2 = SPM_time_2(SPM_time_2 > 0.6 & SPM_time_2 < 4.5);

% end part (fast)
HR_e1 = HR_filt_1(HR_time_1 > 6.0 & HR_time_1 < 9.5);
HR_time_e1 = HR_time_1(HR_time_1 > 6.0 & HR_time_1 < 9.5);
HR_e2 = HR_filt_2(HR_time_2 > 6.0 & HR_time_2 < 9.5);
HR_time_e2 = HR_time_2(HR_time_2 > 6.0 & HR_time_2 < 9.5);

% CAD end part (fast) 
CAD_e1 = SPM_filt_1(SPM_time_1 > 6.0 & SPM_time_1 < 9.5);
CAD_time_e1 = SPM_time_1(SPM_time_1 > 6.0 & SPM_time_1 < 9.5);
CAD_e2 = SPM_filt_2(SPM_time_2 > 6.0 & SPM_time_2 < 9.5);
CAD_time_e2 = SPM_time_2(SPM_time_2 > 6.0 & SPM_time_2 < 9.5);

% HR transition part 
HR_t1 = HR_filt_1(HR_time_1 > 4.6 & HR_time_1 < 5.9);
HR_time_t1 = HR_time_1(HR_time_1 > 4.6 & HR_time_1 < 5.9);
HR_t2 = HR_filt_2(HR_time_2 > 4.6 & HR_time_2 < 5.9);
HR_time_t2 = HR_time_2(HR_time_2 > 4.6 & HR_time_2 < 5.9);

% CAD transition part 
CAD_t1 = SPM_filt_1(SPM_time_1 > 4.6 & SPM_time_1 < 5.9);
CAD_time_t1 = SPM_time_1(SPM_time_1 > 4.6 & SPM_time_1 < 5.9);
CAD_t2 = SPM_filt_2(SPM_time_2 > 4.6 & SPM_time_2 < 5.9);
CAD_time_t2 = SPM_time_2(SPM_time_2 > 4.6 & SPM_time_2 < 5.9);

%% use the broken up runs to get averages and curve fits
HR_b1_avg = mean(HR_b1);
HR_e1_avg = mean(HR_e1);
HR_b2_avg = mean(HR_b2);
HR_e2_avg = mean(HR_e2);

CAD_b1_avg = mean(CAD_b1);
CAD_e1_avg = mean(CAD_e1);
CAD_b2_avg = mean(CAD_b2);
CAD_e2_avg = mean(CAD_e2);

fitobject1 = fit(HR_time_t1, HR_t1, 'exp1');
figure;
plot(fitobject1,HR_time_t1, HR_t1);

fitobject2 = fit(HR_time_t2, HR_t2, 'exp1');
figure;
plot(fitobject2,HR_time_t2, HR_t2);
