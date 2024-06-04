module tb_traffic_light_controller;

// Inputs
reg clk;
 reg reset;
 reg [3:0] Emergency_green;
reg  auto_mode_manual;
reg [7:0] yellow_manual;
reg [7:0] green_manual;
reg vsw;


// Outputs
wire fault;
wire system_off;
wire [11:0] traffic_lights;

parameter GREEN_DELAY=24;
parameter YELLOW_DELAY=4;
parameter RED_DELAY=84;

// Instantiate the Unit Under Test (UUT)
traffic_light_controller uut (
    .clk(clk),
    .reset(reset),
    .Emergency_green(Emergency_green),
    .auto_mode_manual(auto_mode_manual),
    .yellow_manual(yellow_manual),
    .green_manual(green_manual),
    .vsw(vsw),
    .fault(fault),
    .system_off(system_off),
    .traffic_lights(traffic_lights)
);

// Clock generation
always #5 clk = ~clk; // Generate a clock with a period of 10ns

// Tasks
task automatic_mode_test;
    begin
        $display("Starting Automatic Mode Test");
        auto_mode_manual = 1; // Set to automatic mode
        vsw = 1; // Ensure vsw is high to enable normal operation

        // Reset the system to start from a known state
        reset = 1;
        #20; // Hold reset for a short period
        reset = 0;
        #20; // Wait for the system to come out of reset

        // Observe the traffic lights for a few cycles
        repeat (4) begin
            @(posedge clk); // Wait for the clock edge to ensure synchronization
            // Check the east green light
            if (traffic_lights[0] !== 1'b1) begin
                $display("Test failed: East green light is not on during the east green state.");
            end
            #((GREEN_DELAY + YELLOW_DELAY) * 10); 

            // Check the north green light
            if (traffic_lights[3] !== 1'b1) begin
                $display("Test failed: North green light is not on during the north green state.");
            end
            #((GREEN_DELAY + YELLOW_DELAY) * 10);

            // Check the west green light
            if (traffic_lights[6] !== 1'b1) begin
                $display("Test failed: West green light is not on during the west green state.");
            end
            #((GREEN_DELAY + YELLOW_DELAY) * 10); 

            // Check the south green light
            if (traffic_lights[9] !== 1'b1) begin
                $display("Test failed: South green light is not on during the south green state.");
            end
            #((GREEN_DELAY + YELLOW_DELAY) * 10);
        end

        $display("Automatic Mode Test Completed Successfully");
    end
endtask
task manual_mode_test;
    begin
        $display("Starting Manual Mode Test");
        auto_mode_manual = 0; // Set to manual mode for the test
        vsw = 1; // Ensure vsw is high to enable normal operation

        // Define manual mode timings
        //red_manual = 10;
        yellow_manual = 5;
        green_manual = 15;

        // Reset the system to start from a known state
        reset = 1;
        #20; // Hold reset for a short period
        reset = 0;
        #20; // Wait for the system to come out of reset

        // Apply manual timings
        @(posedge clk);
       // red_manual <= ;
        yellow_manual <= 5;
        green_manual <= 15;

        // Wait for the manual timings to take effect
        #100;

        
        $display("Manual Mode Test Completed Successfully");
    end
endtask

task vsw_test;
    begin
        $display("Starting vsw Test");

        // Assume automatic mode for this test
        auto_mode_manual = 1; // Set to automatic mode for the test

        // Reset the system to start from a known state
        reset = 1;
        #20; // Hold reset for a short period
        reset = 0;
        #20; // Wait for the system to come out of reset

        // Set vsw high to enable normal operation
        vsw = 1;
        #100; // Wait for some time to observe the normal operation

        // Check if the system is operating normally with vsw high
        if (system_off !== 1'b0) begin
            $display("Test failed: System should not be off when vsw is high.");
        end

        // Now, disable the system by setting vsw low
        vsw = 0;
        #100; // Wait for some time to observe the disabled state

        // Check if the system is disabled with vsw low
        if (system_off !== 1'b1) begin
            $display("Test failed: System should be off when vsw is low.");
        end

        // Check if all traffic lights are in the all-yellow state when vsw is low
        if (traffic_lights !== 12'b010010010010) begin
            $display("Test failed: All traffic lights should be yellow when vsw is low.");
        end

        // Re-enable the system by setting vsw high again
        vsw = 1;
        #100; // Wait for some time to observe the re-enabled state

        // Check if the system is operating normally after re-enabling
        if (system_off !== 1'b0) begin
            $display("Test failed: System should not be off after re-enabling with vsw high.");
        end

        $display("vsw Test Completed Successfully");
    end
endtask

task emergency_test;
    begin
        $display("Starting Emergency Mode Test");
        auto_mode_manual = 1; // Set to automatic mode for the test
        vsw = 1; // Ensure vsw is high to enable normal operation

        // Reset the system to start from a known state
        reset = 1;
        #20; // Hold reset for a short period
        reset = 0;
        #20; // Wait for the system to come out of reset

        // Test emergency for east green light
        Emergency_green = 4'b0001;
        #10; // Small delay to allow the system to process the emergency input
        if (traffic_lights[0] !== 1'b1 || traffic_lights[1] !== 1'b0 || traffic_lights[2] !== 1'b0) begin
            $display("Test failed: East green light is not on during the east emergency state.");
        end
        #100; // Wait to observe the emergency state

        // Test emergency for north green light
        Emergency_green = 4'b0010;
        #10; // Small delay to allow the system to process the emergency input
        if (traffic_lights[3] !== 1'b1 || traffic_lights[4] !== 1'b0 || traffic_lights[5] !== 1'b0) begin
            $display("Test failed: North green light is not on during the north emergency state.");
        end
        #100; // Wait to observe the emergency state

        // Test emergency for west green light
        Emergency_green = 4'b0100;
        #10; // Small delay to allow the system to process the emergency input
        if (traffic_lights[6] !== 1'b1 || traffic_lights[7] !== 1'b0 || traffic_lights[8] !== 1'b0) begin
            $display("Test failed: West green light is not on during the west emergency state.");
        end
        #100; // Wait to observe the emergency state

        // Test emergency for south green light
        Emergency_green = 4'b1000;
        #10; // Small delay to allow the system to process the emergency input
        if (traffic_lights[9] !== 1'b1 || traffic_lights[10] !== 1'b0 || traffic_lights[11] !== 1'b0) begin
            $display("Test failed: South green light is not on during the south emergency state.");
        end
        #100; // Wait to observe the emergency state

        // Reset emergency to no emergency
        Emergency_green = 4'b0000;
        #10; // Small delay to allow the system to process the emergency input

        $display("Emergency Mode Test Completed Successfully");
    end
endtask

// Test sequence
initial begin
    // Initialize Inputs
    clk = 0;
    reset = 1;
    Emergency_green = 0;
    auto_mode_manual = 0;
    yellow_manual = 0;
    green_manual = 0;
    vsw = 0;

    // Wait for global reset
    #100;
    reset = 0;

    // Add test sequence here
    automatic_mode_test;
    #100; // Wait for some time to observe the behavior in automatic mode

    manual_mode_test;
    #100; // Wait for some time to observe the behavior in manual mode

    vsw_test;
    #100; // Wait for some time to observe the behavior with vsw changes

    emergency_test;
    #100; // Wait for some time to observe the behavior in emergency cases

    $finish; // End the simulation
end

endmodule