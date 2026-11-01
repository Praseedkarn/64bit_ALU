`timescale 1ns/1ps

module alu64(
        input wire clk , 
        input wire rst ,
        input wire [63:0] A,
        input wire [63:0] B ,
        input wire [3:0] opcode,

        output reg [63:0] result,
        output reg zero ,
        output reg carry ,
        output reg overflow,
        output reg negative
    );

    //opcode defination 

    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam AND = 4'b0010;
    localparam OR  = 4'b0011;
    localparam XOR = 4'b0100;
    localparam NOT = 4'b0101;
    localparam SLL = 4'b0110;
    localparam SRL = 4'b0111;
    localparam SRA = 4'b1000;
    localparam SLT = 4'b1001;
    localparam SLTU = 4'b1010;

    //inertnal signal 

    reg [63:0] result_next ;
    reg carry_next;
    reg overflow_next;
    reg zero_next;
    reg negative_next;

    reg[64:0] arithmetric_temp;

    //combinational ALU Logic 

    always @(*) begin 
        //default value 

        result_next = 64'b0;
        carry_next = 1'b0;
        overflow_next = 1'b0;
        arithmetric_temp=65'b0;

        case(opcode)
            ADD:begin 
                arithmetric_temp=
                    {1'b0,A}+{1'b0,B};
                
                result_next=arithmetric_temp[63:0];
                carry_next = arithmetric_temp[64];

                overflow_next=
                (~(A[63]^B[63])) & 
                (result_next[63]^A[63]);
            end

            SUB :begin
                result_next=A-B;

                carry_next=(A>=B);
                overflow_next=
                    (A[63]^B[63])&
                    (result_next[63]^A[63]);

            end

            AND:begin
                result_next = A&B;
            end

            OR :begin
                result_next =A|B ;
            end

            XOR :begin
                result_next = A^B;
            end

            NOT: begin 
                result_next= ~A;
            end

            SLL:begin
                result_next=A<<B[5:0];
            end

            SRL:begin
                result_next=A>>B[5:0];
            end

            SRA :begin
                result_next =$signed(A)>>>B[5:0];
            end

            SLT:begin
                result_next= ($signed(A)< $signed(B))
                ? 64'd1 : 64'd0;
            end

            SLTU :begin 
                result_next = (A<B)? 64'd1 : 64'd0;
            end


            default:begin 

                result_next = 64'b0;
                carry_next = 1'b0;
                overflow_next = 1'b0;

            end

        endcase

        zero_next = (result_next == 64'b0);
        negative_next = result_next[63];
    end

    always @(posedge clk) begin 
        if (rst) begin 
            result <= 64'b0;
            zero <= 1'b1;
            carry <= 1'b0;
            overflow <= 1'b0;
            negative<= 1'b0;

        end
        else begin 
            result <= result_next ; 
            zero <= zero_next;
            carry <= carry_next;
            overflow <= overflow_next;
            negative <=negative_next;
        end
    end
endmodule  
        