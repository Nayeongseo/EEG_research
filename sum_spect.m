saveDir = './data/'; % spect, stimes, sfreqs 저장할 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리

subject_num = char('01','02','03','04','05','06'); % 파일 이름. 주로 데이터 확정시 사용.
[r,c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이

params.Fpass = 2000;
params.fpass = [0 40];
params.tapers = [3 5];
movingwin = [4 0.1];

for i = 1:r
    subject_temp = deblank(subject_num(i,:)); % i 번째에 있는 전체 문자열 불러오기.

    load([saveDir,'EDF_',subject_temp]);
   
    y = signalData(:, :);
    final = y';
    disp('Computing multitaper spectrogram...');
    [spect, stimes, sfreqs]=mtspecgramc(double(final'), movingwin, params);
    spect = single(spect);
    disp('Saving data...')

    % .mat 파일로 저장
    save([saveDir,'spect_',subject_temp], 'spect', 'stimes', 'sfreqs', '-v7.3');

end