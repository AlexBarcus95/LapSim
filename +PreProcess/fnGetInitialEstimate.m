function [problem] = fnGetInitialEstimate(problem, sMethod)

switch sMethod
    case 'load'
        customGuess = load([cd, '/customGuess.mat']);
        
        sLap_old = customGuess.soln.grid.sLap;
        v_old = customGuess.soln.grid.state(1,:);
        T_old = customGuess.soln.grid.control(1,:);
        a_old = customGuess.soln.grid.control(2,:);
        
        v_guess = interp1(sLap_old, v_old, problem.dsSystem.td.sLap);
        T_guess = interp1(sLap_old, T_old, problem.dsSystem.td.sLap);
        a_guess = interp1(sLap_old, a_old, problem.dsSystem.td.sLap);
        
        problem.guess.state   	= v_guess;
        problem.guess.control   = [T_guess;
                                   a_guess];
    otherwise
        error('Select a method for finding the initial estimate');
end

end