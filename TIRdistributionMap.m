%% Code for statistical downscaling of temperature data using drone-based temperature observations
clc
clear

%% Inputs
%savepath
savepath = 'GOES_classRGB_KM_3_TIR_distmapping_425PM.tif';

%from cropped drone mosaics
T_snow = imread('/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/drone_data/F_2020_02_02__4/F4_2_2_2020_snow.tif');
T_tree = imread('/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/drone_data/F_2020_02_02__4/F4_2_2_2020_tree.tif');

%specify classifier
load('/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/Disaggregation_Data/Classifiers/GOES_classRGB_KM_3.mat');
C = classRGB_KM_3;
figure; imshow(C); caxis([min(C(:)) max(C(:))]); %to verify classes

%load in red green and blue reflectance
red_path = '/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/GOES/LC08_SR_B4reflectance_GOES_c.tif';
R = imread(red_path);
G = imread('/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/GOES/LC08_SR_B3reflectance_GOES_c.tif');
B = imread('/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/GOES/LC08_SR_B2reflectance_GOES_c.tif');


%% Processing
%remove fill values from drone imagery, replace with NaN
T_snow(T_snow < -100 | T_snow == 0) = NaN;
T_snow = T_snow + 273.15;
T_tree(T_tree < -100 | T_tree == 0) = NaN;
T_tree = T_tree + 273.15;

%from RGB imagery, overall reflectance from RGB combined, requires
%classifier
RGB = NaN([size(R) 3]);
RGB(:,:,1) = R; RGB(:,:,2) = G; RGB(:,:,3) = B;
%convert to grayscale using built in matlab function
RGB_grayscale = rgb2gray(RGB);
%make all values not in class NaN

%goes
RGB_grayscale_snow = RGB_grayscale;
RGB_grayscale_snow(C ~= 2) = NaN; %verify each time (for GOES 3 class snow is 2)
RGB_grayscale_tree = RGB_grayscale;
RGB_grayscale_tree(C ~= 1) = NaN; %verify each time (for GOES 3 class trees are 1)
RGB_grayscale_mixed = RGB_grayscale;
RGB_grayscale_mixed(C ~= 3) = NaN; %verify each time (for GOES 3 class mixed is 3)

%modis
%{
RGB_grayscale_snow = RGB_grayscale;
RGB_grayscale_snow(C ~= 2) = NaN; %verify each time (for MODIS 3 class snow is 2)
RGB_grayscale_tree = RGB_grayscale;
RGB_grayscale_tree(C ~= 3) = NaN; %verify each time (for MODIS 3 class trees are 3)
RGB_grayscale_mixed = RGB_grayscale;
RGB_grayscale_mixed(C ~= 1) = NaN; %verify each time (for MODIS 3 class mixed is 1)
%}
%get mapped version of reflectances to temperatures
%method uses the 'probability' method in an attempt to retain the
%temperature distribution observed by the drone imagery
mapSNOW = TIRcdfMap(T_snow,RGB_grayscale_snow,[25 75],'probability');
mapTREE = TIRcdfMap(T_tree,RGB_grayscale_tree,[25 75],'probability');

%for mixed perform with both datasets over mixed REFL category, then average

mapSNOWm = TIRcdfMap(T_snow,RGB_grayscale_mixed,[25 75],'probability');
mapTREEm = TIRcdfMap(T_tree,RGB_grayscale_mixed,[25 75],'probability');
mapMIXED = (mapSNOWm + mapTREEm)./2;


%recombine all into final mosaic (if mixed class exists)
mapSNOW(isnan(mapSNOW)) = 0;
mapTREE(isnan(mapTREE)) = 0;
mapMIXED(isnan(mapMIXED)) = 0;
A_OUTPUT_TIR = mapSNOW + mapTREE + mapMIXED;
A_OUTPUT_TIR(A_OUTPUT_TIR == 0) = NaN;
figure; imshow(A_OUTPUT_TIR); caxis([nanmin(A_OUTPUT_TIR(:)) nanmax(A_OUTPUT_TIR(:))]);

%% Georeference and save
geofile = red_path;
[~,R] = readgeoraster(geofile);
RefCode = 32613; %for georeferencing, code for WGS 84/UTM zone 13N
geotiffwrite(savepath,A_OUTPUT_TIR,R,'CoordRefSysCode',RefCode)