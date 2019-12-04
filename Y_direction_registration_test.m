num = 30; %平滑化のための平均化フィルターの範囲、0の時は平滑化による減算なし
range_x = 15; %ずらす最大値（＋,ー）
corr_thr = 0.80; %ズレを採用する相関係数の最小値(閾値)
%% tifファイルの読み取り
tic
[file, file_path] = uigetfile('*.tif');
file_info = imfinfo([file_path, file]);
d1 = file_info(1).Height;
d2 = file_info(1).Width;
bit = file_info(1).BitDepth;
raw_IMG = double(imread([file_path, file], 1));
disp('データ読み取り完了')
toc

%% レジスト
tic
Y_dif = zeros(4,d1-1);
IMG = raw_IMG;
for i = 2:d1
    [r,lgs] = xcorr(raw_IMG(i-1,:),raw_IMG(i,:),range_x,'coeff');
    [Y_dif(1,i-1),idx] = max(r);
    if Y_dif(1,i-1) > corr_thr
        Y_dif(2,i-1) = lgs(idx);
    else
        Y_dif(2,i-1) = 0;
    end
end
Y_dif(3,:) = cumsum(Y_dif(2,:));
if num > 0
    Smoothed = int8(movmean(squeeze(Y_dif(3,:)),num));
else
    Smoothed = int8(zeros(1,d1-1));
end
Y_dif(4,:) = int8(squeeze(Y_dif(3,:))) - Smoothed;
for i = 2:d1
    J = Y_dif(4,i-1);
    source = raw_IMG(i,:);
    if J < 0
        IMG(i,:) = [source((abs(J)+1):d2),zeros(1,abs(J))];
    else
        IMG(i,:) = [zeros(1,J),source(1:(d2 - J))];
    end
end
disp('レジスト完了')
toc

%% 図示
figure
subplot(1,2,1)
imshow(raw_IMG,[]);
title("元画像")
subplot(1,2,2)
imshow(IMG,[]);
title("レジスト後")
figure
imshowpair(raw_IMG,IMG);
title("重ね合わせ")

figure
subplot(2,2,1);
    plot(Y_dif(1,:))
    title("相関係数")
subplot(2,2,2);
    plot(Y_dif(2,:))
    title("前行に対するlag")
subplot(2,2,3)
    plot(Y_dif(3,:))
    hold on
    plot(Smoothed)
    legend('raw data','smoothed')
    title("累積のlag")
subplot(2,2,4)
    plot(Y_dif(4,:))
    title("適用したx移動量")
%% 書き込み
tic
IMG = cast(IMG,['uint',num2str(bit)]);
imwrite(IMG,[file_path, 'Yreged_', file]);
disp('書き込み完了')
toc
