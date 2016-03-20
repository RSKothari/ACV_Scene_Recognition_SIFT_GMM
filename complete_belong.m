function [ trip ] = complete_belong( temp,mask,cuttoff,radius )
[b a]=size(mask);
trip=zeros(1,length(temp));
for i=1:length(temp)
%     radius=temp(3,i);
    
    a1=floor(temp(2,i)-radius);
    if a1<=0
        a1=1;
    end
    a2=floor(temp(2,i)+radius);
    if a2>a
        a2=a;
    end
    b1=floor(temp(1,i)-radius);
    if b1<=0
        b1=1;
    end
    b2=floor(temp(1,i)+radius);
    if b2>b
        b2=b;
    end
    frame=mask(a1:a2,b1:b2);
    t=ones(size(frame));
    in_size=sum(frame(:))/sum(t(:));
    if in_size>=cuttoff
        trip(i)=1;
    else
        trip(i)=0;
    end
end
trip=logical(trip);
end

