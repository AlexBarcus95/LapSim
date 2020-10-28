function [td] = fnInitTrack(sDist,nGrid)

td = struct();

curv = zeros(1,nGrid);
curv(ceil(length(curv)*0.3)) = 0.02;
curv(ceil(length(curv)*0.8)) = 0.1;

td.sLap = linspace(0,sDist,nGrid);
td.curv = curv;

end