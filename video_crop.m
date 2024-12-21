% Script to crop a video to a specific region and save the cropped video
% This script reads an input video, allows the user to define a crop region
% interactively using the first frame, and then applies this cropping to all
% subsequent frames. The cropped frames are saved to a new video file.

clc
clear all
close all

% Specify the input video file path
% Replace 'INPUT_VIDEO_PATH' with the actual path to the input video file
vid = VideoReader('INPUT_VIDEO_PATH');

% Specify the output video file path
% Replace 'OUTPUT_VIDEO_PATH' with the desired path to save the cropped video
croppedVideo = VideoWriter('OUTPUT_VIDEO_PATH', "Uncompressed AVI");
croppedVideo.FrameRate = vid.FrameRate; % Match the frame rate of the original video

% Get the total number of frames in the input video
disp(['Total number of frames: ', num2str(vid.NumFrames)]);

% Open the VideoWriter object to prepare for writing
open(croppedVideo);

% Initialize frame counter
frameCounter = 1;

while hasFrame(vid)
    % Read the next frame from the video
    Frame = readFrame(vid);
    
    if frameCounter == 1
        % For the first frame, allow the user to define the crop region interactively
        figure(1);
        [croppedFrame, rect] = imcrop(Frame); % User selects the crop region interactively
        
        % Define the crop region based on the user's selection
        cropRegion = rect; 

        % Write the cropped first frame to the output video
        writeVideo(croppedVideo, croppedFrame);
        
        % Display the original and cropped first frames for verification
        changedPlot = figure(2);
        subplot(1, 2, 1), imshow(Frame), title('Original Frame');
        subplot(1, 2, 2), imshow(croppedFrame), title('Cropped Frame');
    end
    
    % Crop the current frame using the selected crop region
    croppedFrame = imcrop(Frame, cropRegion);
    
    % Write the cropped frame to the output video
    writeVideo(croppedVideo, croppedFrame);
    
    % Increment the frame counter
    frameCounter = frameCounter + 1;
end

% Close the VideoWriter object after processing all frames
close(croppedVideo);

% Display a message indicating successful completion
disp('Cropping completed successfully.');
