function [problem] = fnInitTrack(problem, bPlotTrackDef)

%% Generate the track definition

switch problem.options.method
    case 'trapezoid'
        nGrid = problem.options.trapezoid.nGrid;
    case 'hermiteSimpson'
        nGrid = 2*problem.options.hermiteSimpson.nSegment + 1;
    otherwise
        error('Invalid method.');
end

td = struct();

td.sLap = linspace(0,300,nGrid);
td.curv = zeros(1,nGrid);
td.curv( (td.sLap > median(td.sLap)) & (td.sLap < (median(td.sLap) + pi*20) )) = 1/22;
td.curv_nosmooth = td.curv; % Store
td.curv = smooth(td.curv, 0.3, 'lowess')';

td.d_sLap   = [diff(td.sLap), td.sLap(end) - td.sLap(end-1)];
td.aYaw  	= cumsum(td.curv.*td.d_sLap);
td.xCar 	= cumsum(td.d_sLap.*cos(-td.aYaw));
td.yCar 	= cumsum(td.d_sLap.*sin(-td.aYaw));

problem.dsSystem.td = td;

%% Plot the track definition

if bPlotTrackDef
    fnPlotTrackDefinition(td);
end

end

function fnPlotTrackDefinition(td)

f1 = figure(1);
clf(f1);

f1.Name = 'Track Definition';

subplot(2,2,1);
plot(td.sLap, td.curv_nosmooth);
hold on;
plot(td.sLap, td.curv, 'LineWidth', 2);
plot(td.sLap, td.curv, 'ob');
title('Track curvature');
xlabel('sLap'); ylabel('curv');

subplot(2,2,2)
plot(td.sLap, td.aYaw);
title('Vehicle yaw angle');
xlabel('sLap'); ylabel('aYaw');

subplot(2,2,3)
plot(td.sLap, td.xCar, 'b');
hold on;
plot(td.sLap, td.yCar, 'r');
title('xCar and yCar');
legend('xCar', 'yCar');
xlabel('sLap'); ylabel('yCar and xCar');

subplot(2,2,4)
plot(td.xCar, td.yCar, 'LineWidth', 3);
hold on;
plot(td.xCar, td.yCar, 'or');
title('Car position');
xlabel('xCar'); ylabel('yCar');

axis equal

end