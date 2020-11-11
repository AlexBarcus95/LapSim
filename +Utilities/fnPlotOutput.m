function fnPlotOutput(soln, bOverlayGuess)

f2 = figure(2); 
clf(f2);

s = soln.grid.sLap;
x = soln.grid.state;
u = soln.grid.control;

v = x(1,:);
T = u(1,:);
a = u(2,:).*180/pi;

%% Plot the velocity profile
subplot(2,2,1);
plot(s,v,'LineWidth',3,'Color','b');
hold on;
plot(s,v,'ob','HandleVisibility','off');
xlabel('distance (m)');
ylabel('velocity (m/s)');
xlim([s(1), s(end)]);
ylim([0, 100*round(max(v)/100,1) + 5]);
title(['Velocity profile || ', num2str(soln.info.objVal), 's || ', num2str(soln.info.nlpTime), 's']);
grid on;
if bOverlayGuess
    plot(s,soln.problem.guess.state(1,:),'or');
    legend('Final Result', 'Initial Guess');
end

%% Plot the steering trace
subplot(2,2,2);
plot(s,a,'LineWidth',2,'Color','b');
hold on;
plot(s,a,'ob','HandleVisibility','off');
plot(s,zeros(1,length(s)), '--b','HandleVisibility','off')
xlabel('distance (m)');
ylabel('steering (deg)');
xlim([s(1), s(end)]);
ylim([soln.problem.bounds.control.low(2)*180/pi, soln.problem.bounds.control.upp(2)*180/pi]);
title('Steering trace');
grid on;
if bOverlayGuess
    plot(s,soln.problem.guess.control(2,:),'or');
    legend('Final Result', 'Initial Guess');
end

%% Plot the torque profile
subplot(2,2,3);
plot(s,T,'LineWidth',2,'Color','b');
hold on;
plot(s,T,'ob','HandleVisibility','off');
plot(s,zeros(1,length(s)), '--b','HandleVisibility','off')
xlabel('distance (m)');
ylabel('torque (Nm)');
xlim([s(1), s(end)]);
ylim([soln.problem.bounds.control.low(1), soln.problem.bounds.control.upp(1)]);
title('Torque profile');
grid on;
if bOverlayGuess
    plot(s,soln.problem.guess.control(1,:),'or');
    legend('Final Result', 'Initial Guess');
end

%% Plot the lateral tyre grip
subplot(2,2,4);
dsSystem = soln.problem.dsSystem;
vd = dsSystem.vd;
Fy = dsSystem.Models.Tyre.Run(x,u,vd);
Fz = vd.chassis.m*9.81;
mu = Fy./Fz;
plot(a,mu,'o');
xlabel('steering (deg)');
ylabel('Lateral grip');
xlim([min(a), max(a)]);
ylim([min(mu), max(mu)]);
title('Lateral grip vs. steering angle');
grid on

%% Set title
f2.Name = ['Maneouvre Time: ', num2str(soln.info.objVal), 's || Solve Time:', num2str(soln.info.nlpTime), 's'];

end