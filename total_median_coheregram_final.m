saveDir = './data/'; % data 저장 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리
SaveFigdir = './figure1/'; % 사진 저장할 공간

% saveDir에 있는 폴더 이름 불러오기
folders = dir(saveDir);
folders = folders([folders.isdir]); % 디렉토리만 필터링
folders = folders(~ismember({folders.name}, {'.', '..'})); % '.'와 '..' 제거
subject_num = {folders.name}; % 폴더 이름을 셀 배열로 저장

[r, c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이
C_all = zeros(c, 60, 115);
load([saveDir, 'freq', '.mat']);
for i = 1:c
    subject_temp = subject_num{i};
    load([saveDir, 'coherence_', subject_temp, '.mat']);

    % 결과 저장
    C_all(i, :, :) = C_selected;
end

C_median = squeeze(median(C_all));

% .mat 파일로 저장
disp('Saving data...');
save([saveDir,'coherence_median'], "C_median", '-v7.3');

fig1 = figure('color', 'w', 'units', 'normalized', 'position', [0 0 .8 .95]);
colormap jet
imagesc(1:120, f, C_median'); % Use t_selected for time and f for frequency
set(gca, 'clim', [0 1]); % Coherence ranges from 0 to 1
axis xy;

xlabel('Time (s)');
ylabel('Frequency (Hz)');
c = colorbar('location','eastoutside');
ylabel(c,'Power (dB)');
title("total median coheregram");

% 사진 저장
set(fig1, 'PaperPositionMode', 'auto')
fname = [SaveFigdir, ['median coheregram']];
print('-dpng', fname);
