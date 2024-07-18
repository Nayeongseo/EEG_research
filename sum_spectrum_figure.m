SaveFigdir = './figure/'; % 사진 저장할 공간
saveDir = './data/'; % 저장된 데이터 불러올 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리
currentFolder = pwd;

subject_num = char('01','02','03','04','05','06'); % 파일 이름. 주로 데이터 확정시 사용.
density_num = char('14', '16', '18', '20', '22', '24'); % 마취 농도
[r,c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이
[rr, cc] = size(density_num);

for i = 1:r
    subject_temp = deblank(subject_num(i,:));

   
    load([saveDir,'spect_',subject_temp,'.mat']);
    AnnotationData = load([saveDir, 'annotation_', subject_temp, '.mat']);

    %농도별 시간 따와서 각 그림 4,4,[1-4], 4,4,5~~~~~ 그림 그리기
    fig1 = figure('color','w','units','normalized','position', [0 0 .8 .95]);
    spect_normalize = double(spect);

    suptitle(subject_temp);

    subplot(3, 3, [1 3]);
    colormap jet
    imagesc(stimes, sfreqs, pow2db(spect_normalize(:,:)'));
    set(gca,'clim',[-10 30])
    axis xy;
    ylabel('Frequency (Hz)');
    c = colorbar('location','eastoutside');
    ylabel(c,'Power (dB)');
    

    % subplot 그리기
    for j = 1:rr
        density_temp = deblank(density_num(j, :))
        varName = ['density_', density_temp]
        density_value = AnnotationData.(varName);

        % density_value보다 크거나 같은 첫 번째 stimes 값의 인덱스 찾기
        idxStart = find(stimes >= density_value, 1);
        idxEnd = find(stimes <= density_value+300, 1, 'last');

        disp(idxStart)
        disp(idxEnd)

        subplot(3, 3, j+3);
        colormap jet
        imagesc(stimes(idxStart:idxEnd), sfreqs, pow2db(spect_normalize(idxStart:idxEnd,:)'));
        set(gca,'clim',[-10 30])
        axis xy;
        ylabel('Frequency (Hz)');
        c = colorbar('location','eastoutside');
        ylabel(c,'Power (dB)');
    
    end

    set(fig1, 'PaperPositionMode','auto')
    fname = [SaveFigdir, [subject_temp, 'mouse spectrogram']];
    print('-dpng',fname);

end
