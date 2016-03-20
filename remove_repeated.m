function [  matches ] = remove_repeated( matches)

t1=tabulate(matches(1,:));
a1=t1((t1(:,2)==1),1);
[~,loc]=ismember(a1',matches(1,:));
matches1=matches(:,loc);

t2=tabulate(matches(2,:));
a2=t2((t2(:,2)==1),1);

if length(a2)<length(matches1)
    [~,loc]=ismember(a2',matches1(2,:));
else
    [~,loc]=ismember(matches1(2,:),a2');
end

matches=matches1(:,loc);

% if ~(any(t1(:,2)>1) && any(t2(:,2)>1))
%     disp('No multi-matching SIFT vectors')
% else
%     disp('There are multiple matching')
% end
% save('test.mat')