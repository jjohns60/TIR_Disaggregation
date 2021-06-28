%% Takes input pixel data for disaggregation functions
clear
clc

%% Inputs
%if single pixel just input single value
pixel_TIR = 274.78;
%individual temperature components from drone imagery
T_tree = 1.62 + 273.15;
T_snow = -2.52 + 273.15;

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

% path to recent NLCD data
NLCD_scaleFactor = 1;
NLCD_fill = 0;
NLCD_path = '/Volumes/GRA_Data_Backup/DroneTIR_MicroclimFT/Data/subPixel_investigations/MODIS/NLCD_MODIS_c.tif';



%read in data
pixel_EMIS = TIFformat(EMIS_path,EMIS_fill,EMIS_scaleFactor,0);
%combines RBG into single 3D matrix, where layer 1 = red, 2 = green, 3 = blue
pixel_R = TIFformat(red_path,RGB_fill,RGB_scaleFactor,RGB_additiveSF);
pixel_G = TIFformat(green_path,RGB_fill,RGB_scaleFactor,RGB_additiveSF);
pixel_B = TIFformat(blue_path,RGB_fill,RGB_scaleFactor,RGB_additiveSF);
pixel_RGB = NaN([size(pixel_R) 3]);
pixel_RGB(:,:,1) = pixel_R;
pixel_RGB(:,:,2) = pixel_G;
pixel_RGB(:,:,3) = pixel_B;
pixel_NLCD = TIFformat(NLCD_path,NLCD_fill,NLCD_scaleFactor,0);

%clean up workspace
clearvars -except pixel_EMIS pixel_RGB pixel_R pixel_G pixel_B pixel_NLCD pixel_TIR T_tree T_snow

%% classify region based on EMIS, RGB, and NLCD
%partition into vegetation and snow clusters using kmeans
EMIS_class = reshape(kmeans(pixel_EMIS(:),3),size(pixel_EMIS));
RGB_class = reshape(kmeans([pixel_R(:) pixel_G(:) pixel_B(:)],2),size(pixel_RGB,[1 2]));


%% Compute estimated proportional coverages



