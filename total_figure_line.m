% 라인으로 그림을 그리는 방법으로 해보기**

saveDir = './data/'; % data 저장 공간
SaveFigdir = './figure/'; % 사진 저장할 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리

except_subject_num = {'13','15', '16'}; % PSI가 없는 폴더들
D_subject_num = {'10', '30', '58', '96', '102', '119', '157'}; % 섬망 환자들 list
channel = char('EEGL1_Fp1','EEGR1_Fp2','EEGL2_F7','EEGR2_F8');

% 섬망, 비섬망 구분 없이 PSI가 30~40인 곳 흰 선으로 표시하기.
% 이후 figure를 그릴 때 이름을 나눠서 표시하기 - 섬망, 비섬망

% saveDir에 있는 폴더 이름 불러오기
folders = dir(saveDir);
folders = folders([folders.isdir]); % 디렉토리만 필터링
folders = folders(~ismember({folders.name}, {'.', '..'})); % '.'와 '..' 제거
subject_num = {folders.name}; % 폴더 이름을 셀 배열로 저장

for i = 1:length(subject_num)
    number = subject_num{i};

    % except_subject_num에 포함된 subject는 넘어가기
    if ismember(number, except_subject_num)
        disp(['Skipping subject ', number]);
        continue;
    end

    dataFile = fullfile(saveDir, ['PSI_', number, '.mat']);
    load(dataFile)
    rowNumbers = (1:length(psi))'; % 행 번호
    
    % PSI 값이 30에서 40 사이인 행 필터링
    psiFilter = psi >= 30 & psi <= 40;
    filteredPsi  = psi(psiFilter); % 조건에 맞는 행을 포함한 새로운 테이블
    filteredRowNumbers = rowNumbers(psiFilter); % 필터링된 행 번호

    % 필터링된 데이터 테이블 생성
    filteredTable = table(filteredRowNumbers, filteredPsi, 'VariableNames', {'RowNumbers', 'PSI'});

    if ~length(filteredPsi)
        disp(["There is no PSI [30 40]"]);
        continue;
    end
    % 연속된 행 번호의 시작점과 끝점 찾기
    rowNumbers = filteredTable.RowNumbers;
    diffRowNumbers = diff([0; rowNumbers; max(rowNumbers) + 1]);
    startPoints = rowNumbers(diffRowNumbers(1:end-1) > 1);
    endPoints = rowNumbers(diffRowNumbers(2:end) > 1);

    % endPoints의 마지막 값이 startPoints의 마지막 값보다 작으면 rowNumbers의 마지막 값을 추가
    if isempty(endPoints) || endPoints(end) < startPoints(end)
        endPoints = [endPoints; rowNumbers(end)];
    end

    % 길이가 300 이상인 구간의 시작점 찾기
    longSegments = find((endPoints - startPoints + 1) >= 150);
    if isempty(longSegments) % 구간이 300이 넘는 곳이 없으면
        disp('there is no longSegments');
        realStartTime = 0; % 작은 구간으로 뽑기
        realEndTime = rowNumbers(end);

    else % 구간이 300이 넘는 곳이 있으면
        longStartPoints = startPoints(longSegments)+1;
        longEndPoints = endPoints(longSegments) + 1;
        realStartTime = (longStartPoints * 2 + timeDifferenceInSeconds);
        realEndTime = (longEndPoints * 2 + timeDifferenceInSeconds);
    end
    disp(['Draw lines', number,'...']);
    % 그래프 그리기
    fig1 = figure('color', 'w', 'units', 'normalized', 'position', [0 0 .8 .95]);

    numPlots = length(realStartTime); % 나타낼 PSI 갯수
    
    load([saveDir, 'spect_', number]);
    for j = 1:size(channel)
        % Subplot 생성
        subplot(4, 1, j); % 2열로 정렬된 subplot
        colormap jet;

        % 이미지 생성
        spect_normalize = double(spect);
        imagesc(stimes, sfreqs, pow2db(spect_normalize(:, :, j)'));
        set(gca, 'clim', [-20 15]);
        axis xy;
        ylabel('Frequency (Hz)');
        c = colorbar('location', 'eastoutside');
        ylabel(c, 'Power (dB)');

        hold on; % 새로운 요소를 같은 플롯에 추가

        for k = 1:numPlots
            % density_value보다 크거나 같은 첫 번째 stimes 값의 인덱스 찾기
            idxStart = realStartTime(k);
            idxEnd = realEndTime(k);
    
            plot([idxStart, idxEnd], [30, 30], 'w-', 'LineWidth', 1); % 수평선 -
            plot([idxStart, idxStart], [0, 30], 'w-', 'LineWidth', 1); % 수직선1
            plot([idxEnd, idxEnd], [0, 30], 'w-', 'LineWidth', 1); % 수직선2

        end

        hold off;

        title(channel(j, :));
    end
    
    if ismember(number, D_subject_num)

        suptitle([number, ' D']);
        set(fig1, 'PaperPositionMode', 'auto')
        fname = [SaveFigdir, ['D sevo', number,' line spectrogram']];
        print('-dpng', fname);
    else
        suptitle([number, ' ND']);
        set(fig1, 'PaperPositionMode', 'auto')
        fname = [SaveFigdir, ['ND sevo', number,' line spectrogram']];
        print('-dpng', fname);
    end

end
