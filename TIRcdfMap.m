function map = TIRcdfMap(T,R,pbounds,method)
%TIRpercentileMap Associate data in T with data in R using percentiles
%This function uses cumulative distribution functions to map values in one
%distribution (R) to another (T)
%   INPUTS
%   T: input grid of temperature (or other) data
%   R: input grid of reflectance (or other) data (will not be trimmed)
%   pbounds: trims the input data T, based on upper and lower bound
%   percentiles input as [p_low p_high] where p_low and p_high are the 
%   upper and lower bound percentiles [must be 0 - 100]. i.e. [1 99] will
%   retain the middle 98% of the data for mapping to R
%   method: percentile or probability. Mapping using cdf x-axis, vertical
%   line to associate values (percentile) or using cdf y-axis, horizontal
%   line to associate values. For example, percentile will retain the
%   original R data's distribution while probability will match the
%   distribution of R to that of T
%   OUTPUTS
%   map: a matrix of size(R) with mapped values of R from T


method = lower(method);

%DELETE
%T = T_snow;
%R = RGB_grayscale_snow; %use index of snow class in classifier to get emissivities

%reformat/trim data
T = double(T); %convert to double
T = T(~isnan(T)); %remove NaNs
T = sort(T(:)); %sort from lowest (row 1) to highest value (row end)
R = double(R);
map = R;
R = R(~isnan(R));
R = sort(R(:));

%trim data
p_low = prctile(T,pbounds(1));
p_high = prctile(T,pbounds(2));
T = T(T >= p_low & T <= p_high);

%TEST
%{
p_low = prctile(R,pbounds(1));
p_high = prctile(R,pbounds(2));
R = R(R >= p_low & R <= p_high);
%}

%create normalized x,y inputs for cdf
x_T = (T - min(T))/(max(T) - min(T));
y_T = [1:length(x_T)]'./length(x_T);
x_R = (R - min(R))/(max(R) - min(R));
y_R = [1:length(x_R)]'./length(x_R);

%figure; hold on; plot(x_T,y_T,x_R,y_R); legend('Tcdf','Rcdf')

if strcmp(method,'percentile') %mapping via normalized cdf x-dimension
    
    idx = knnsearch(x_T,x_R);
    D = x_T(idx);
    %map D to T values
    TRmap = NaN(length(U),2);
    TRmap(:,1) = x_R*(max(R)-min(R)) + min(R); %x_R mapped back to original values
    TRmap(:,2) = flipud(D*(max(T)-min(T)) + min(T)); %flip as reflectances are inverse to temperatures

elseif strcmp(method,'probability') %mapping via normalized cdf y-dimension
    
    idx = knnsearch(y_T,y_R);
    D = x_T(idx);
    %map D to T values
    TRmap = NaN(length(D),2);
    TRmap(:,1) = x_R*(max(R)-min(R)) + min(R); %x_R mapped back to original values
    TRmap(:,2) = flipud(D*(max(T)-min(T)) + min(T));
    
end

%replace values in R_copy with mapped values
for i = 1:length(TRmap)
    val = TRmap(i,1);
    idx = (map == val);
    map(idx) = TRmap(i,2);
end

end

