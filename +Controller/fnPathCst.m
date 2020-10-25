function [c, ceq] = fnPathCst(~,z,vd,td)
% [c, ceq] = pathCst(z)
%
% Computes a velocity-matching path constraint
%
% INPUTS:
%   z = [1, n] = [X1; X2; X3; ... ] = state matrix
%
% OUTPUTS:
%   c
%   ceq
%

v = z(1,:);
v_p = vd.chassis.m*td.curv.*v.^2;

c = v_p - 100;
ceq = [];

end