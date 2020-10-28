function fnPlotOutput(soln)

f = figure(1); 
clf(f);

s = soln.grid.time;
x = soln.grid.state;
v = x(1,:);
u = soln.grid.control;
T = u(1,:);

f.Name = num2str(soln.info.objVal);
subplot(2,1,1);
plot(s,v,'LineWidth',3);
hold on
plot(s,v,'ob');
xlabel('distance (m)');
ylabel('velocity (m/s)');
xlim([s(1), s(end)]);
ylim([0, 100*round(max(v)/100,1)]);
title(['Velocity profile || ', num2str(soln.info.objVal), 's']);

subplot(2,1,2);
plot(s,T,'LineWidth',2);
hold on
plot(s,T,'ob');
plot(s,zeros(1,length(s)), '--b')
xlabel('distance (m)');
ylabel('torque (Nm)');
xlim([s(1), s(end)]);
ylim([soln.problem.bounds.control.low, soln.problem.bounds.control.upp]);
title(['Torque profile || ', num2str(soln.info.nlpTime), 's']);

end