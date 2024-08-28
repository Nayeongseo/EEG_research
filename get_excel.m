saveDir = './data/'; % spect, stimes, sfreqs 저장할 공간

addpath('./mtspecgramc/'); % 함수 사용할 디렉토리

folderPath = fullfile(saveDir, '06');
csvFiles = dir(fullfile(folderPath, '*.csv')); % 이 경로 안의 csv 파일 불러오기

for i = 1:length(csvFiles)
    filePath = fullfile(folderPath, csvFiles(i).name);

    % CSV 파일을 테이블로 읽기 ('VariableNamingRule'을 'preserve'로 설정)
    dataTable = readtable(filePath, 'VariableNamingRule', 'preserve');

    % 열 이름 확인
    disp(['Column names in ', csvFiles(i).name, ':']);
    disp(dataTable.Properties.VariableNames);

    % 필요한 열만 선택 (시간 정보와 PSI 열)
    requiredColumns = {'Time (GMT)', 'PSI'}; % 열 이름에 공백이나 특수 문자가 있는 경우
    availableColumns = dataTable.Properties.VariableNames;

    % 선택한 열이 테이블에 있는지 확인하고 추출
    for col = requiredColumns
        if ismember(col{1}, availableColumns)
            disp(['Extracting ', col{1}, ' data from ', csvFiles(i).name, ':']);
            disp(dataTable.(col{1}));
        else
            disp([col{1}, ' column not found in ', csvFiles(i).name]);
        end
    end
end


time = dataTable.(requiredColumns{1});
psi = dataTable.(requiredColumns{2});

% PSI 값이 30에서 40 사이인 행 필터링
psiFilter = psi >= 30 & psi <= 37;
filteredTable = dataTable(psiFilter, :); % 조건에 맞는 행을 포함한 새로운 테이블

% 행 번호 추가
filteredTable.RowNumbers = find(psiFilter)+1;
% 연속된 행 번호의 시작점과 끝점 찾기
rowNumbers = filteredTable.RowNumbers;
diffRowNumbers = diff([0; rowNumbers; max(rowNumbers)+1]);
startPoints = rowNumbers(diffRowNumbers(1:end-1) > 1);
endPoints = rowNumbers(diffRowNumbers(2:end) > 1);

% endPoints의 마지막 값이 startPoints의 마지막 값보다 작으면 rowNumbers의 마지막 값을 추가
if endPoints(end) < startPoints(end)
    endPoints = [endPoints; rowNumbers(end)];
end

% 길이가 300 이상인 구간의 시작점 찾기
longSegments = find((endPoints - startPoints + 1) >= 150);
longStartPoints = startPoints(longSegments);
longEndPoints = endPoints(longSegments+1);

eeg = load([saveDir, 'spect_', '06']);
eeg.stimes(realStartTime)
eeg.stimes(realEndTime)
eeg.stimes(3285*20)

time(1) % 엑셀 파일의 시간
folderPath = fullfile(saveDir, '06');
edfFiles = dir(fullfile(folderPath, '*.edf')); % 이 경로 안의 csv 파일 불러오기
fileName = edfFiles(1).name;
splitName = strsplit(fileName, '_');
thirdPart = splitName{3};
thirdPart = strrep(thirdPart, '.edf', '');

if length(thirdPart) == 6
    hour = str2double(thirdPart(1:2));
    minute = str2double(thirdPart(3:4));
    second = str2double(thirdPart(5:6));
    thirdPartTime = duration(hour, minute, second); % edf 파일의 시간

    % 두 시간의 차이를 초 단위로 계산
    timeDifference = abs(thirdPartTime - time(1));
    timeDifferenceInSeconds = seconds(timeDifference);

    % 결과 출력
    disp(['Time difference in seconds: ', num2str(timeDifferenceInSeconds)]);
end


realStartTime = (longStartPoints*2+timeDifferenceInSeconds);
realEndTime = (longEndPoints*2+timeDifferenceInSeconds);

fig1 = figure('color','w','units','normalized','position', [0 0 .8 .95]);


numPlots = length(realStartTime); % subplot 개수
load([saveDir, 'spect_', '06', '.mat']);

for i = 1:numPlots
    % density_value보다 크거나 같은 첫 번째 stimes 값의 인덱스 찾기
    idxStart = find(stimes >= realStartTime(i), 1);
    idxEnd = find(stimes <= realEndTime(i), 1, 'last');
    
    % Subplot 생성
    subplot(numPlots+1, 2, i*2-1); % 2열로 정렬된 subplot
    colormap jet;
    
    % 이미지 생성
    imagesc(stimes(idxStart:idxEnd), sfreqs, pow2db(spect_normalize(idxStart:idxEnd, :, 4)'));
    set(gca,'clim',[-20 15]);
    axis xy;
    ylabel('Frequency (Hz)');
    title(sprintf('Plot %d', i));
    c = colorbar('location', 'eastoutside');
    ylabel(c, 'Power (dB)');
end
