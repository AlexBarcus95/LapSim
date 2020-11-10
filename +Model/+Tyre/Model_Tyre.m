classdef Model_Tyre
 	
    methods (Access = public)
        
        function [vd] = Initialise(~, vd, ~)
            vd.tyres.rear.Rl = 0.5;
            
            vd.tyres.Pacejka.B = 1;
            vd.tyres.Pacejka.C = 1.9;
            vd.tyres.Pacejka.E = 0.6;
            vd.tyres.Pacejka.Fz1 = 0;%1/7000;
            vd.tyres.Pacejka.Fx1 = 0;%1/10000;
            vd.tyres.Pacejka.Fx2 = 0;%1/5000000;
        end
        
        function [Fy] = Run(~, ~, u, vd)                         
            T   = u(1,:);
            a   = u(2,:);
%             
%             B = vd.tyres.Pacejka.B;
%             C = vd.tyres.Pacejka.C;
%             E = vd.tyres.Pacejka.E;
%             
%             mu_a = sin(C*atan(B*a - E*B*a + E*atan(B*a)));
            mu_a = a./pi;    % Tyre grip is linear with steering angle
            
            Fx  = T/vd.tyres.rear.Rl;
            Fz 	= vd.chassis.m*9.81;
            D  	= 1 - Fz*vd.tyres.Pacejka.Fz1 - Fx*vd.tyres.Pacejka.Fx1 - (Fx.^2)*vd.tyres.Pacejka.Fx2;
            
            Fy 	= Fz*D.*mu_a;
        end
        
    end
end