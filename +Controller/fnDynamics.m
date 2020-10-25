function dz = fnDynamics(z,u,vd)
% dz = dynamics(z,u,vd)
%
% This function returns the dynamics of the car. The state of
% the car is its velocity, and the control is the torque supplied.
%
% INPUTS:
%   z = [1, n] = [v] = state = [velocity];
%   u = [1, n] = [T] = state = [torque];
%
% OUTPUTS:
%  dz = dz/dt
%

v = z(1,:);
T = u;

D = 0.5*vd.aero.density*vd.aero.A*vd.aero.Cd.*v.^2;
dv = (1/vd.chassis.m)*((1/vd.tyres.Rl).*T - D)./v;

dz = [dv];

end