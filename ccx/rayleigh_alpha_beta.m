function [alpha, beta] = rayleigh_alpha_beta(xi,fn)
% 

    wn = fn*2*pi;
    alpha = xi*wn;
    beta  = xi/wn;
    
    fprintf('alpha=%f,beta=%e\n',alpha,beta);
    fprintf(',,%f,%e\n',alpha,beta);