classdef Model_Aero
    
    methods (Access = public)
        
        function [vd] = Initialise(~, vd, ~)
            vd.aero.rho = 1.3;
            vd.aero.Ax = 0.7;
            vd.aero.Cx = 1;
        end
        
    end
end