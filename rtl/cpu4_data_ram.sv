module cpu4_data_ram (
    input  logic       clk,
    input  logic       write_enable,
    input  logic [3:0] address,
    input  logic [3:0] write_data,
    output logic [3:0] read_data
);
    logic [3:0] memory [0:15];
    integer index;

    initial begin
        for (index = 0; index < 16; index = index + 1) begin
            memory[index] = 4'h0;
        end
    end

    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory[address] <= write_data;
        end
    end

    // Asynchronous read keeps the teaching datapath easy to follow.
    assign read_data = memory[address];
endmodule