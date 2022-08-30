% combine 2 fem models into 1
% fem2 is put after fem1
% bgeng 2020-01-30
function fem = combine_fe_models(fem1,fem2)


    noffset = size(fem1.x,1); 
    eoffset = size(fem1.conn,1); 
    
    fem.x = [fem1.x; fem2.x];
    % change indice of fem2
    fem2.conn = fem2.conn + noffset;
    
    fem.conn = [fem1.conn; fem2.conn];
    
    
    for i=1:length(fem2.ele)
        fem2.ele(i).set = fem2.ele(i).set + eoffset;
        fem2.ele(i).conn = fem2.ele(i).conn + noffset;
    end
    
    
    for i=1:length(fem2.surf)

    
    

