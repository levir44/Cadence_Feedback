% This is to extract tau or 1st order/delay model from measured cadence and
% heart rate data

% need to FFT the cadence and HR data as an input/output pair
% cadence is input
% heart rate is output

% take the ratio of magnitude spectrum and plot

% need to run corresponding TEST# code

%% Begin code, read in HR and Cad data and interpolate for uniform samples
% Heart rate = HR_filt at HR_time
% Cadence = SPM_filt_med at SPM_time
i_time = 60*linspace(1,9,8000);
i_hr = interp1(60*HR_time,HR_filt,i_time);
i_SPM = interp1(60*SPM_time, SPM_filt_med, i_time);

%% with interpolated and uniform samples, time to FFT
f_hr = fft(i_hr);
f_SPM = fft(i_SPM);

%% working on plotting the responses
% Compute the frequency axis
Fs = (1 / (i_time(2) - i_time(1))); % Sampling frequency
N = length(i_hr); % Number of samples
f_axis = (0:N-1) * Fs / N; % Frequency axis in Hz

% Take the absolute value of FFT results to get magnitude spectrum
f_hr_mag = abs(f_hr);
f_SPM_mag = abs(f_SPM);

% Plot the magnitude spectrum
figure;
subplot(2,1,1);
plot(f_axis, f_hr_mag);
title('FFT of Interpolated Heart Rate Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

subplot(2,1,2);
plot(f_axis, f_SPM_mag);
title('FFT of Interpolated Cadence Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

%% Compute the ratio of cadence and heart rate
ratio = f_SPM_mag ./ f_hr_mag;

% Plot the ratio
figure;
plot(f_axis, ratio);
title('Ratio of Cadence to Heart Rate');
xlabel('Frequency (Hz)');
ylabel('Ratio');
grid on;


%% Shift the FFT
N = length(f_axis);
shifted_ratio = fftshift(ratio);
shifted_f_axis = (-N/2:N/2-1) * Fs / N; % Corrected frequency axis for fftshift

% Plot the shifted ratio
figure;
plot(shifted_f_axis, shifted_ratio);
title('Shifted Ratio of Cadence to Heart Rate');
xlabel('Shifted Frequency (Hz)');
ylabel('Ratio');
grid on;


%% Shift the FFT

% Compute magnitude in dB
mag_dB = 20*log10(abs(shifted_ratio));

% Plot the frequency response in dB vs the log of the frequency scale
figure;
semilogx(shifted_f_axis, mag_dB);
title('Frequency Response (dB) vs Log Frequency');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;

