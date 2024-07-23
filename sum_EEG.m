saveDir = './data/'; % EDF 저장할 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리

% saveDir에 있는 폴더 이름 불러오기
folders = dir(saveDir);
folders = folders([folders.isdir]); % 디렉토리만 필터링
folders = folders(~ismember({folders.name}, {'.', '..'})); % '.'와 '..' 제거
subject_num = {folders.name}; % 폴더 이름을 셀 배열로 저장

for i = 1:length(subject_num)
    subject_temp = subject_num{i}

    folderPath = fullfile(saveDir, subject_temp);
    edfFiles = dir(fullfile(folderPath, '*.edf')); % 이 경로 안의 edf 파일 불러오기

    % 모든 EDF 파일의 데이터를 병합할 배열 초기화
    allSignalData1 = [];
    allSignalData2 = [];
    allSignalData3 = [];
    allSignalData4 = [];

    for j = 1:length(edfFiles)
        filePath = fullfile(folderPath, edfFiles(j).name);

        % EDF 파일을 읽기.
        EDF = edfread(filePath);

        % 각 EDF 파일의 신호 데이터를 배열에 추가
        signalData1 = cell2mat(EDF.EEGL1_Fp1_);
        signalData2 = cell2mat(EDF.EEGR1_Fp2_);
        signalData3 = cell2mat(EDF.EEGL2_F7_);
        signalData4 = cell2mat(EDF.EEGR2_F8_);
        allSignalData1 = [allSignalData1; signalData1];
        allSignalData2 = [allSignalData2; signalData2];
        allSignalData3 = [allSignalData3; signalData3];
        allSignalData4 = [allSignalData4; signalData4];
    end

    % 데이터를 테이블로 변환하고 열 이름 지정
    allSignalData = table(allSignalData1, allSignalData2, allSignalData3, allSignalData4, 'VariableNames', {'EEGL1_Fp1_', 'EEGR1_Fp2_', 'EEGL2_F7_', 'EEGR2_F8_'});
    allSignalData = allSignalData.Variables;
    % 병합된 데이터를 저장
    save([saveDir, 'EDF_', subject_temp], 'allSignalData', '-v7.3');
end