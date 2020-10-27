function [td] = fnInitTrack(sDist,gridSize)

td = struct();

curv = zeros(1,gridSize);
curv(ceil(length(curv)*0.3)) = 0.02;
curv(ceil(length(curv)*0.8)) = 0.1;

td.sLap = linspace(0,sDist,gridSize);
td.curv = curv;

end