function fnPlotOutput(soln)

f2 = figure(2); 
clf(f2);

f2.Name = 'Output Solution';

s = soln.grid.sLap;
x = soln.grid.state;
u = soln.grid.control;

v = x(1,:);
T = u(1,:);
a = u(2,:).*180/pi;

%% Plot the velocity profile
subplot(3,1,1);
plot(s,v,'LineWidth',3);
hold on
plot(s,v,'ob');
xlabel('distance (m)');
ylabel('velocity (m/s)');
xlim([s(1), s(end)]);
ylim([0, 100*round(max(v)/100,1) + 5]);
title(['Velocity profile || ', num2str(soln.info.objVal), 's || ', num2str(soln.info.nlpTime), 's']);

%% Plot the torque profile
subplot(3,1,2);
plot(s,T,'LineWidth',2);
hold on
plot(s,T,'ob');
plot(s,zeros(1,length(s)), '--b')
xlabel('distance (m)');
ylabel('torque (Nm)');
xlim([s(1), s(end)]);
ylim([soln.problem.bounds.control.low(1), soln.problem.bounds.control.upp(1)]);
title('Torque profile');

%% Plot the steering trace
subplot(3,1,3);
plot(s,a,'LineWidth',2);
hold on
plot(s,a,'ob');
plot(s,zeros(1,length(s)), '--b')
xlabel('distance (m)');
ylabel('steering (deg)');
xlim([s(1), s(end)]);
ylim([soln.problem.bounds.control.low(2)*180/pi, soln.problem.bounds.control.upp(2)*180/pi]);
title('Steering trace');

end