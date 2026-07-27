module cpu4_program_rom #(
    parameter string PROGRAM_FILE = "demo_cpu4.mem"
) (
    input  logic [3:0] address,
    output logic [7:0] instruction
);
    logic [7:0] memory [0:15];
    integer index;

    initial begin
        for (index = 0; index < 16; index = index + 1) begin
            memory[index] = 8'h00;
        end

        if (PROGRAM_FILE != "") begin
            $readmemh(PROGRAM_FILE, memory);
        end
    end

    assign instruction = memory[address];
endmodule