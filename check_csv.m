saveDir = './data/'; % spect, stimes, sfreqs 저장할 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리
SaveFigdir = './figure/'; % 사진 저장할 공간


% saveDir에 있는 폴더 이름 불러오기
folders = dir(saveDir);
folders = folders([folders.isdir]); % 디렉토리만 필터링
folders = folders(~ismember({folders.name}, {'.', '..'})); % '.'와 '..' 제거
subject_num = {folders.name}; % 폴더 이름을 셀 배열로 저장
i = 4
for i = 1:length(subject_num)
    number = subject_num{i};
    folderPath = fullfile(saveDir, number);
    csvFiles = dir(fullfile(folderPath, '*.csv')); % 이 경로 안의 csv 파일 불러오기
    xlsFiles = dir(fullfile(folderPath, '*.xls*')); % 이 경로 안의 Excel 파일 불러오기

    % 파일이 없는 경우 continue
    if isempty(csvFiles) && isempty(xlsFiles)
        disp(['No CSV or Excel files found for subject ', number]);
        continue;
    end
    try
        % 파일이 있는 경우 불러오기
        if ~isempty(xlsFiles)
            filePath = fullfile(folderPath, xlsFiles(1).name); % 여러 파일이 있을 경우 첫 번째 파일 사용
            dataTable = readtable(filePath, 'VariableNamingRule', 'preserve'); % Excel 파일을 테이블로 읽기
        elseif ~isempty(csvFiles)
            filePath = fullfile(folderPath, csvFiles(1).name); % 여러 파일이 있을 경우 첫 번째 파일 사용
            dataTable = readtable(filePath, 'VariableNamingRule', 'preserve');; % CSV 파일을 테이블로 읽기
        end

        % 필요한 열만 선택 (시간 정보와 PSI 열)
        requiredColumns = {'Time (GMT)', 'PSI'}; % 열 이름에 공백이나 특수 문자가 있는 경우
        availableColumns = dataTable.Properties.VariableNames;

        % 선택한 열이 테이블에 있는지 확인하고 추출
        for col = requiredColumns
            if ismember(col{1}, availableColumns)
                disp(['Extracting ', col{1}, ' data from ', filePath, ':']);
                %disp(dataTable.(col{1}));
                time = dataTable.(requiredColumns{1});
                psi = dataTable.(requiredColumns{2});

                % PSI가 cell형이면 double형으로 변환
                if iscell(psi)
                    psi = cellfun(@str2double, psi);
                end

                if isnan(time(1))
                    time = time(2:end);
                end
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
                end

            else
                disp([col{1}, ' column not found in ', number]);
            end

        end
        % 결과 출력
        disp(['Time difference in seconds: ', num2str(timeDifferenceInSeconds)]);
        save([saveDir, 'PSI_', number], 'time', 'psi', 'timeDifferenceInSeconds', '-v7.3')



    catch ME
        % 파일이 손상되었거나 다른 오류 발생 시 메시지 출력하고 다음으로 넘어감
        disp(['Error processing subject ', number, ': ', ME.message]);
        continue;
    end
end
