function [ x,y ] = form_grid( A,B,n )
A=(floor(A/n)-1)*n;
B=(floor(B/n)-1)*n;
temp1=n:n:A;
temp2=n:n:B;
[x,y]=meshgrid(temp1,temp2);
end

