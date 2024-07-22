SaveFigdir = './figure/'; % 사진 저장할 공간
saveDir = './data/'; % 데이터 저장 경로


subject_num = char('01','02','03','04','05','06'); % 파일 이름. 주로 데이터 확정시 사용.
density_num = char('14', '16', '18', '20', '22', '24'); % 마취 농도
[r, c] = size(subject_num); % r: subject_num 길이, c: 각 요소들의 길이
[rr, cc] = size(density_num);

fig1 = figure('color','w','units','normalized','position', [0 0 .8 .95]);
suptitle('EEG per density');
i = 6
for i = 1:r
    subject_temp = deblank(subject_num(i, :));
    load([saveDir,'spect101_',subject_temp,'.mat']);
    annotationData = load([saveDir, 'annotation_', subject_temp, '.mat']);

    spect_normalize = double(spect);
    
    title(['Subject ', subject_temp])

    subplot(3, 2, i);
    colormap jet
    imagesc(stimes, sfreqs, pow2db(spect_normalize(:,:)'));
    set(gca,'clim',[-10 30])
    axis xy;
    ylabel('Frequency (Hz)');
    c = colorbar('location','eastoutside');
    ylabel(c,'Power (dB)');

    yyaxis right; % 오른쪽 y축 사용
    ylabel('Density');
    ylim([0 3]);

    hold on; % 새로운 요소를 같은 플롯에 추가

    % density 정보에 따른 계단형 그래프 그리기
    y = 0; % 초기 y 위치
    prev_density_value = 0; % 초기 density 값
    j = 3
    for j = 1:rr
        density_temp = deblank(density_num(j, :));
        varName = ['density_', density_temp];
        y_next = 1.2 + 0.2*j; % y 값 증가
        % density_value 가져오기
        density_value = annotationData.(varName);

        plot([prev_density_value, density_value], [y, y], 'w-', 'LineWidth', 2); % 수평선
        plot([density_value, density_value], [y, y_next], 'w-', 'LineWidth', 2); % 수직선
        prev_density_value = density_value; % 이전 density 값 업데이트
        y = y_next;
        y
    end

    plot([prev_density_value, density_value], [y, y], 'w-', 'LineWidth', 2); % 수평선

    for j = rr-1:-1:1
        density_temp = deblank(density_num(j, :));
        varName = ['density_', density_temp, '_2'];
        y_next = y - 0.2; % y 값 증가
        % density_value 가져오기
        density_value = annotationData.(varName);

        plot([prev_density_value, density_value], [y, y], 'w-', 'LineWidth', 2); % 수평선
        plot([density_value, density_value], [y, y_next], 'w-', 'LineWidth', 2); % 수직선
        prev_density_value = density_value; % 이전 density 값 업데이트
        y = y_next;
        y
    end
    x_limits = xlim;
    x_end = x_limits(2);

    plot([prev_density_value, x_end], [y, y], 'w-', 'LineWidth', 2); % 수평선
    hold off;
end