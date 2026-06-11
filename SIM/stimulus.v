`timescale 1ns / 1ps


module stimulus();
wire [3:0]sum;
wire cout;
reg [3:0]a,b;
reg cin;

//instantiate lookahead module
lookahead uut(
    .sum(sum),
    .cout(cout),
    .a(a),
    .b(b),
    .cin(cin)
    );
   
//write stimulus to test
// Write stimulus to test
initial begin
    $monitor("TIME=%0t | A=%d (%b) | B=%d (%b) | CIN=%b | SUM=%d (%b) | COUT=%b", 
             $time, a, a, b, b, cin, sum, sum, cout);

    // Initialize inputs at time 0
    a = 4'd0; b = 4'd0; cin = 1'b0;

    // --- GROUP 1: Basic Addition (No Carries) ---
    #10 a = 4'd2;  b = 4'd1;  cin = 1'b0; // 2 + 1 = 3
    #10 a = 4'd5;  b = 4'd4;  cin = 1'b0; // 5 + 4 = 9
    #10 a = 4'd10; b = 4'd4;  cin = 1'b0; // 10 + 4 = 14

    // --- GROUP 2: Basic Carries (No Cout yet) ---
    #10 a = 4'd1;  b = 4'd1;  cin = 1'b0; // 1 + 1 = 2 (Internal carry c1 generated)
    #10 a = 4'd3;  b = 4'd1;  cin = 1'b0; // 3 + 1 = 4 (Internal carry c2 generated)
    #10 a = 4'd7;  b = 4'd1;  cin = 1'b0; // 7 + 1 = 8 (Internal carry c3 generated)

    // --- GROUP 3: Carry Out (Cout / c4) Generation ---
    #10 a = 4'd8;  b = 4'd8;  cin = 1'b0; // 8 + 8 = 16 (Sum = 0, Cout = 1)
    #10 a = 4'd12; b = 4'd5;  cin = 1'b0; // 12 + 5 = 17 (Sum = 1, Cout = 1)
    #10 a = 4'd15; b = 4'd1;  cin = 1'b0; // 15 + 1 = 16 (Sum = 0, Cout = 1)

    // --- GROUP 4: Testing CIN (Carry In) Impact ---
    #10 a = 4'd0;  b = 4'd0;  cin = 1'b1; // 0 + 0 + 1 = 1
    #10 a = 4'd7;  b = 4'd8;  cin = 1'b1; // 7 + 8 + 1 = 16 (Sum = 0, Cout = 1)
    #10 a = 4'd14; b = 4'd0;  cin = 1'b1; // 14 + 0 + 1 = 15 (Sum = 15, Cout = 0)

    // --- GROUP 5: Worst-Case Carry Propagation ---
    // (Forces the lookahead logic to pass CIN through every single P-gate to COUT)
    #10 a = 4'b1111; b = 4'b0000; cin = 1'b1; // 15 + 0 + 1 = 16 (Sum = 0, Cout = 1)
    #10 a = 4'b1010; b = 4'b0101; cin = 1'b1; // 10 + 5 + 1 = 16 (Sum = 0, Cout = 1)

    // --- GROUP 6: Absolute Maximum Boundaries ---
    #10 a = 4'd15; b = 4'd15; cin = 1'b0; // 15 + 15 = 30 (Sum = 14, Cout = 1)
    #10 a = 4'd15; b = 4'd15; cin = 1'b1; // 15 + 15 + 1 = 31 (Sum = 15, Cout = 1)

    // --- GROUP 7: Sliding Bit Patterns ---
    #10 a = 4'b0001; b = 4'b0001; cin = 1'b0; // Bit 0 clash
    #10 a = 4'b0010; b = 4'b0010; cin = 1'b0; // Bit 1 clash
    #10 a = 4'b0100; b = 4'b0100; cin = 1'b0; // Bit 2 clash
    #10 a = 4'b1000; b = 4'b1000; cin = 1'b0; // Bit 3 clash

    // Clean up finish
    #10 a = 4'd0;  b = 4'd0;  cin = 1'b0;
    #10 $finish;
end
endmodule
