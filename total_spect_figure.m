saveDir = './data/'; % spect, stimes, sfreqs 저장할 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리
SaveFigdir = './figure/'; % 사진 저장할 공간

% saveDir에 있는 폴더 이름 불러오기
folders = dir(saveDir);
folders = folders([folders.isdir]); % 디렉토리만 필터링
folders = folders(~ismember({folders.name}, {'.', '..'})); % '.'와 '..' 제거
subject_num = {folders.name}; % 폴더 이름을 셀 배열로 저장

channel = char('EEGL1_Fp1','EEGR1_Fp2','EEGL2_F7','EEGR2_F8');

for i = 1:length(subject_num)
    load([saveDir,'spect_',subject_num{i}]);

    disp('Drawing Spectrogram...');
    fig1 = figure('color','w','units','normalized','position', [0 0 .8 .95]);

    for j = 1:4
        % 그래프 그리기
        subplot(4, 1, j)
        spect_normalize = double(spect);
        colormap jet
        imagesc(stimes, sfreqs, pow2db(spect_normalize(:,:,j)'));
        set(gca,'clim',[-20 15])
        axis xy;
        ylabel('Frequency (Hz)');
        c = colorbar('location','eastoutside');
        ylabel(c,'Power (dB)');
        titlee = channel(j, :);
        title(titlee)

    end
    suptitle(subject_num{i});


    set(fig1, 'PaperPositionMode','auto')
    fname = [SaveFigdir, [subject_num{i}, 'sevo spectrogram']];
    print('-dpng',fname);
end