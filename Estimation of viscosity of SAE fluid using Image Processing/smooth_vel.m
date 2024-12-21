function y_coeff = smooth_vel(ballProp, vid, col_len)

% ADDME Fits a displacement-time curve to a video of a ball falling in a
% liquid column.
% 
% Inputs: -
% 1) ballPos - A mx4 array that stores the position of the object as x- and
%    y- coordinates and also the size of the captured object.
% 2) vid - Path of the file from which we will be taking the values of pixel to determine the length of the column in pixels  
% 3) col_len - Length of the column in the real world. This will be used to
% calibrate the frame coordinate system to world coordinate systems. The
% following values are to be used:
%   a) Column length for SAE-90 = 0.9271 m (36.5in)
%   b) Column length for SAE-50 = 0.9525 m (99.5in - 62in)
%   c) Column length for SAE-40 = 0.8890 m (44in - 9in)
% 
% Outputs: - 
% 2) fitted_y - A function handle that can is fitted to the
% displacement-time curve of the falling body in the fluid column.


    ballPos = {}                    % For filtering and storing values of ballProp
    ballPos{1} = ballProp(1,:)      % To not let ballPos be empty within the loop
    BallDist = {}                   % For storing the distance from the initial position of detection of sphere

    vid = VideoReader(vid);

    % For selecting the points the length between which we know
    h = findobj('type','figure');
    n = length(h);
    figure(n+1);
    imshow(read(vid,500));
    critical_pts = ginput(2);
    column_ht_frame = sqrt((critical_pts(1,1) - critical_pts(2,1))^2+(critical_pts(1,2) - critical_pts(2,2))^2);

    
    % Camera coordinate system to world coordinate system conversion factor
    ccs_to_wcs = column_ht_frame/col_len;
    
    % Computing the first distance to avoid array being empty and allowing
    % for dynamic array update.
    BallDist{1} = sqrt((ballPos{1}(1,1)-ballPos{1}(1,1)).^2 + (ballPos{1}(1,2)-min(ballPos{1}(:,2))).^2)/ccs_to_wcs;
    j=1;
    figure(n+2);
    for i=2:length(ballProp)
        if (ballProp(i,2)>ballProp(i-1,2)) && (ballProp(i,4)>ballProp(i-1,4)) && (ballProp(i,4)-ballProp(i-1,4))<=100/vid.FrameRate
%             ballProp(i,:);
            fprintf("Difference in frames between %d and %d indices is %d and the truth value is %d\n",i,i-1,ballProp(i,4)-ballProp(i-1,4),ballProp(i,4)-ballProp(i-1,4)>=100/vid.FrameRate);
            ballPos{j} = [ballPos{j} ; ballProp(i,:)];
        elseif (ballProp(i,4)-ballProp(i-1,4))>=100/vid.FrameRate;
            disp("Inside elseif");
            ballProp(i,:);
            fprintf("Difference in frames between %d and %d indices is %d and the truth value is %d\n",i,i-1,ballProp(i,3)-ballProp(i-1,3),ballProp(i,3)-ballProp(i-1,3)>=100/vid.FrameRate);
            j=j+1;
            ballPos{j} = ballProp(i,:);
        end
    end
    
    
    
    for j = 1:length(ballPos)
        time = ballPos{j}(:,4);
%       Converting the diatance covered by the ball from pixels to meters
        BallDist{j} = sqrt((ballPos{j}(1,1)-min(ballPos{j}(:,1))).^2 + (ballPos{j}(1,2)-min(ballPos{j}(:,2))).^2)/ccs_to_wcs;
        for i=2:length(ballPos{j})
            if(j<=3)

            BallDist{j} = [BallDist{j}; sqrt((ballPos{j}(i,1)-min(ballPos{j}(:,1))).^2 + (ballPos{j}(i,2)-min(ballPos{j}(:,2))).^2)/ccs_to_wcs];
            end
        end
        hold on

        % Finding the coefficients of the strainght line to fit the
        % displacement vs time curve
        y_coeff{j} = polyfit(time,BallDist{j}, 1);
        fitted_y{j} = @(x) y_coeff{j}(1)*x + y_coeff{j}(2);

%       Plotting the best fit for displacement time curve
        subplot(2,1,1);
        plot(time, fitted_y{j}(time), '--');
        hold on
    
    % Plotting the actual displacement of the ball to visualise the
    % deviations of the positions of the ball to visualise the best fit
    % as compared to the data
        plot(time,BallDist{j},"r*");
        xlabel("Time(sec)$\longrightarrow$",Interpreter="latex")
        ylabel("Distance Travelled (m)$\longrightarrow$",Interpreter="latex")

    % Computing the velocity based on the data from the image
    % processing to show the difference between the computed and
    % average velocity line.
        vel = diff(fitted_y{j}(ballPos{j}(:,3)))./diff(ballPos{j}(:,3));
        smoothed_vel{j} = smooth(vel, 3, 'rlowess');
        subplot(2,1,2);
        plot(time(1:end-1),smoothed_vel{j},'ro');
        hold on;
        plot(time, y_coeff{j}(1)*ones(size(ballPos{j},1),1),'k--',LineWidth=0.9);
        xlabel("Time(sec)$\longrightarrow$",Interpreter="latex")
        ylabel("Velocity(m/s)$\longrightarrow$",Interpreter="latex")
    end
    hold off;
end
