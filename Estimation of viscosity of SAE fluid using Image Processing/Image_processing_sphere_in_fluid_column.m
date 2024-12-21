clc
clear all
close all

folder_path = "D:\IIT Delhi Study Material\MCL705 - Experimental Methods\Viscosity Measuremet using Image Processing\";
name = "SAE-90_crop.avi";
vid = strcat(folder_path,name);

% Radius of ball dropped in the fluid column
r = [6.36 6.09 6.22 6.02 6.33 6.39 6.44 6.4 6.22]*10^-3;

% Density of steel ball used in bearing dropped in the fluid column
rho_sphere = 7810;

% Acceleration due to gravity
g = 9.81;

if(contains(name,"SAE-90"))
    col_ht = 0.9271;
    r = r(1:3);
    rho_liq = 893;
    minBlobArea = 40;
    maxBlobArea = 700;
    noisePxlSz = 35;
    thresholdVal = 27.5;
elseif(contains(name, "SAE-50"))
    col_ht = 0.9525;
    r = r(4:6);
    rho_liq = 898;
    minBlobArea = 290;
    maxBlobArea = 500;
    noisePxlSz = 180;
    thresholdVal = 30;
elseif(contains(name, "SAE-40"))
    col_ht = .8890;
    r = r(7:9);
    rho_liq = 887;
    minBlobArea = 300;
    maxBlobArea = 1300;
    noisePxlSz = 280;
    thresholdVal = 30;
end



[coord, objSz, time] = track_ball(vid, minBlobArea, maxBlobArea, noisePxlSz, thresholdVal)
y_coeff = smooth_vel([coord,objSz,time], vid, col_ht);

for i=1:3
    vel(i) = y_coeff{i}(1);
end

n=length(vel);
mu = 2*r.^2.*(rho_sphere - rho_liq)*g./(9.*vel);
U_vel = tinv(0.975,n-1)*std(vel)/sqrt(n);
U_r = tinv(0.975,n-1)*std(r)/sqrt(n);
U_mu_calc = mean(mu)*sqrt((2*U_r/mean(r))^2+(U_vel/mean(vel))^2);
U_mu_tab = tinv(0.975,n-1)*std(mu)/sqrt(n);

Rel_U_tab = U_mu_tab/mean(mu)
Rel_U_calc = U_mu_calc/mean(mu)

calc_lim = [mean(mu) - U_mu_calc, mean(mu) + U_mu_calc]
tab_lim = [mean(mu) - U_mu_tab, mean(mu) + U_mu_tab]