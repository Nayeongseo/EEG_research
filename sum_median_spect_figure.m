saveDir = './data/';

subject_num = char('01','02','03','04','05','06'); % 파일 이름. 주로 데이터 확정시 사용.
density_num = char('14', '16', '18', '20', '22', '24'); % 마취 농도

[r, c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이
[rr, cc] = size(density_num);

% 각 마취 농도에 대해 데이터를 저장할 구조체 초기화
totalEEG = struct();
totalTime = struct();

for i = 1:r
    subject_temp = deblank(subject_num(i, :));
    data = load([saveDir, 'spect101_', subject_temp, '.mat']);
    AnnotationData = load([saveDir, 'annotation_', subject_temp, '.mat']);

    for j = 1:rr
        density_temp = deblank(density_num(j, :));
        varName = ['density_', density_temp];
        density_value = AnnotationData.(varName);
        idxStart = find(data.stimes >= density_value, 1);
        idxEnd = idxStart + 2999
        % 데이터가 이미 존재하면 새로운 데이터를 추가
        if isfield(totalEEG, varName)
            totalEEG.(varName) = cat(1, totalEEG.(varName), reshape(data.spect(idxStart:idxEnd, :), 1, 3000, 41));
            totalTime.(varName) = cat(1, totalTime.(varName), reshape(data.stimes(idxStart:idxEnd), 1, 1, 3000));
        else
            totalEEG.(varName)(1,:,:) = data.spect(idxStart:idxEnd, :);
            totalTime.(varName)(1,:,:) = data.stimes(idxStart:idxEnd);
        end
    end
end


fig1 = figure('color','w','units','normalized','position', [0 0 .8 .95]);
subplot(2, 3, 1)
colormap jet
imagesc(1:300, data.sfreqs, pow2db(squeeze(median(totalEEG.density_14))'));
set(gca, 'clim', [0 15])
axis xy;
ylabel('Frequency (Hz)');
c = colorbar('location','eastoutside');
ylabel(c,'Power (dB)');
title('1.4%')
disp(size(median(totalEEG.(varName))));

subplot(2, 3, 2)
colormap jet
imagesc(1:300, data.sfreqs, pow2db(squeeze(median(totalEEG.density_16))'));
set(gca, 'clim', [0 15])
axis xy;
ylabel('Frequency (Hz)');
c = colorbar('location','eastoutside');
ylabel(c,'Power (dB)');
title('1.6%')


subplot(2, 3, 3)
colormap jet
imagesc(1:300, data.sfreqs, pow2db(squeeze(median(totalEEG.density_18))'));
set(gca, 'clim', [0 15])
axis xy;
ylabel('Frequency (Hz)');
c = colorbar('location','eastoutside');
ylabel(c,'Power (dB)');
title('1.8%')

subplot(2, 3, 4)
colormap jet
imagesc(1:300, data.sfreqs, pow2db(squeeze(median(totalEEG.density_20))'));
set(gca, 'clim', [0 15])
axis xy;
ylabel('Frequency (Hz)');
c = colorbar('location','eastoutside');
ylabel(c,'Power (dB)');
title('2.0%')

subplot(2, 3, 5)
colormap jet
imagesc(1:300, data.sfreqs, pow2db(squeeze(median(totalEEG.density_22))'));
set(gca, 'clim', [0 15])
axis xy;
ylabel('Frequency (Hz)');
c = colorbar('location','eastoutside');
ylabel(c,'Power (dB)');
title('2.2%')

subplot(2, 3, 6)
colormap jet
imagesc(1:300, data.sfreqs, pow2db(squeeze(median(totalEEG.density_24))'));
set(gca, 'clim', [0 15])
axis xy;
ylabel('Frequency (Hz)');
c = colorbar('location','eastoutside');
ylabel(c,'Power (dB)');
title('2.4%')