function soln = LTS(problem)
% soln = LTS(problem)

problem = Utilities.fnInputValidation(problem);   % Check inputs
problem = Utilities.fnGetDefaultOptions(problem); % Complete options struct

%%%% Call the underlying transcription method:
switch problem.options.method
    case 'trapezoid'
        soln = Solver.fnTrapezoid(problem);
    case 'hermiteSimpson'
        soln = Solver.fnHermiteSimpson(problem);
    otherwise
        error('Invalid method.');
end

end