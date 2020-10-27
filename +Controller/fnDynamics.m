function dz = fnDynamics(z,u,vd)
%
% This function returns the dynamics of the car
%

v = z(1,:);
T = u;

D = 0.5*vd.aero.density*vd.aero.A*vd.aero.Cd.*v.^2;
dv = (1/vd.chassis.m)*((1/vd.tyres.Rl).*T - D)./v;

dz = [dv];

end