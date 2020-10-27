classdef Model_Tyre
 	
    methods (Access = public)
        
        function [vd] = Initialise(~, vd, ~)
            vd.tyres.rear.Rl = 0.5;
        end
        
    end
end