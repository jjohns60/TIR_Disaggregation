function TIF_out = TIFformat(path,fill_value,scale_factor,additive_scale_factor)
%TIFformat reads in a specified .tif file to MATLAB
%   Formats a given a .tif file for use in TIR_Disaggregation codes
%   Inputs
%   path: file path to .tif file
%   scale_factor: the scale factor for the given input data
%   fill_value: specified fill value for given input data

D = double(imread(path));
D(D == fill_value) = NaN;
D = D*scale_factor + additive_scale_factor;

TIF_out = D;
end

