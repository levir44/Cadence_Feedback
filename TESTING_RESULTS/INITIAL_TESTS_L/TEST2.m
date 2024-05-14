% Second TEST

%DIDNT WORK BC OF LOOSE POWER CONNECTION FOR HR

% done at the track, had a lot of difficulty
% thought it wasnt working well, really hard to hear the buzzer

load("T2.mat");
% desrired HR = 160
% length of workout = 12 mins
HR_exp = [160 160];
HR_exp_time = [T2_HR(2)/60000 T2_HR(end-2)/60000];

% everyhting worked, nothing got disconnected
% begin getting the data

% load in T1.mat which contains
% 1. T2_HR - inst. HR with time stamps
% 2. T2_SPM - inst. cadence with time stamps
% 3. T2_Cad - desired cadence
HR_time = T2_HR(2:2:end);
HR_time = HR_time / 60000; % converting to mins
HR = T2_HR(1:2:end); % is in bpm

SPM_time = T2_SPM(2:2:end);
SPM_time = SPM_time / 60000; % also converting to mins
SPM = T2_SPM(1:2:end); % is in steps per min (SPM)

CAD_time = T2_Cad(2:2:end);
CAD_time = CAD_time / 60000; % converting to mins
CAD = T2_Cad(1:2:end);

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
% Median filter HR with nbh of 5 values
HR_filt = medfilt1(HR, 5); 

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