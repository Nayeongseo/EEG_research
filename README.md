# EEG_research_sevo

### 사람 개개인의 마취제 투여 시 일어나는 섬망을 관찰하기 위함. 

##### 참고
Channel: 4
- 'EEGL1_Fp1','EEGR1_Fp2','EEGL2_F7','EEGR2_F8'

Subject: 42

Anesthetic: Sevoflurane

Language: Matlab

---

##### Data
- EDF_n: EEG data
  - 4 channel
  - size: (1 channel data)x4

- Fs: sampling rate
  - value: 178.1538

- PSI_n: PSI data
  - PSI, time, timeDifferenceInSeconds

- spect_n: spectrum data
  - sfreqs, spect, stimes
  - sfreqs size: 1x(A)
  - spect size: (B)x(A)x4
  - stimes size: 1x(B)

- median: spect median data
  - 4 channel

- coherence_n: coherence data
  - channel: F7, F8
  - size: 60x115
 
- coheren_median: coherence median data
  - size: 60x115
