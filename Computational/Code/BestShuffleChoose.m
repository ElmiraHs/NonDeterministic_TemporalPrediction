filename = 'sd25_11_noSkew.mat'; %example
load(filename);

%% choose best shuffle
n = 1;
x = 10;
y = 10;

while n <= 50

    
%     [valmeanAng, IdxmeanAng] = maxk(PredictionDiffmeanAngle),x);%find the n max element
    [valpredDiff, IdxpredDiff] = mink(abs(400-PredictionDiffmeanAngle),x);%find the n max element
    
    [valPC, IdxPC] = maxk(mean(allPC,1), y);
    

    maxShuffles = intersect(IdxPC, IdxpredDiff);
    n = length(intersect(IdxPC, IdxpredDiff));

    x =  x + 1;
    y = y + 5;

end

%  chose manually one of the intersect idx
figure;
plot(mean(allPC(:,maxShuffles), 1) , PredictionDiffmeanAngle(maxShuffles), 'o', LineWidth= 1)
xlabel('ITPC increase', 'FontWeight','bold', 'LineWidth', 2)
ylabel('Prediction Difference (ms)' , 'FontWeight','bold', 'LineWidth', 2)
title('Scatter plot for best shuffles of the stream', 'FontWeight','bold', FontSize=13)
set(gca,'FontWeight','bold')
x = mean(allPC(:,maxShuffles), 1);
y = PredictionDiffmeanAngle(maxShuffles);

g = ginput(2);                 
D = pdist2([x', y'],g);
[~,ix] = min(D);               
hold on
plot(x(ix),y(ix),'or', LineWidth= 1)

hold off


allchosen_shuffles_idx = maxShuffles(ix,1)
