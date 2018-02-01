function out = imagetranslate(Image,cx,cy);

[l b] = size(Image);
nw = zeros([l b]);
if cx >= 0 && cy >= 0
    for i = 1: l-cx
    for j  = 1: b-cy
         nw(i+cx,j+cy) = Image(i,j);
    end 
    end
 out = nw;
end

if cx <0 && cy <0
        for i = 1: l+cx
        for j  = 1: b+cy
            nw(i,j) = Image(i-cx,j-cy);
        end
        end
    out = nw; 
    
end

if cx < 0 && cy >= 0
        for i = 1: l+cx
        for j  = 1: b-cy
            nw(i,j+cy) = Image(i-cx,j);
        end
        end
        out = nw;
end


if cx >= 0 && cy <0
        for i = 1: l-cx
        for j  = 1: b+cy
            nw(i+cx,j) = Image(i,j-cy);
        end
        end
        out = nw;
end