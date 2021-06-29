%% Takes input pixel data for disaggregation functions
clear
clc

%% Inputs

% temporally matched Landsat emissivity data
EMIS_scaleFactor = 0.0001;
EMIS_fill = -9999;
EMIS_path = '/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/MODIS/LC08_ST_EMIS_MODIS_c.tif';

% path to recent Landsat RGB data
RGB_scaleFactor = 0.0000275;
RGB_additiveSF = -0.2;
RGB_fill = 0;
blue_path = '/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/MODIS/LC08_SR_B2_MODIS_c.tif';
green_path = '/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/MODIS/LC08_SR_B3_MODIS_c.tif';
red_path = '/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/MODIS/LC08_SR_B4_MODIS_c.tif';


%% read in data
pixel_EMIS = TIFformat(EMIS_path,EMIS_fill,EMIS_scaleFactor,0);
%combines RBG into single 3D matrix, where layer 1 = red, 2 = green, 3 = blue
pixel_R = TIFformat(red_path,RGB_fill,RGB_scaleFactor,RGB_additiveSF);
pixel_G = TIFformat(green_path,RGB_fill,RGB_scaleFactor,RGB_additiveSF);
pixel_B = TIFformat(blue_path,RGB_fill,RGB_scaleFactor,RGB_additiveSF);
pixel_RGB = NaN([size(pixel_R) 3]);
pixel_RGB(:,:,1) = pixel_R;
pixel_RGB(:,:,2) = pixel_G;
pixel_RGB(:,:,3) = pixel_B;

%clean up workspace
clearvars -except pixel_EMIS pixel_RGB pixel_R pixel_G pixel_B pixel_NLCD pixel_TIR T_tree T_snow

%% classify region based on EMIS and RGB. AND calculate proportional coverages
[classEMIS_KM_2,propEMIS_KM_2] = createClassifier(pixel_EMIS,'kmeans',2);
[classEMIS_KM_3,propEMIS_KM_3] = createClassifier(pixel_EMIS,'kmeans',3);
[classRGB_KM_2,propRGB_KM_2] = createClassifier(pixel_RGB,'kmeans',2);
[classRGB_KM_3,propRGB_KM_3] = createClassifier(pixel_RGB,'kmeans',3);
[classEMIS_T0,propEMIS_T0] = createClassifier(pixel_EMIS,'threshold',.99);
[classEMIS_T1,propEMIS_T1] = createClassifier(pixel_EMIS,'threshold',.98);
[classEMIS_T2,propEMIS_T2] = createClassifier(pixel_EMIS,'threshold',.97);
[classEMIS_T3,propEMIS_T3] = createClassifier(pixel_EMIS,'threshold',.96);
