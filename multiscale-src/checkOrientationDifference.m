function [ endFlag ] = checkOrientationDifference(v1start, v1end, vertices)
%CHECKORIENTATIONDIFFERENCE Checks orientation difference between any two
%vertices and reports a 0 if it exceeds pi and 1 if it doesn't exceed pi.

if (v1end - v1start <= 1)
    endFlag = 1;
    return;
end

% % -- use VertexOdom
% for i = v1start:(v1end-1)
%     v1  = vertexOdom(i);
%     for j = i:v1end
%         v2 = vertexOdom(j);
%         oDiff = v1- v2;
%         if (oDiff > pi)
%             endFlag = 0;
%             return;
%         end
%     end
% end
% endFlag = 1;
% end

% -- use a storage to store values in a matrix
items = v1end - v1start + 1;
ornts = zeros(1,items);
idx = 1;
for i = v1start:v1end
    ornts(idx) = vertices(i).o;
    idx = idx + 1;
end

for i = 1:(items-1)
    for j= i+1:items
        diffO = ornts(i) - ornts(j);
        if (diffO > pi)
            endFlag = 0;
            return;
        end
    end
end

endFlag = 1;
end

% iter = v1end - v1start + 1;
% combn = combnk(1:iter,2);
% combn = combn + (v1start-1);
% for i = 1:length(combn)
%     v1 = vertices(combn(i,1));
%     v2 = vertices(combn(i,2));
%     oDiff = v1.o - v2.o;
%     if (oDiff > pi)
%         endFlag = 0;
%         return;
%     end
% end
% endFlag = 1;
% end

% for i = v1start:(v1end-1)
%     v1  = vertices(i);
%     for j = i:v1end
%         v2 = vertices(j);
%         oDiff = v1.o - v2.o;
%         if (oDiff > pi)
%             endFlag = 0;
%             return;
%         end
%     end
% end
% endFlag = 1;
% end
% 
