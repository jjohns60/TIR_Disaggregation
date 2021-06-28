function Tmat = trange3(Tcenter,Tinc)
%trange3 Returns 3 temperature vector with mean and 1 SD (or incremenent)
%above and below the mean
%   Tcenter: the average, or center value
%   Tinc: the incremement to return values above and below
%if temperature colder than is observed on Earth in Kelvin, assume Celsius
%and convert
if Tcenter < 150
    Tcenter = Tcenter + 273.15;
end
Tmean = Tcenter;
T_down = Tcenter - Tinc;
T_up = Tcenter + Tinc;
Tmat = [Tmean,T_up,T_down];
end

