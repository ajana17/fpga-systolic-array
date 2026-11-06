# FPGA Implementation of a 2x2 Signed Systolic Array Matrix Multiplier

The project evaluates both **Radix-4 Modified Booth** and **Vedic** multiplier architectures, demonstrating why Booth was selected to power each Processing Element (PE) in the systolic grid, and proves signed 2's complement matrix arithmetic deployed on physical hardware.

---

## Features

- **Radix-4 Booth Multiplier:** Custom 8-bit signed two's complement multiplier (`-128` to `+127`).
- **Processing Element (PE):** Accumulator with arithmetic sign-extension to 32 bits to prevent overflow and preserve negative values.
- **Wavefront Dataflow:** 2D systolic mesh using sequential boundary skew registers.
- **Hardware Controller:** Integrated FSM to stream matrices, detect start pushbuttons (`BTNC`), and output selected matrix elements via multiplexed slide switches (`SW[1:0]`).
- **Display Driver:** Real-time 8-digit 7-segment active-low hexadecimal display controller (~1 kHz refresh).

---

### Synthesis & Timing Benchmark

| Multiplier Architecture | Slice LUTs | Slice Registers (FFs) | Critical Path Delay ($T_{pd}$) | Max Frequency ($F_{max}$) | Area-Delay Product (ADP) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **8-bit Radix-4 Booth Multiplier** | **89** | **40** | **5.504 ns** | **181.68 MHz** | **~489.8 LUT·ns** |
| **8-bit Vedic Multiplier** | 133 | 35 | 6.500 ns | 153.85 MHz | ~864.5 LUT·ns |
---

### Architectural Trade-Offs & Selection

1. **Area Efficiency:** The Radix-4 Booth multiplier utilizes **89 LUTs**, offering an approximate **33% reduction in logic area** compared to the Vedic core's 133 LUTs.
2. **Speed & Routing:** Booth achieves a shorter critical path. The Vedic multiplier's tree of ripple/carry adders for parallel partial product summation results in deeper combinational logic levels and higher routing congestion.
3. **Signed Arithmetic:** Radix-4 recoding natively supports two's complement signed inputs with minimal additional overhead, whereas an unsigned Vedic multiplier requires explicit magnitude conversion and sign-reconstruction logic.

Consequently, **Radix-4 Booth** was chosen as the baseline multiplication core inside each Processing Element (PE).

---
## Systolic Array Architecture & Dataflow

The design utilizes a **2D Output-Stationary (OS) Systolic Mesh**:
- Each PE holds one stationary accumulator element while input vectors stream across the array horizontally and vertically.
- **Wavefront Scheduling:** Input streams are staggered using boundary skew flip-flops:
  - Row 0 / Col 0 enter immediately.
  - Row 1 / Col 1 are delayed by 1 clock cycle.
