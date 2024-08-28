saveDir = './data/'; % data 저장 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리
SaveFigdir = './figure1/'; % 사진 저장할 공간

% saveDir에 있는 폴더 이름 불러오기
folders = dir(saveDir);
folders = folders([folders.isdir]); % 디렉토리만 필터링
folders = folders(~ismember({folders.name}, {'.', '..'})); % '.'와 '..' 제거
subject_num = {folders.name}; % 폴더 이름을 셀 배열로 저장

channel = char('EEGL1_Fp1','EEGR1_Fp2','EEGL2_F7','EEGR2_F8');

[r, c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이

% 각 마취 농도에 대해 데이터를 저장할 구조체 초기화
totalEEG = struct();

% 2분(120초)구간의 spect 뽑기
for i = 1:c
    subject_temp = subject_num{i};
    data = load([saveDir, 'spect_', subject_temp, '.mat']);
    idxStart = find(data.stimes >= 6000, 1); %10분 index
    idxEnd= find(data.stimes < 6120, 1, 'last'); %12분 index
    for j = 1:4
        varName = deblank(channel(j, :));
        if isfield(totalEEG, varName)
            totalEEG.(varName) = cat(1, totalEEG.(varName), reshape(data.spect(idxStart:idxEnd, :, j), 1, 1188, 230));
        else
            totalEEG.(varName)(1,:,:) = data.spect(idxStart:idxEnd, :, j);
        end
    end
end
% .mat 파일로 저장
disp('Saving data...');
save([saveDir,'median'], "totalEEG", '-v7.3');


% median 그림그리기
disp('Drawing Spectrogram...');
fig1 = figure('color','w','units','normalized','position', [0 0 .8 .95]);

for i = 1:4
    varName = deblank(channel(i, :));
    position = i*4-3
    subplot(4, 4, position)
    colormap jet
    imagesc(1:120, data.sfreqs, pow2db(squeeze(median(totalEEG.(varName)))'));
    set(gca, 'clim', [-25 10])
    axis xy;
    ylabel('Frequency (Hz)');
    c = colorbar('location','eastoutside');
    ylabel(c,'Power (dB)');
    title(['Median sevoflurane EEG spectrogram  ', varName])
    disp(size(median(totalEEG.(varName))));

end


    set(fig1, 'PaperPositionMode', 'auto')
    fname = [SaveFigdir, ['median spectrogram']];
    print('-dpng', fname);