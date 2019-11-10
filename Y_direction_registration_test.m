num = 30; %�������̂��߂̕��ω��t�B���^�[�͈̔́A0�̎��͕������ɂ�錸�Z�Ȃ�
range_x = 15; %���炷�ő�l�i�{,�[�j
corr_thr = 0.80; %�Y�����̗p���鑊�֌W���̍ŏ��l(臒l)
%% tif�t�@�C���̓ǂݎ��
tic
[file, file_path] = uigetfile('*.tif');
file_info = imfinfo([file_path, file]);
d1 = file_info(1).Height;
d2 = file_info(1).Width;
bit = file_info(1).BitDepth;
raw_IMG = double(imread([file_path, file], 1));
disp('�f�[�^�ǂݎ�芮��')
toc

%% ���W�X�g
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
disp('���W�X�g����')
toc

%% �}��
figure
subplot(1,2,1)
imshow(raw_IMG,[]);
title("���摜")
subplot(1,2,2)
imshow(IMG,[]);
title("���W�X�g��")
figure
imshowpair(raw_IMG,IMG);
title("�d�ˍ��킹")

figure
subplot(2,2,1);
    plot(Y_dif(1,:))
    title("���֌W��")
subplot(2,2,2);
    plot(Y_dif(2,:))
    title("�O�s�ɑ΂���lag")
subplot(2,2,3)
    plot(Y_dif(3,:))
    hold on
    plot(Smoothed)
    legend('raw data','smoothed')
    title("�ݐς�lag")
subplot(2,2,4)
    plot(Y_dif(4,:))
    title("�K�p����x�ړ���")
%% ��������
tic
IMG = cast(IMG,['uint',num2str(bit)]);
imwrite(IMG,[file_path, 'Yreged_', file,'.tif']);
disp('�������݊���')
toc