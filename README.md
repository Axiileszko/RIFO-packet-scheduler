# RIFO-packet-scheduler

## Problem Statement

Modern high-speed networks require efficient packet scheduling mechanisms to ensure fairness, low latency, and quality of service (QoS). Traditional scheduling algorithms such as FIFO (First-In-First-Out) are simple but fail to prioritize critical traffic. More advanced approaches like PIFO (Push-In First-Out) enable flexible scheduling based on packet ranks but are difficult to implement efficiently in hardware.

The RIFO (Ranked In-First-Out) scheduler, as proposed in recent research, aims to approximate the behavior of PIFO while maintaining implementation simplicity. In RIFO, packets are assigned integer rank values in advance, where lower values indicate higher priority. Instead of fully sorting packets, RIFO introduces a threshold-based dropping strategy: packets with ranks above a certain threshold are discarded, effectively controlling congestion while preserving important traffic.

This project aims to design and implement a RIFO packet scheduler using the P4 programming language, exploring how programmable data planes can support rank-based scheduling decisions.

## Design Overview

The core idea of the implementation is to extend packet metadata with a rank field and apply decision logic based on this value.

### Packet Rank Assignment
Each packet carries a precomputed rank value, represented as a positive integer, where lower values indicate higher priority. In this design, the rank is embedded in a custom packet header field before the packet enters the P4 switch. This rank is assigned by an external component (most likely a traffic generator) and remains unchanged throughout processing.
### Threshold-Based Filtering
The threshold value is stored in a dedicated register in the data plane. This register holds a single global threshold value that is applied to all packets. The threshold is set by the control plane before execution and remains constant during runtime for the initial implementation. (For simplicity, the initial implementation has a fixed threshold value, but it can later be extended to a dynamically adjustable parameter.)
### Ingress Processing and Decision Logic
The core RIFO logic is implemented in the ingress control block. During ingress processing:
1. The switch reads the packet’s rank from hdr.rifo.rank
2. The threshold value is read from the register
3. The two values are compared

The decision is made using a conditional check:
* If rank > threshold, the packet is marked for drop
* Otherwise, the packet is allowed to continue processing
### Drop Mechanism and Forwarding Behavior
Packets that exceed the threshold are marked for dropping and packets thaat pass the threshold check are forwarded using standard IPv4 forwarding logic implemented in the ingress pipeline.
