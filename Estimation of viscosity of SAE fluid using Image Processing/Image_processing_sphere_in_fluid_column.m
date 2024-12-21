% Script to process a video of a ball falling in a fluid column and calculate viscosity
% The script determines the relative uncertainty in viscosity measurements
% based on the video analysis. The input file path needs to be replaced
% with your specific video path.

clc
clear all
close all

% Define placeholders for folder path and file name
% Replace 'FOLDER_PATH' with the actual folder containing the video files
% Replace 'VIDEO_FILE_NAME' with the actual video file name
folder_path = "FOLDER_PATH"; % Placeholder for the folder path
name = "VIDEO_FILE_NAME"; % Placeholder for the video file name
vid = strcat(folder_path, name); % Combine folder path and video file name

% Parameters for the experiment
% Radius of the ball dropped in the fluid column (in meters)
r = [6.36 6.09 6.22 6.02 6.33 6.39 6.44 6.4 6.22] * 10^-3;

% Density of the steel ball (in kg/m^3)
rho_sphere = 7810;

% Acceleration due to gravity (in m/s^2)
g = 9.81;

% Set column height, fluid density, and detection parameters based on video name
if contains(name, "SAE-90")
    col_ht = 0.9271; % Column height for SAE-90
    r = r(1:3); % Radius for SAE-90 balls
    rho_liq = 893; % Fluid density for SAE-90
    minBlobArea = 40;
    maxBlobArea = 700;
    noisePxlSz = 35;
    thresholdVal = 27.5;
elseif contains(name, "SAE-50")
    col_ht = 0.9525; % Column height for SAE-50
    r = r(4:6); % Radius for SAE-50 balls
    rho_liq = 898; % Fluid density for SAE-50
    minBlobArea = 290;
    maxBlobArea = 500;
    noisePxlSz = 180;
    thresholdVal = 30;
elseif contains(name, "SAE-40")
    col_ht = 0.8890; % Column height for SAE-40
    r = r(7:9); % Radius for SAE-40 balls
    rho_liq = 887; % Fluid density for SAE-40
    minBlobArea = 300;
    maxBlobArea = 1300;
    noisePxlSz = 280;
    thresholdVal = 30;
end

% Use the track_ball function to track the position, size, and time of the ball
% GUI interaction: User will select the column's x-limits interactively for detection
[coord, objSz, time] = track_ball(vid, minBlobArea, maxBlobArea, noisePxlSz, thresholdVal);

% Smooth the velocity using the smooth_vel function
% GUI interaction: User will select two points interactively to calibrate pixel-to-meters conversion
y_coeff = smooth_vel([coord, objSz, time], vid, col_ht);

% Calculate average velocity for each ball
for i = 1:3
    vel(i) = y_coeff{i}(1); % First coefficient represents the average velocity
end

% Number of velocity measurements
n = length(vel);

% Calculate dynamic viscosity using Stokes' law
mu = 2 * r.^2 .* (rho_sphere - rho_liq) * g ./ (9 * vel);

% Calculate uncertainties
U_vel = tinv(0.975, n - 1) * std(vel) / sqrt(n); % Uncertainty in velocity
U_r = tinv(0.975, n - 1) * std(r) / sqrt(n); % Uncertainty in radius
U_mu_calc = mean(mu) * sqrt((2 * U_r / mean(r))^2 + (U_vel / mean(vel))^2); % Calculated uncertainty in viscosity
U_mu_tab = tinv(0.975, n - 1) * std(mu) / sqrt(n); % Tabulated uncertainty in viscosity

% Relative uncertainties
Rel_U_tab = U_mu_tab / mean(mu);
Rel_U_calc = U_mu_calc / mean(mu);

% Confidence intervals for viscosity
calc_lim = [mean(mu) - U_mu_calc, mean(mu) + U_mu_calc];
tab_lim = [mean(mu) - U_mu_tab, mean(mu) + U_mu_tab];

% Display results
disp('Relative Uncertainty (Tabulated):'), disp(Rel_U_tab);
disp('Relative Uncertainty (Calculated):'), disp(Rel_U_calc);
disp('Confidence Interval (Calculated):'), disp(calc_lim);
disp('Confidence Interval (Tabulated):'), disp(tab_lim);
