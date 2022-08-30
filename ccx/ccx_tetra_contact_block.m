function blk = ccx_tetra_contact_block(dimension,corner)
% created by bgeng on 2019-08-26
% generates an block for contact setup in Calculix
% dimension:1*3 vector, [DX,DY,DZ]
% corner:   1*3 vector, [X1,Y1,Z1]
% blk: struct contain all info about the contact block

DX = dimension(1);
DY = dimension(2);
DZ = dimension(3);


Delta = [ 0   0   0;
         DX   0   0;
         DX  DY   0;
          0  DY   0;
          0   0  DZ;
         DX   0  DZ;
         DX  DY  DZ;
          0  DY  DZ];

blk.X = corner + Delta;
blk.tetra = [2 5 4 1;
             2 7 5 6;
             4 5 7 8;
             2 4 7 3;
             2 7 4 5];
             
      
      
      
      