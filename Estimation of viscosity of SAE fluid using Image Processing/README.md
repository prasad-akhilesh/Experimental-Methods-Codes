The overview of workflow for analyzing the image processing algorithm:
- Cropping of the video to the region of interest
- Processing the cropped frames to get the position of the balls as they travel through the liquid column.
- Processing the displacement-time data to calculate the velocity of the balls
- Uncertainty in determination of viscosity of a fluid

In the main program we call the <code>track_ball()<\code> and the <code>smooth_vel()<\code> functions to carry
out the uncertainty analysis. The process flow is described below:
- First we create the file path in two separate variables, one is the folder location and the other the file name in that folder location.
- A check for the file name is carried out, which then sets the values of the variables to be supplied to the track ball() function. These values been arrived at by trial and error.
- Finally the values obtained from the track ball() function are used to invoke the smooth vel() function.
- From the smooth vel function we get the linear regression coefficients using which we get the velocity. This velocity is used to carry out the uncertainty analysis for the function.
