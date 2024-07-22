saveDir = './data/'; % annotation 저장할 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리

subject_num = char('01','02','03','04','05','06'); % 파일 이름. 주로 데이터 확정시 사용.
[r,c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이
i = 5
for i = 1:r
    subject_temp = deblank(subject_num(i,:));
    
    % 경로 불러오기
    folderPath = fullfile(saveDir, subject_temp);
    edfFile = dir(fullfile(folderPath, '*.tsv')); % 이 경로 안의 tsv 파일 불러오기
    filePath = fullfile(folderPath, edfFile.name);
    time_data = readtable(filePath, 'FileType','text','Delimiter','\t', 'VariableNamingRule', 'preserve');
    
    % 밀도 시작 끝 정의(변수명)
    startDensity = 1.4;
    endDensity = 2.4;
    increment = 0.2;
    
    disp('start for')
    % 반복문으로 변수 동적 생성 및 값 할당
    densityValues = struct();
    for j = 0:5
        densityValue = startDensity + j * increment;
        annotationPattern = sprintf('%.1f%%start', densityValue); % 예: 1.4%start

        % Annotation 열에서 특정 패턴을 포함하는 행 선택
        matchingRows = contains(time_data.Annotation, annotationPattern);
        selectedRow = time_data(matchingRows, :);
        
        variableName = sprintf('density_%02d', round(densityValue * 10));

        % Time From Start 값 가져오기
        if ~isempty(selectedRow)
            timeFromStartValue = selectedRow.('Time From Start');
            if timeFromStartValue(1) > 3000
                densityValues.(variableName) = 0;
            else
                densityValues.(variableName) = timeFromStartValue(1);
            end
        end
    end

    startDensity = 2.2;
    endDensity = 1.4;
    increment = -0.2;
    j = 0
    for j = 0:4
        densityValue = startDensity + j * increment;
        annotationPattern = sprintf('%.1f%%start', densityValue); % 예: 1.4%start

        % Annotation 열에서 특정 패턴을 포함하는 행 선택
        matchingRows = contains(time_data.Annotation, annotationPattern);
        selectedRow = time_data(matchingRows, :);
        
        variableName = sprintf('density_%02d_2', round(densityValue * 10));

        % Time From Start 값 가져오기
        if ~isempty(selectedRow)
            timeFromStartValue = selectedRow.('Time From Start');
            [a, b] = size(timeFromStartValue)
            if a == 1
                densityValues.(variableName) = timeFromStartValue(1);
            elseif a == 3
                densityValues.(variableName) = timeFromStartValue(3);
            else
                densityValues.(variableName) = timeFromStartValue(2);
            end
        end
    end

    disp(size(timeFromStartValue))
    % 해당 subject의 mat 파일로 저장
    save(fullfile(saveDir, ['annotation_', subject_temp, '.mat']), '-struct', 'densityValues', '-v7.3');
end
