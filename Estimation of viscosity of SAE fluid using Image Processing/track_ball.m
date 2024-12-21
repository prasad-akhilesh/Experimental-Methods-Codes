function [coord, objSz, time] = track_ball(vid, minBlobArea, maxBlobArea, noisePxlSz, thresholdVal)

% ADDME This function takes a video file containing a vertical fluid column
% in which a spherical ball is dropped for the velocity of the ball to be
% tracked.
% 
% Input: -
%   1) vid - Path to the video file path
%   
%   2) minBlobArea - minimum Area of the spherical ball to be tracked. This is
%   to be found out by monitoring the size of the object that is detected.
%   One would need to monitor whether the blob detected is the ball.
%   
%   3) maxBlobArea - Maximum Area of the spherical ball to be tracked. This is
%   done to eliminate the situations where there might be large difference
%   between two frames due to some disturbance, in this case we need to
%   eliminate these large noises from the data.
%   
%   4) noisePxlSz - The size of the detected connected objects that needs
%   to be eliminated from the frame using bwareaopen() function.
%   5) thresholdVal - This is the value of the threshold that is the 

    fontSize = 22;
%     minBlobArea = 300;
%     maxBlobArea = 1300;
    ballProp = [];
    ballArea = [];
            
    
    vid = VideoReader(vid);
    
    prevFrame = readFrame(vid);
    prevGrayFrame = im2gray(prevFrame);
    figure(1)
    imshow(prevFrame)
    coordinateLim = ginput(2);
    findobj('Type', 'figure');
    close(figure(1))
    
    frameCounter = 1;
    numberOfFrames = vid.NumFrames;
    
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    
    while hasFrame(vid)
        frameCounter = frameCounter + 1;
        origFrame = readFrame(vid);
        currGrayFrame = im2gray(origFrame);
        FilterFrame = medfilt2(currGrayFrame,[5 5]);
        FrameDiff = imabsdiff(currGrayFrame, prevGrayFrame) > thresholdVal;
        
        % Get rid of small blobs smaller than 250 pixels.
        mask = bwareaopen(FrameDiff, noisePxlSz);
    
        
        % Mask image by multiplying each channel by the mask.
        maskedFrame = FilterFrame.*cast(mask, 'like', FilterFrame);
        
        binaryFrame = imbinarize(maskedFrame,"adaptive","ForegroundPolarity","bright");
        stats = regionprops(binaryFrame, 'Centroid', 'Area');
    
        for i = 1:length(stats)
            % Extract centroid and area of the current blob
            FeatureProp = [stats(i).Centroid stats(i).Area frameCounter];
            
            % Check if the blob area is within the specified range then
            % only track the position of the ball for further processing
            if FeatureProp(1) > min(coordinateLim(:,1)) && FeatureProp(1) < max(coordinateLim(:,1)) ...
                && FeatureProp(3)>= minBlobArea && FeatureProp(3)<= maxBlobArea
                    ballProp = [ballProp; FeatureProp];
            end
        end
        if(~isempty(ballProp) && ballProp(end,4)-frameCounter<=15)
            hPlot = subplot(1, 3, 1);
            imshowpair(binaryFrame,origFrame,'montage')
            hold on
    	    axis image;
    	    caption = sprintf('Frame %d of %d.', frameCounter, numberOfFrames);
    	    title(caption, 'FontSize', fontSize);
            plot(ballProp(:,1)+vid.Width,ballProp(:,2),"k.")
            drawnow;
        end
        fprintf('Frame %4d of %d \t with time processed %d of %d \n', frameCounter, numberOfFrames, frameCounter/vid.FrameRate, vid.NumFrames/vid.FrameRate)
    
        ballPosPlot = subplot(1,3,2);
        if(~isempty(ballProp) && ballProp(end,4)-frameCounter<=15)
            distTravel = sqrt((ballProp(:,1)-mean(ballProp(:,1))).^2 + (ballProp(:,2)-min(ballProp(:,2))).^2);
            time = ballProp(:,4)/vid.FrameRate;
            plot(time,distTravel)
            xlabel("Time(sec)$\longrightarrow$",Interpreter="latex")
            ylabel("Distance Travelled (pixels)$\longrightarrow$",Interpreter="latex")
            subplot(1,3,3)
            plot(ballProp(:,4),ballProp(:,3),'r.')
            xlabel("Frames $\longrightarrow$",Interpreter="latex")
            ylabel("Area of detected object (pixels) $\longrightarrow$",Interpreter="latex")
        end
        prevGrayFrame = currGrayFrame;
        prevFilterFrame = FilterFrame;
    end
    hold off;
    coord = ballProp(:,1:2)
    objSz = ballProp(:,3)
end