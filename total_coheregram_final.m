saveDir = './data/'; % data 저장 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리
SaveFigdir = './figure1/'; % 사진 저장할 공간

% Define parameters based on the provided conditions
% Define parameters based on the paper
Fs = load([saveDir,'Fs']); % 샘플링 주파수 (Hz)
fs = Fs.samlingrate; % 샘플링 주파수 (Hz), 실제 값으로 대체
params = struct();
params.Fs = fs; % 샘플링 주파수 (Hz)
params.tapers = [3 5]; % [TW, K] = [3, 5]
params.pad = 0; % No padding
params.fpass = [0 40]; % 주파수 범위 (0-40 Hz)
params.trialave = 0; % 트라이얼 평균 없음
params.err = [2 0.05];

% 윈도우 및 스텝 설정
movingwin = [2 2]; % [window_length, step_size] in seconds

% saveDir에 있는 폴더 이름 불러오기
folders = dir(saveDir);
folders = folders([folders.isdir]); % 디렉토리만 필터링
folders = folders(~ismember({folders.name}, {'.', '..'})); % '.'와 '..' 제거
subject_num = {folders.name}; % 폴더 이름을 셀 배열로 저장

[r, c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이


% Plot the coheregram for the selected time range
%figure('color', 'w', 'units', 'normalized', 'position', [0 0 .8 .95]);


for i = 1:c
    subject_temp = subject_num{i};
    data = load([saveDir, 'EDF_', subject_temp, '.mat']);
    data = data.('allSignalData');
    % 데이터 추출
    signalF7 = data(:, 3); % F7 채널 데이터
    signalF8 = data(:, 4); % F8 채널 데이터

    [C,phi,S12,S1,S2,t,f,confC,phistd,Cerr]=cohgramc(signalF7,signalF8,movingwin,params);

    time_range = [6000 6120]; % 10분부터 12분까지였는데 수정...
    time_idx = t >= time_range(1) & t <= time_range(2);

    C_selected = C(time_idx, :);
    t_selected = t(time_idx);

    % 그래프 그리기
    %subplot(6, 7, i)
    %colormap jet
    %imagesc(t_selected, f, C_selected'); % Use t_selected for time and f for frequency
    %set(gca, 'clim', [0 1]); % Coherence ranges from 0 to 1
    %axis xy;

    %xlabel('Time (s)');
    %ylabel('Frequency (Hz)');
    %c = colorbar('location','eastoutside');
    %ylabel(c,'Power (dB)');
    %title(subject_temp);

    
    % .mat 파일로 저장
    disp('Saving data...');
    save([saveDir,'coherence_', subject_temp], "C_selected", '-v7.3');
end

disp('Saving data...');
save([saveDir,'freq'], "f", '-v7.3');

% Save the figure
saveas(gcf, [SaveFigdir, '0']);