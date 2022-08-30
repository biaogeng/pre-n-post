function fem=inp2plt(subdir,inp)

% generate plt files from ccx input for visualization
% subdir - input file location
% inp    - input file name

% assemble finite element model
fem = inp2fem(subdir,inp);


% write to plt
fem2plt(subdir,fem);