CoinImage = imread(“CoinImage.png”)
[CoinMask, maskedCoinImage] = segmentImage(CoinImage);

maskedCoinImage = im2uint8(edge(maskedCoinImage,"sobel",0.08));
se = strel("disk",10,0);

CoinMask = imerode(CoinMask,se);

faceEdgeMask = maskedCoinImage & CoinMask;
se = strel("disk",32,0);
faceEdgeMask = imdilate(faceEdgeMask,se);

validCoinMask = faceEdgeMask & CoinMask

[bw,coinSizes] = filtertheRegions(validCoinMask);
coinSizes = sortrows(coinSizes,"Area","ascend");

nDimes = nnz(coinSizes.Area<4500)
nNickels = nnz(coinSizes.Area>4500 & coinSizes.Area<7000)
nQuarters = nnz(coinSizes.Area>7000 & coinSizes.Area<10000)
nFiftyCents = nnz(coinSizes.Area>10000 & coinSizes.Area<20000)

USD = nDimes*0.1 + nNickels*0.05 + nQuarters*0.25+nFiftyCents*0.5


function [BW,maskedImage] = segmentImage(X)
% Find circles
[centers,radii,~] = imfindcircles(X,[25 75],'ObjectPolarity','bright','Sensitivity',0.85);

BW = false(size(X,1),size(X,2));
[Xgrid,Ygrid] = meshgrid(1:size(BW,2),1:size(BW,1));

for n = 1:10
BW = BW | (hypot(Xgrid-centers(n,1),Ygrid-centers(n,2)) <= radii(n));
end

% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;

end


function [BW_out,properties] = filtertheRegions(BW_in)
BW_out = BW_in;

properties = struct2table(regionprops(BW_out, {'Area'}));
end