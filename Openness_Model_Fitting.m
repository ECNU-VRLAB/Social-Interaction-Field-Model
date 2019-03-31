clc; clear;
parameter_a = [];
for iOpenness = 1:5
    x=[cos(Exp{iOpenness}.OrientationA(:)/180*pi)';cos(Exp{iOpenness}.OrientationB(:)/180*pi)';Exp{iOpenness}.Distance(:)'];
    y=Exp{iOpenness}.Probability(:)';
    func=inline('1-exp(-((((x(1,:)+0.087).*(x(2,:)+0.087))./(x(3,:).^2))*beta(1)).^0.748)','beta','x');
    beta=nlinfit(x,y,func,1);
    parameter_a = [parameter_a, beta(1)];
end

disp( 'a value' )
disp([  'Opennese_-2   :   ' num2str(parameter_a(1))     '       Opennese_-1   : ' num2str(parameter_a(2)) ...
    '      Opennese_0   : ' num2str(parameter_a(3)) '      Opennese_1   : ' num2str(parameter_a(4)) ...
    '      Opennese_2   : ' num2str(parameter_a(5)) ]);

x=[-2 -1 0 1 2];

y=sqrt(parameter_a);

p = polyfit(x,y,1);


lambda = (1/p(2))^2;
disp('Function: ')
disp([ 'I = ' num2str(p(1)/2.41) '*openness + 1'])
disp([ 'lambda = ' num2str((1/p(2))^2)] );

