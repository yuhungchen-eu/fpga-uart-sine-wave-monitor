module uart_tx #(
    parameter integer CLK_FREQ  = 27000000,
    parameter integer BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output reg        tx,
    output reg        tx_busy
);

    localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_cnt = 16'd0;
    reg [3:0]  bit_idx  = 4'd0;
    reg [9:0]  shifter  = 10'b1111111111;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx       <= 1'b1;
            tx_busy  <= 1'b0;
            baud_cnt <= 16'd0;
            bit_idx  <= 4'd0;
            shifter  <= 10'b1111111111;
        end else begin
            if (!tx_busy) begin
                tx       <= 1'b1;
                baud_cnt <= 16'd0;
                bit_idx  <= 4'd0;

                if (tx_start) begin
                    shifter <= {1'b1, tx_data, 1'b0};
                    tx_busy <= 1'b1;
                    tx      <= 1'b0;
                end
            end else begin
                if (baud_cnt == BAUD_DIV - 1'b1) begin
                    baud_cnt <= 16'd0;
                    bit_idx  <= bit_idx + 1'b1;
                    shifter  <= {1'b1, shifter[9:1]};
                    tx       <= shifter[1];

                    if (bit_idx == 4'd9) begin
                        tx_busy <= 1'b0;
                        tx      <= 1'b1;
                    end
                end else begin
                    baud_cnt <= baud_cnt + 1'b1;
                end
            end
        end
    end

endmodule
