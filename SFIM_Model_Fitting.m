clc; clear; 

x=[cos(OrientationA(:)/180*pi)';cos(OrientationB(:)/180*pi)';Distance(:)']; 

y=Probability(:)';

func=inline('1-exp(-((((x(1,:)+beta(3)).*(x(2,:)+beta(3)))./(x(3,:).^2))*beta(1)).^beta(2))','beta','x'); 

beta=nlinfit(x,y,func,[1 1 1]); 

disp(['  a: ' num2str(beta(1)) '     b: ' num2str(beta(2)) '     c: ' num2str(beta(3)) ]); 

