function f = fnObjective(z)
% f = objective(z,u)
%
% This function computes the integrand of the objective function for the
% SL acceleration problem. The car will choose the quickest path.
%
% INPUTS:
%   z = [1, n] = [v] = state = [velocity];
%
% OUTPUTS:
%  f = f(x,y) = integrand of the objective function
%

v = z(1,:);

% Minimise inverse of velocity
f = 1./v;

end