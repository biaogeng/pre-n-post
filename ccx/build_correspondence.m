function [map12, map21] = build_correspondence(x1,x2,tol)


% build the correspondence between two point cloud x1, x2


    if ~exist('tol','var')
        tol = 1e-6;
    end

    npt1 = size(x1,1);
    npt2 = size(x2,1);
    
    swap=false;
    ix = [1 2];
    
    if npt1>npt2  % loop through smaller set to save time
        swap = true;
        tmp = x1;
        x1 = x2;
        x2 = tmp;
        npt1 = size(x1,1);
        npt2 = size(x2,1);
        
        ix = [2 1];
    end
    
    map12 = NaN(npt1,1);
    map21 = NaN(npt2,1);
    
    for i=1:npt1
        dx = x1(i,:) - x2;
        
        ds = sqrt(dx(:,1).^2 + dx(:,2).^2 + dx(:,3).^2);
        [dmin,jmin] = min(ds);
        if dmin<tol
            map12(i) = jmin;
            map21(jmin) = i;
        else
            fprintf('no correspondence found for point %d in point set %d\n',i,ix(1));
            fprintf('cloest point is %d, %g,%g,%g, distance %g\n',jmin,x2(jmin,:),dmin);
        end
    end 
    
    
    if swap
        tmp = map12;
        map12 = map21;
        map21 = tmp;
    end
    
    

    
    
    