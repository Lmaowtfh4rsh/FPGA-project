Comparison Summary 

1. Overview

The design encrypts data using:
Non-pipelined DES core
Pipelined DES core

Both designs use Xilinx Block Memory Generator (BRAM IP) to:
Read plaintext
Send it to DES core
Write ciphertext back into BRAM

2. Functional Verification

Non-Pipelined Simulation Output
Addr 0 : Input = 123456789abcdef0 | Output = 069d0bf0000000e3
Addr 1 : Input = 069d0bf0000000e3 | Output = 069d0bf000000000
Addr 2 : Input = 069d0bf000000000 | Output = 069d0bf000000000
Addr 3 : Input = 069d0bf000000000 | Output = 069d0bf000000000
Addr 4 : Input = 069d0bf000000000 | Output = 069d0bf000000000

Pipelined Simulation Output
Addr 0: Input=0000000000000000 | Output=884988d80143c46c
Addr 1: Input=1010101010101010 | Output=884988d80143c46c
Addr 2: Input=2020202020202020 | Output=884998c81153d47c
Addr 3: Input=3030303030303030 | Output=8849a8f82163e44c
Addr 4: Input=4040404040404040 | Output=8849b8e83173f45c

Both designs successfully:
Read plaintext from BRAM
Encrypted using DES
Wrote encrypted data back to BRAM

3. Latency Comparison

Design	Time when done LED = 1	
Non-Pipelined	~385 ns	16 rounds executed sequentially
Pipelined	~995 ns	Full 16-stage pipeline, processes 64 blocks

Important:
Pipelined design has higher total time, because it processes many blocks through 16 pipeline stages.
But its throughput is much higher, because after pipeline fills, 1 block is produced every clock cycle.

4. Waveform Evidence

Non-pipelined:
<img width="1920" height="1080" alt="Screenshot 2025-11-24 195702" src="https://github.com/user-attachments/assets/8e42b9ea-d0c0-4d7e-8261-3657217904d3" />

Pipelined:
<img width="1920" height="1080" alt="Screenshot 2025-11-24 192142" src="https://github.com/user-attachments/assets/75afe8f2-9eca-45ba-8634-28d7e6e28792" />
<img width="1920" height="1080" alt="Screenshot 2025-11-24 191401" src="https://github.com/user-attachments/assets/661f28eb-5c10-4b6d-86cb-3186b518653d" />

These show the round-by-round behavior vs. pipeline flow.

5. Conclusion

The non-pipelined DES performs one round per 25–30 ns → low throughput but simpler.
The pipelined DES achieves 1 ciphertext per cycle after filling the pipeline.
Using BRAM IP allows clean memory interfacing and realistic hardware simulation.
Simulation verifies correct encryption and controller operation.
