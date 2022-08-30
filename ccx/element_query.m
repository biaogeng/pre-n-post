function element_query(elist,vf)
% check element by index


% rootdir =getenv('researchfolder');
% workdir = [rootdir '/bct_talker'];
% subdir = [workdir '/VF_models/ruby_casefiles/'];
% mshdir = [subdir '/quality_check'];

% 
% q0 = load([mshdir '/quality_00.txt']);
% q1 = load([mshdir '/quality_neu_0905.txt']);
fname = 'bad_elements.plt';
fid = fopen(fname, 'w');
fprintf(fid, 'variables=x,y,z\n');

for j=1:length(elist)
iel = elist(j);
for i=1:length(vf.ele)
   if ismember(iel,vf.ele(i).set)
      fprintf('found element %d in %s\n',iel,vf.ele(i).name);
%       fprintf('    q0, ar:%g,ess:%g\n',q0(iel,:));
%       fprintf('    q1, ar:%g,ess:%g\n',q1(iel,:));
   end
    
  
end

    % pick problematic elements
    fprintf(fid,'zone t = t%d\n',iel);
    fprintf(fid,'zonetype=fetetrahedron\n');
    fprintf(fid,'datapacking=point\n');
    fprintf(fid,'N=4,E=1\n');
    ipt = vf.conn(iel,:)';
    fprintf(fid,'%f %f %f\n',vf.x(ipt,:)');
    fprintf(fid,'1 2 3 4\n');

end

fclose(fid);