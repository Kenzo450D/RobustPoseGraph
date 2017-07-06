function [autVertices] = alignVertices(autVertices, gtVertices)

%% Initialization
% -- Get init pose of ground Truth
gt.x = gtVertices(1).x;
gt.y = gtVertices(1).y;
gt.th = wrapToPi(gtVertices(1).o);
gtT = convert2TransformationMatrix_SO2(gt);

% -- Get init pose of AUT
aut.x = autVertices(1).x;
aut.y = autVertices(1).y;
aut.th = wrapToPi(autVertices(1).o);
autT = convert2TransformationMatrix_SO2(aut);

%% make relative transformation
rt = inv(autT);

i = 1;
while i<=size(autVertices,2)
    av.x = autVertices(i).x;
    av.y = autVertices(i).y;
    av.th = autVertices(i).o;
    avT = convert2TransformationMatrix_SO2(av);
    nPavT = rt * avT;
    nPav = convertFromTransformationMatrix(nPavT);
    autVertices(i).x = nPav.x;
    autVertices(i).y = nPav.y;
    autVertices(i).z = nPav.th;
%     fprintf(1,'i = %d\n',i);
    % -- iterate
    i = i + 1;
end

end

function [T]=convert2TransformationMatrix_SO2(val)

    x=val.x;
    y=val.y;
    th=val.th;

    T=[cos(th) -sin(th) x;
        sin(th) cos(th) y;
        0 0 1];
end

function [v]=convertFromTransformationMatrix(T)

    v.x=T(1,3);
    v.y=T(2,3);
    v.th=(atan2(T(2,1),T(1,1)));  %   T(2,1)=sin(th), T(1,1)=cos(th). So, on the whole,

end