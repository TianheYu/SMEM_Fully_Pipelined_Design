# SMEM_Fully_Pipelined_Design
SMEM++, A Fully Pipelined and Time-Multiplexed SMEM Seeding Accelerator for Genome Sequencing

This released code is the SMEM FPGA kernel code, the details of which is described in our paper. The original implementation is on harp2 and has copyright issues so the FPGA side communication interface code is abbreviated. It should be fairly easy to port this code to your platform if features a 512bitwidth read/write port.
You can find our paper within this same repository. 

Please cite our paper if you are inspired by our design.
"SMEM++: A Pipelined and Time-Multiplexed SMEM Seeding Accelerator for Genome Sequencing" 2018 28th International Conference on Field Programmable Logic and Applications (FPL), Jason Cong, Licheng Guo, Po-Tsang Huang, Peng Wei and Tianhe Yu



Copyright (c) 2018, Regents of the University of California
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed by the University of California, Los Angeles.
4. Neither the name of the University of California, Los Angeles nor the
   names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Regents of the University of California ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Regents of the University of California BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
