function [dx,dy,amplitude] = rieszPhaseDifference(c,cx,cy,p,px,py)
% Quaternion product current*conj(previous), under constant local orientation.
% atan2 is equivalent to the official acos expression away from degeneracies.
r = c.*p + cx.*px + cy.*py;
x = p.*cx - c.*px;
y = p.*cy - c.*py;
v = hypot(x,y);
angle = atan2(v,r);
scale = zeros(size(v),'like',v);
valid = v > 0;
scale(valid) = angle(valid)./v(valid);
dx = x.*scale;
dy = y.*scale;
amplitude = sqrt(hypot(r,v));
end
