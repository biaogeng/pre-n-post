

function xi = rayleigh_damping_ratio(alpha,beta,fn)

%     wn = 0.01:1:100;

    if ~exist('fn','var')
        fn = 100:200;
    end
    wn = fn*2*pi;
    xi = 1/2*(alpha./wn+beta.*wn);
    plot(fn,xi,'-o');
    
