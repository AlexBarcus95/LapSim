function fnPlotOutputSingle(soln)

f3 = figure(3); 
clf(f3);

s = soln.grid.sLap;
x = soln.grid.state;
u = soln.grid.control;

vUpp = 100*round(max(x(1,:))/100,1);
v = x(1,:).*10/vUpp;
T = u(1,:).*10/max(abs([soln.problem.bounds.control.low(1), soln.problem.bounds.control.upp(1)]));
a = u(2,:).*10/max(abs([soln.problem.bounds.control.low(2), soln.problem.bounds.control.upp(2)]));

ax = axes;
axes(ax);
plot(s,zeros(1,length(s)), '--k','HandleVisibility','off', 'LineWidth', 2);
hold on;
plot(s,v,'LineWidth',3);
plot(s,a,'LineWidth',3);
plot(s,T,'LineWidth',3);
ylim([-10,10]);
xlim([s(1), s(end)]);

grid minor;
ax.LineWidth = 3;
ax.YTickLabel = [];

xlabel('distance (m)');
legend('Velocity (m/s)', 'Steering (deg)', 'Torque (Nm)');
f3.Name = 'Single Overlay of States and Controls';

end