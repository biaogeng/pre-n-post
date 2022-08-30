function fem = update_element_sets(fem,eset)

% update set definitions in fem with the eset
    update = 1;  % update an old set
    add    = 2;  % add as new set
    operation = add;
    
    nset = length(fem.ele);
    for i =1:nset
        if strcmp(fem.ele(i).name,eset.name)
            fprintf('update_element_sets: updating set %s\n',fem.ele(i).name);
            operation = update;
            iset = i;
            break;
        end
    end
            
    
    if operation == add
        iset = nset+1;
        fprintf('update_element_sets: adding set %s\n',eset.name);
    end
    
    fem.ele(iset).name = eset.name;
    fem.ele(iset).type = 'C3D4';
    fem.ele(iset).conn = fem.conn(eset.list,:);
    fem.ele(iset).set = eset.list;
