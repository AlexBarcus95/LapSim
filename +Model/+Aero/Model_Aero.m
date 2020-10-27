classdef Model_Aero
    
    methods (Access = public)
        
        function [vd] = Initialise(~, vd, ~)
            vd.aero.rho = 1.3;
            vd.aero.Ax = 1.5;
            vd.aero.Cx = 1;
        end
        
    end
end