![image](https://github.com/smritisharmaaaaaaa/Verilog-Traffic-Light-Controller/assets/136004533/6798a468-fc7c-4302-80e5-a8bb2249d94f)# Verilog-Traffic-Light-Controller
Four junctional Verilog traffic light controller 

# Traffic Light Controller Requirements

## System Requirements Overview

This document outlines the requirements for a traffic light controller designed for a four-way junction in a city. The controller is to be implemented as a hardware-driven state machine without the use of a dedicated microcontroller.

### M_SYS_001: Four-Way Junction Consideration
- **Requirement**: The controller needs to be developed keeping 4 crossing roads at a junction in mind.
- **Rationale**: All roads are 4 junctions in the city.

### M_SYS_002: Hardware-Driven State Machine
- **Requirement**: The controller may be a completely hardware-driven state machine and not software-based as in a dedicated microcontroller.

### M_SYS_003: Traffic Light Outputs
- **Requirement**: The IP should cater to 3 traffic lights - RED, YELLOW, GREEN on 4 roads and hence a total of 12 outputs.
- **Rationale**: Output peripherals.

### M_SYS_004: State Machine Bit Limitation
- **Requirement**: The number of bits in the state machine should not exceed 4.
- **Rationale**: With 4 bits, you may be able to handle up to 16 outputs.

### M_SYS_005: Traffic Light Sequence
- **Requirement**: The sequence of lights should be RED- 85s, YELLOW - 5s, GREEN - 30s, and repeat in order for all roads.

### M_SYS_006: Programmable Delay Values
- **Requirement**: The state machine should allow the programming of these delay values through a dedicated "forcible" register interface from the top.
- **Rationale**: Means in manual mode we can write the inputs of delays manually; timers and timing sequence.

### M_SYS_007: Mode Selection
- **Requirement**: The controller should support 2 modes - Automatic and Manual, selectable by an async input "mode_auto_notmanual".
- **Rationale**: Additional input peripheral.

### M_SYS_008: Delay Values in Different Modes
- **Requirement**: In case of automatic, the delay values are as specified in M_SYS_005. In manual mode, the delay values are specified by register input.
- **Rationale**: In case we need to use it for morning, evening, weekend, traffic hours.

### M_SYS_009: Manual Mode Register Inputs
- **Requirement**: The register inputs in manual mode shall be separate- RED, GREEN, YELLOW for 4 roads. So, in total 12 registers.

### M_SYS_010: Hardware Limitation
- **Requirement**: The number of gates in implementation should not exceed 10,000 2 input LUTs (equivalent) and 10,000 flip-flops.
- **Rationale**: Die size limitation.

### M_SYS_011: Clock and Reset Inputs
- **Requirement**: The system should run using only 1 clock input and 1 reset input (Asynchronous).

### M_SYS_012: Power Failure State Retention
- **Requirement**: In case of power failure, when the system is put back on power, it should be back to the same state where it was before power loss.
- **Rationale**: Retention of state is needed.

### M_SYS_013: One Side Green Requirement
- **Requirement**: The system should ensure that only 1 side is green at any point in time, else it should signal a failure.
- **Rationale**: Safety Requirement.

### M_SYS_014: Fault Signal
- **Requirement**: In case a system is not safe, a signal named fault should be high asynchronously (Immediately as soon as the failure situation occurs).
- **Rationale**: Safety Requirement.

### M_SYS_015: System Shutdown Indication
- **Requirement**: In case the system is powered on but deliberately shut off by traffic police, it should signal "System_off=1" and all lights put to yellow.
- **Rationale**: We may need to differentiate between a working and non-working system.

### M_SYS_016: Emergency Vehicle Priority
- **Requirement**: The system should have 4 emergency signals to turn any side green at any given point and then the system should resume from that state (Following next side green). So there must be 4 such signals for each side of the crossing.
- **Rationale**: Important for emergency vehicles to not pile up; emergency peripheral.
