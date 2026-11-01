`timescale 1ns/1ps

module tb_alu64;

    reg clk ;
    reg rst ;
    reg [63:0] A;
    reg [63:0] B ;
    reg [3:0] opcode;

    wire [63:0] result;
    wire zero ;
    wire carry ;
    wire overflow;
    wire negative;

    integer pass_count ;
    integer fail_count ;
    integer i ;

    reg [63:0] expected_result;
    reg expected_carry ;
    reg expected_overflow;
    reg [64:0] temp_sum ;
    reg [63:0] temp_diff;

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam NOT  = 4'b0101;
    localparam SLL  = 4'b0110;
    localparam SRL  = 4'b0111;
    localparam SRA  = 4'b1000;
    localparam SLT  = 4'b1001;
    localparam SLTU = 4'b1010;

    alu64 dut (
        .clk(clk),.rst(rst),.A(A),.B(B),.opcode(opcode),.result(result)
        ,.zero(zero),.carry(carry),.overflow(overflow),.negative(negative)
    );

    initial begin 
        clk = 1'b0;
        forever #5 clk =~clk;
    end

    initial begin
        $dumpfile("simulation/alu64.vcd");
        $dumpvars(0, tb_alu64);
    end

    task check_alu ;
        input [3:0] op;
        input [63:0] operand_a;
        input [63:0] operand_b;
        input [63:0] expected_result;
        input expected_carry;
        input expected_overflow;

        begin 

            @(negedge clk );
            
            opcode = op;
            A      = operand_a;
            B      = operand_b;
            
            @(posedge clk);
            #1;

            if (
                result   === expected_result   &&
                carry    === expected_carry    &&
                overflow === expected_overflow &&
                zero     === (expected_result == 64'b0) &&
                negative === expected_result[63]
            ) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS | OP=%b A=%h B=%h RESULT=%h",
                    op, operand_a, operand_b, result
                );

            end

            else begin

                fail_count = fail_count + 1;

                $display("FAIL | OP=%b", op);
                $display("  A              = %h", operand_a);
                $display("  B              = %h", operand_b);
                $display("  Expected result= %h", expected_result);
                $display("  Actual result  = %h", result);
                $display("  Expected carry = %b", expected_carry);
                $display("  Actual carry   = %b", carry);
                $display("  Expected ovf   = %b", expected_overflow);
                $display("  Actual ovf     = %b", overflow);
                $display("  Zero           = %b", zero);
                $display("  Negative       = %b", negative);

            end

        end

    endtask

    // ================================================
    // 7. Main Test Sequence
    // ================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

                // --------------------------------------------
        // TEST 1: Synchronous Reset
        // --------------------------------------------

        rst    = 1'b0;
        A      = 64'd10;
        B      = 64'd20;
        opcode = ADD;

        // Assert reset on the falling edge
        @(negedge clk);
        rst = 1'b1;

        // Check after the next rising edge
        @(posedge clk);
        #1;

        if (
            result   === 64'b0 &&
            zero     === 1'b1  &&
            carry    === 1'b0  &&
            overflow === 1'b0  &&
            negative === 1'b0
        ) begin

            pass_count = pass_count + 1;
            $display("PASS | Synchronous reset");

        end
        else begin

            fail_count = fail_count + 1;
            $display("FAIL | Synchronous reset");
            $display("  result   = %h", result);
            $display("  zero     = %b", zero);
            $display("  carry    = %b", carry);
            $display("  overflow = %b", overflow);
            $display("  negative = %b", negative);

        end

        // Deassert reset on the falling edge
        @(negedge clk);
        rst = 1'b0;

        // --------------------------------------------
        // TEST 2: Addition
        // --------------------------------------------

        $display("");
        $display("--- ADDITION TESTS ---");

        check_alu(
            ADD, 64'd10, 64'd20,
            64'd30, 1'b0, 1'b0
        );

        // Maximum unsigned value + 1
        check_alu(
            ADD, 64'hFFFFFFFFFFFFFFFF, 64'd1,
            64'h0000000000000000, 1'b1, 1'b0
        );

        // Maximum positive signed value + 1
        check_alu(
            ADD, 64'h7FFFFFFFFFFFFFFF, 64'd1,
            64'h8000000000000000, 1'b0, 1'b1
        );

        // --------------------------------------------
        // TEST 3: Subtraction
        // --------------------------------------------

        $display("");
        $display("--- SUBTRACTION TESTS ---");

        check_alu(
            SUB, 64'd30, 64'd10,
            64'd20, 1'b1, 1'b0
        );

        // Unsigned borrow
        check_alu(
            SUB, 64'd5, 64'd10,
            64'hFFFFFFFFFFFFFFFB, 1'b0, 1'b0
        );

        // Minimum signed value - 1
        check_alu(
            SUB, 64'h8000000000000000, 64'd1,
            64'h7FFFFFFFFFFFFFFF, 1'b1, 1'b1
        );

        // --------------------------------------------
        // TEST 4: Logical Operations
        // --------------------------------------------

        $display("");
        $display("--- LOGICAL OPERATION TESTS ---");

        check_alu(
            AND, 64'hFF00FF00FF00FF00,
                 64'h0F0F0F0F0F0F0F0F,
            64'h0F000F000F000F00, 1'b0, 1'b0
        );

        check_alu(
            OR, 64'hFF00000000000000,
                64'h00000000000000FF,
            64'hFF000000000000FF, 1'b0, 1'b0
        );

        check_alu(
            XOR, 64'hAAAAAAAAAAAAAAAA,
                 64'h5555555555555555,
            64'hFFFFFFFFFFFFFFFF, 1'b0, 1'b0
        );

        check_alu(
            NOT, 64'h0000000000000000, 64'd0,
            64'hFFFFFFFFFFFFFFFF, 1'b0, 1'b0
        );

        // --------------------------------------------
        // TEST 5: Shift Operations
        // --------------------------------------------

        $display("");
        $display("--- SHIFT TESTS ---");

        check_alu(
            SLL, 64'd1, 64'd4,
            64'd16, 1'b0, 1'b0
        );

        check_alu(
            SRL, 64'h8000000000000000, 64'd4,
            64'h0800000000000000, 1'b0, 1'b0
        );

        check_alu(
            SRA, 64'h8000000000000000, 64'd4,
            64'hF800000000000000, 1'b0, 1'b0
        );

        // Shift by 63 positions
        check_alu(
            SLL, 64'd1, 64'd63,
            64'h8000000000000000, 1'b0, 1'b0
        );

        // --------------------------------------------
        // TEST 6: Comparison Operations
        // --------------------------------------------

        $display("");
        $display("--- COMPARISON TESTS ---");

        check_alu(
            SLT, 64'hFFFFFFFFFFFFFFFF, 64'd1,
            64'd1, 1'b0, 1'b0
        );

        check_alu(
            SLTU, 64'hFFFFFFFFFFFFFFFF, 64'd1,
            64'd0, 1'b0, 1'b0
        );

        check_alu(
            SLT, 64'd10, 64'd5,
            64'd0, 1'b0, 1'b0
        );

        check_alu(
            SLTU, 64'd5, 64'd10,
            64'd1, 1'b0, 1'b0
        );

        // --------------------------------------------
        // TEST 7: Zero Result
        // --------------------------------------------

        $display("");
        $display("--- ZERO FLAG TEST ---");

        check_alu(
            SUB, 64'h123456789ABCDEF0,
                 64'h123456789ABCDEF0,
            64'd0, 1'b1, 1'b0
        );

        // --------------------------------------------
        // TEST 8: Back-to-Back Operations
        // --------------------------------------------

        $display("");
        $display("--- BACK-TO-BACK TESTS ---");

        check_alu(
            ADD, 64'd100, 64'd200,
            64'd300, 1'b0, 1'b0
        );

        check_alu(
            SUB, 64'd300, 64'd100,
            64'd200, 1'b1, 1'b0
        );

        check_alu(
            XOR, 64'hAAAAAAAAAAAAAAAA,
                 64'hAAAAAAAAAAAAAAAA,
            64'd0, 1'b0, 1'b0
        );

        // --------------------------------------------
        // TEST 9: Randomized Addition and Subtraction
        // --------------------------------------------

        $display("");
        $display("--- RANDOMIZED ARITHMETIC TESTS ---");

        for (i = 0; i < 20; i = i + 1) begin

            A = {$random, $random};
            B = {$random, $random};

            // Randomized addition
            temp_sum = {1'b0, A} + {1'b0, B};

            check_alu(
                ADD, A, B,
                temp_sum[63:0],
                temp_sum[64],
                (~(A[63] ^ B[63])) &
                (temp_sum[63] ^ A[63])
            );

            // Randomized subtraction
           // Randomized subtraction
            temp_diff = A - B;

            check_alu(
                SUB, A, B,
                temp_diff,
                (A >= B),
                (A[63] ^ B[63]) &
                (temp_diff[63] ^ A[63])
            );

        end

        // --------------------------------------------
        // TEST 10: Invalid Opcode
        // --------------------------------------------

        $display("");
        $display("--- INVALID OPCODE TEST ---");

        check_alu(
            4'b1111, 64'd10, 64'd20,
            64'd0, 1'b0, 1'b0
        );

        // --------------------------------------------
        // FINAL SUMMARY
        // --------------------------------------------

        $display("");
        $display("========================================");
        $display("          VERIFICATION SUMMARY");
        $display("========================================");

        $display("Total PASS: %0d", pass_count);
        $display("Total FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("ALU VERIFICATION FAILED");

        $display("========================================");

        $finish;

    end

endmodule