function [td] = fnInitTrack(sDist,nGrid)

td = struct();

curv = zeros(1,nGrid);
curv(ceil(length(curv)*0.6)) = 0.02;

td.sLap = linspace(0,sDist,nGrid);
td.curv = curv;

end