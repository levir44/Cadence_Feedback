% TEST 8
% chaning heart rate expected
% more drastic than test 7
% produces decent results

load("T8.mat");
% desrired HR = 150
% length of workout = 10 mins
HR_exp = T8_HR_E(1:2:end);
HR_exp_time = T8_HR_E(2:2:end);
HR_exp_time = HR_exp_time / 60000; % converting to mins


% everyhting worked, nothing got disconnected
% begin getting the data

% load in T1.mat which contains
% 1. T8_HR - inst. HR with time stamps
% 2. T8_SPM - inst. cadence with time stamps
% 3. T8_Cad - desired cadence
HR_time = T8_HR(2:2:end);
HR_time = HR_time / 60000; % converting to mins
HR = T8_HR(1:2:end); % is in bpm

SPM_time = T8_SPM(2:2:end);
SPM_time = SPM_time / 60000; % also converting to mins
SPM = T8_SPM(1:2:end); % is in steps per min (SPM)

CAD_time = T8_Cad(2:2:end);
CAD_time = CAD_time / 60000; % converting to mins
CAD = T8_Cad(1:2:end);

% now have HR, SPM, and desired CAD with corresponding times

% plotting raw heart rate
figure(1);
plot(HR_time, HR);
xlabel("Time (min)");
ylabel("BPM");
title("Raw Instantaneous HR");

% plotting raw SPM
figure(2);
plot(SPM_time, SPM);
xlabel("Time (min)");
ylabel("Cadence (SPM)");
title("Raw Instantaneous Cadence");

% plotting desired cadence
figure(3);
stairs(CAD_time, CAD);
xlabel("Time (min)");
ylabel("Cadence (SPM)");
title("Desired Cadence");

%% Filtering the inst. HR and SPM 
% Median filter HR with nbh of 15 values 
% 15 b/c extra noisy at the beginning, but the median filter cleans it up
HR_filt = medfilt1(HR, 15); 

% average filt SPM and median filt to see what is better
B = 1/5*ones(5,1);
SPM_filt_avg = filter(B,1,SPM);
SPM_filt_med = medfilt1(SPM, 5);

% plot the filtered hr and spm (compare which is better for SPM)

% plotting filtered heart rate
figure(4);
plot(HR_time, HR_filt);
xlabel("Time (min)");
ylabel("BPM");
title("Median Filtered HR");

% plotting both filtered SPM
figure(5);
plot(SPM_time, SPM_filt_avg);
xlabel("Time (min)");
ylabel("Cadence (SPM)");
title("Filtered SPM");
hold on;
plot(SPM_time, SPM_filt_med);
legend("AVG", "MED");

%% now it is time to compare desired hr and cadence with expected

% starting with cadence
figure(6);
plot(SPM_time, SPM_filt_avg);
xlabel("Time (min)");
ylabel("Cadence (SPM)");
title("Desired vs. Measured SPM (AVG FILT)");
hold on;
stairs(CAD_time, CAD);
legend("Measured", "Desired");
hold off;

figure(7);
plot(SPM_time, SPM_filt_med);
xlabel("Time (min)");
ylabel("Cadence (SPM)");
title("Desired vs. Measured SPM (MED FILT)");
hold on;
stairs(CAD_time, CAD);
legend("Measured", "Desired");
hold off;

figure(8);
plot(HR_time, HR_filt);
xlabel("Time (min)");
ylabel("BPM");
title("Median Filtered HR vs. Desired");
hold on;
stairs(HR_exp_time, HR_exp);
hold off;

%% now plotting hr vs cadence 
figure(9);
plot(SPM_time, SPM_filt_med);
xlabel("Time (min)");
ylabel("HR and Cadence");
title("HR & Cadence vs. Time");
hold on;
plot(HR_time, HR_filt);
legend("Cadence", "Heart Rate");
hold off;

figure(10);
plot(SPM_time, SPM_filt_med + 40);
xlabel("Time (min)");
ylabel("HR and Cadence");
title("TESTING HR to CAD Relationship");
hold on;
plot(HR_time, HR_filt);
legend("1*(Cadence+40)", "Heart Rate");
hold off;

figure(11);
SPM_shift = circshift(SPM_filt_med,50);
plot(SPM_time, SPM_shift + 40);
xlabel("Time (min)");
ylabel("HR and Cadence");
title("TESTING HR to CAD Relationship with Shifting");
hold on;
plot(HR_time, HR_filt);
legend("1*(Cadence+40) SHIFTED", "Heart Rate");
hold off;

%% last graph of everything together
figure(12);
plot(HR_time, HR_filt);
xlabel("Time (min)");
ylabel("HR and Cadence");
title("HR and SPM vs. Desired HR and SPM");
hold on;
stairs(HR_exp_time, HR_exp, "Color",[0.3010 0.7450 0.9330]); %teal
plot(SPM_time, SPM_filt_med);
stairs(CAD_time, CAD, 'Color',[0.4660 0.6740 0.1880]); %green
legend("HR","Desired HR", "SPM", "Desired CAD");
hold off;
ylim([50 200]);