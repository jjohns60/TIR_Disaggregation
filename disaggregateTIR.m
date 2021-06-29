function TIR = disaggregateTIR(Tpixel,classifier,class_legend,lapse_grid)
%disaggregateTIR Create downscaled TIR grid based on land cover
%classification and drone observed temperatures
%   Tpixel: overarching pixel temperature (from satellite, coarse res.)
%   classifier: high resolution grid with land cover classifications
%   class_legend: matrix specifying temperatures corresponding to
%   classifications in 'classifier'. Column vectors with first column being
%   the class numbers and second row being their corresponding
%   temperatures.
%   lapse_grid: grid with lapse rate corrections (based on air temperature)

Tpixel = 274.78;
classifier = classRGB_KM_3;
class_legend = [1 272.7; 2 270.63; 3 274.77];

%compute TIR grid from inputs
TIR = NaN(size(classifier));
for i = 1:

FLIRtiff(TIR); c = colorbar; ylabel(c,'Temperature (K)');

%rescale TIR values so average matches Tpixel

%generate random values using normal distribution (or distribution type
%matching the drone data)
dist_mean = 266.51; %distribution mean
dist_SD = 1.88; %distribution standard deviation
N = 200; %number of values within class
vals = dist_SD.*randn(N,1) + dist_mean; %generate numbers using the specified distribution





end

