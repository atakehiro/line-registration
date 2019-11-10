num = 30; %�������̂��߂̕��ω��t�B���^�[�͈̔́A0�̎��͕������ɂ�錸�Z�Ȃ�
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
IMG = zeros(d1,d2,T);
Y_dif = zeros(4,d1-1,T);
tic
for i = 1:T
    tmp_IMG = raw_IMG(:,:,i);
    for j = 2:d1
        [r,lgs] = xcorr(raw_IMG(j-1,:,i),raw_IMG(j,:,i),range_x,'coeff');
        [Y_dif(1,j-1,i),idx] = max(r);
        if Y_dif(1,j-1,i) > corr_thr
            Y_dif(2,j-1,i) = lgs(idx);
        else
            Y_dif(2,j-1,i) = 0;
        end
    end
    Y_dif(3,:,i) = cumsum(Y_dif(2,:,i));
    if num > 0
        Smoothed = int8(movmean(squeeze(Y_dif(3,:,i)),num));
    else
        Smoothed = int8(zeros(1,d1-1));
    end
    Y_dif(4,:,i) = int8(squeeze(Y_dif(3,:,i))) - Smoothed;
    for j = 2:d1
        source = raw_IMG(j,:,i);
        J  =  Y_dif(4,j-1,i);
        if J < 0
            tmp_IMG(j,:) = [source((abs(J)+1):d2),zeros(1,abs(J))];
        else
            tmp_IMG(j,:) = [zeros(1,J),source(1:(d2 - J))];
        end
    end
    IMG(:,:,i) = tmp_IMG;
    disp(['���� ',num2str(i),'�X���C�X�ڂ�����']);
end
disp('���W�X�g����')
toc
%% �ړ��ʂ̐}��
a = squeeze(Y_dif(2,:,:));
figure
imagesc(a)
colorbar
title("�O�s�ɑ΂���lag")
b = squeeze(Y_dif(4,:,:));
figure
imagesc(b)
colorbar
title("�K�p����x�ړ���")
%% ��������
tic
IMG = cast(IMG,['uint',num2str(bit)]);
imwrite(IMG(:,:,1),[file_path, 'Yreged_', file,'.tif']);
for t = 2:T
    imwrite(IMG(:,:,t),[file_path, 'Yreged_', file,'.tif'],'WriteMode','append');
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