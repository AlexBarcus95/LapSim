function dx = fnDynamics(x,u,vd)
% This function returns the dynamics of the car

v = x(1,:);
T = u(1,:);

D = 0.5*vd.aero.rho*vd.aero.Ax*vd.aero.Cx.*v.^2;
dv = (1/vd.chassis.m)*((1/vd.tyres.rear.Rl).*T - D)./v;

dx = [dv];

end