function f = fnObjective(z)
% 
%  f = f(x,y) = integrand of the objective function
%

v = z(1,:);

% Minimise inverse of velocity
f = 1./v;

end