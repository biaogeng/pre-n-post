function p = exp_overclosure_pressue(p0,c0)

    x = -c0:c0/100:c0/5;

    beta = log(100)/c0;
    p = p0*exp(beta*x);
    figure;
    plot(x,p);
    
    title(sprintf('p0=%g,c0=%g',p0,c0));