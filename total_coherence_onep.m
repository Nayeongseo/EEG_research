saveDir = './data/'; % data 저장 공간
addpath('./mtspecgramc/'); % 함수 사용할 디렉토리
SaveFigdir = './figure1/'; % 사진 저장할 공간


% Define parameters based on the paper
Fs = load([saveDir,'Fs']); % 샘플링 주파수 (Hz)
fs = Fs.samlingrate; % 샘플링 주파수 (Hz), 실제 값으로 대체
params = struct();
params.Fs = fs; % 샘플링 주파수 (Hz)
params.tapers = [3 5];    % Time-bandwidth product and number of tapers
params.pad = 0;           % No padding
params.fpass = [0 40];    % Frequency range of interest (0-40 Hz)
params.trialave = 0;      % Do not average across trials


data = load([saveDir, 'EDF_', '05', '.mat']);
data = data.('allSignalData');
% 데이터 추출
signalF7 = data(:, 3); % F7 채널 데이터
signalF8 = data(:, 4); % F8 채널 데이터


% 전체 데이터에서 10분부터 12분 사이의 데이터 추출
start_time = 6000; % 10분 (6000초)
end_time = 6120; % 12분 (6120초)
idxStart = round(start_time * fs); % 10분에 해당하는 인덱스 (반올림하여 정수로 변환)
idxEnd = round(end_time * fs); % 12분에 해당하는 인덱스 (반올림하여 정수로 변환)

% 데이터 추출
dataSegmentF7 = signalF7(idxStart:idxEnd); % 10-12분 사이의 F7 데이터
dataSegmentF8 = signalF8(idxStart:idxEnd); % 10-12분 사이의 F8 데이터

% Compute spectra using mtspectrumc
[S1, f] = mtspectrumc(dataSegmentF7, params); % Spectrum of F7
[S2, ~] = mtspectrumc(dataSegmentF8, params); % Spectrum of F8

% Compute cross-spectral density
% Here we calculate the cross-spectrum between signalF7 and signalF8
J1 = mtfftc(dataSegmentF7, dpsschk(params.tapers, length(dataSegmentF7), fs), max(2^(nextpow2(length(dataSegmentF7))+params.pad),length(dataSegmentF7)), fs);
J2 = mtfftc(dataSegmentF8, dpsschk(params.tapers, length(dataSegmentF8), fs), max(2^(nextpow2(length(dataSegmentF8))+params.pad),length(dataSegmentF8)), fs);

J1 = J1(f>=params.fpass(1) & f<=params.fpass(2), :);
J2 = J2(f>=params.fpass(1) & f<=params.fpass(2), :);

S12 = squeeze(mean(conj(J1).*J2,2)); % Cross-spectral density

% Compute coherence
Cxy = abs(S12).^2 ./ (S1 .* S2);

% Plot coherence
figure('color','w','units','normalized','position', [0 0 .8 .95]);
plot(f, Cxy, 'LineWidth', 2);
xlabel('Frequency (Hz)');
ylabel('Coherence');
title('Coherence between F7 and F8');
grid on;