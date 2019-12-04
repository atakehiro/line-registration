% チャンネル1の変化量に合わせて変化させる
% C1,C2を別々に保存
num = 30; %平滑化のための平均化フィルターの範囲、0の時は平滑化による減算なし
range_x = 15; %ずらす最大値（＋,ー）
corr_thr = 0.80; %ズレを採用する相関係数の最小値(閾値)
%% tifファイルの読み取り
[file, file_path] = uigetfile('*.tif');
file_info = imfinfo([file_path, file]);
d1 = file_info(1).Height;
d2 = file_info(1).Width;
T = numel(file_info);
bit = file_info(1).BitDepth;

result_dif = zeros(4,d1-1,T/2);
figure
for t = 1:T/2
    C1_raw_IMG = imread([file_path, file], 2*t-1);
    C2_raw_IMG = imread([file_path, file], 2*t);
    Y_dif = zeros(4,d1-1);
    C1_IMG = C1_raw_IMG;
    C2_IMG = C2_raw_IMG;
    for i = 2:d1
        [r,lgs] = xcorr(C1_raw_IMG(i-1,:),C1_raw_IMG(i,:),range_x,'coeff');
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
        C1_source = C1_raw_IMG(i,:);
        C2_source = C2_raw_IMG(i,:);
        if J < 0
            C1_IMG(i,:) = [C1_source((abs(J)+1):d2),zeros(1,abs(J))];
            C2_IMG(i,:) = [C2_source((abs(J)+1):d2),zeros(1,abs(J))];
        else
            C1_IMG(i,:) = [zeros(1,J),C1_source(1:(d2 - J))];
            C2_IMG(i,:) = [zeros(1,J),C2_source(1:(d2 - J))];
        end
    end
    disp(['現在 ',num2str(t),'スライス目を完了']);
    result_dif(:,:,t) =  Y_dif;
    imshowpair(C1_IMG, C2_IMG)
    if t == 1
        imwrite(C1_IMG,[file_path, 'Yreged_C1_', file]);
        imwrite(C2_IMG,[file_path, 'Yreged_C2_', file]);
    else
        imwrite(C1_IMG,[file_path, 'Yreged_C1_', file],'WriteMode','append');
        imwrite(C2_IMG,[file_path, 'Yreged_C2_', file],'WriteMode','append');
    end
end 
%% 移動量の図示
a = squeeze(result_dif(2,:,:));
figure
imagesc(a)
colorbar
title("前行に対するlag")
b = squeeze(result_dif(4,:,:));
figure
imagesc(b)
colorbar
title("適用したx移動量")
