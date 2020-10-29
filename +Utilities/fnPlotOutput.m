function fnPlotOutput(soln)

f = figure(1); 
clf(f);

s = soln.grid.sLap;
x = soln.grid.state;
v = x(1,:);
u = soln.grid.control;

f.Name = num2str(soln.info.objVal);
subplot(2,1,1);
plot(s,v,'LineWidth',3);
hold on
plot(s,v,'ob');
xlabel('distance (m)');
ylabel('velocity (m/s)');
xlim([s(1), s(end)]);
ylim([0, 100*round(max(v)/100,1) + 5]);
title(['Velocity profile || ', num2str(soln.info.objVal), 's']);

subplot(2,1,2);
plot(s,u(1,:),'LineWidth',2);
hold on
plot(s,u(1,:),'ob');
plot(s,zeros(1,length(s)), '--b')
xlabel('distance (m)');
ylabel('torque (Nm)');
xlim([s(1), s(end)]);
ylim([soln.problem.bounds.control.low(1), soln.problem.bounds.control.upp(1)]);
title(['Torque profile || ', num2str(soln.info.nlpTime), 's']);

end