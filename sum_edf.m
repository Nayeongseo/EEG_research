saveDir = './data/'; % EDF 저장할 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리

subject_num = char('01','02','03','04','05','06'); % 파일 이름. 주로 데이터 확정시 사용.
[r,c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이

for i = 1:r
    subject_temp = deblank(subject_num(i,:));

    folderPath = fullfile(saveDir, subject_temp);
    edfFile = dir(fullfile(folderPath, '*.edf')); % 이 경로 안의 edf 파일 불러오기
    filePath = fullfile(folderPath, edfFile.name);

    % EDF 파일을 읽기.
    [EDF, annotations] = edfread(filePath);
    signalData = cell2mat(EDF.EEGEEG_4_SA_B);

    save([saveDir,'EDF_',subject_temp], 'signalData', '-v7.3');


end