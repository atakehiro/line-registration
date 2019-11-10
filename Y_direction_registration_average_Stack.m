% ���ω摜�Ƀ��C�����W�X�g���s���āA�S�摜�𓯂������ړ�������
num = 10; %�������̂��߂̕��ω��t�B���^�[�͈̔́A0�̎��͕������ɂ�錸�Z�Ȃ�
range_x = 15; %���炷�ő�l�i�{,�[�j
corr_thr = 0.80; %�Y�����̗p���鑊�֌W���̍ŏ��l(臒l)
%% tif�t�@�C���̓ǂݎ��
tic
[file, file_path] = uigetfile('*.tif');
file_info = imfinfo([file_path, file]);
d1 = file_info(1).Height;
d2 = file_info(1).Width;
T = numel(file_info);
bit = file_info(1).BitDepth;
   
raw_IMG = zeros(d1,d2,T);
for t = 1:T
    raw_IMG(:,:,t) = imread([file_path, file], t);
end
disp('�f�[�^�ǂݎ�芮��')
toc
%% ���W�X�g
raw_mean_IMG = mean(raw_IMG,3);
Y_dif = zeros(4,d1-1);
IMG = zeros(d1,d2,T);
tic
for j = 2:d1
    [r,lgs] = xcorr(raw_mean_IMG(j-1,:),raw_mean_IMG(j,:),range_x,'coeff');
    [Y_dif(1,j-1),idx] = max(r);
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
disp('�ω��ʌv�Z������');

for i = 2:d1
    J = Y_dif(4,i-1);
    source = raw_IMG(i,:,:);
    if J < 0
        IMG(i,:,:) = [source(1,(abs(J)+1):d2,:),zeros(1,abs(J),T)];
    else
        IMG(i,:,:) = [zeros(1,J,T),source(1,1:(d2 - J),:)];
    end
end
disp('���W�X�g����')
toc
%% �}��
mean_IMG = mean(IMG,3);
figure
subplot(1,2,1)
imshow(raw_mean_IMG,[]);
title("���̕��ω摜")
subplot(1,2,2)
imshow(mean_IMG,[]);
title("���W�X�g��̕��ω摜")
figure
imshowpair(raw_mean_IMG,mean_IMG);
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
imwrite(IMG(:,:,1),[file_path, 'YAVGreged_', file,'.tif']);
for t = 2:T
    imwrite(IMG(:,:,t),[file_path, 'YAVGreged_', file,'.tif'],'WriteMode','append');
end
disp('�������݊���')
toc

%% �A�j���[�V�����\��
% figure
% tic
% for t = 1:T
%     imshow(IMG(:,:,t),[])
%     pause(0.01)
% end
% toc