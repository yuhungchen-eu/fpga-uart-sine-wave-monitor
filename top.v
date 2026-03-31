module top (
    input  wire clk,
    output wire led,
    output wire uart_tx_o
);

    wire rst_n = 1'b1;

    // 27 MHz / 270000 = 100 samples/sec
    localparam integer SAMPLE_DIV = 19'd270000;

    reg [18:0] sample_div_cnt = 19'd0;
    wire sample_tick = (sample_div_cnt == SAMPLE_DIV - 1'b1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sample_div_cnt <= 19'd0;
        else if (sample_tick)
            sample_div_cnt <= 19'd0;
        else
            sample_div_cnt <= sample_div_cnt + 1'b1;
    end

    wire [11:0] signal;
    wire        flag;
    wire [11:0] peak;
    wire [15:0] count;

    waveform_gen u_gen (
        .clk(clk),
        .rst_n(rst_n),
        .step_en(sample_tick),
        .signal_out(signal)
    );

    monitor_core #(
        .THRESHOLD(12'd3200)
    ) u_mon (
        .clk(clk),
        .rst_n(rst_n),
        .signal_in(signal),
        .threshold_flag(flag),
        .peak_value(peak),
        .event_count(count)
    );

    // active-low LED
    assign led = ~flag;

    reg        tx_start = 1'b0;
    reg [7:0]  tx_data  = 8'd0;
    wire       tx_busy;

    uart_tx #(
        .CLK_FREQ(27000000),
        .BAUD_RATE(115200)
    ) u_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(uart_tx_o),
        .tx_busy(tx_busy)
    );

    function [7:0] hex_ascii;
        input [3:0] nibble;
        begin
            if (nibble < 4'd10)
                hex_ascii = 8'd48 + nibble;
            else
                hex_ascii = 8'd55 + nibble;
        end
    endfunction

    // send: ABC\r\n
    reg [7:0] msg [0:4];
    reg [2:0] state = 3'd0;
    reg [2:0] index = 3'd0;

    localparam S_IDLE      = 3'd0;
    localparam S_LOAD_MSG  = 3'd1;
    localparam S_START_TX  = 3'd2;
    localparam S_WAIT_BUSY = 3'd3;
    localparam S_WAIT_DONE = 3'd4;
    localparam S_NEXT_CHAR = 3'd5;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_start <= 1'b0;
            tx_data  <= 8'd0;
            state    <= S_IDLE;
            index    <= 3'd0;
        end else begin
            tx_start <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (sample_tick && !tx_busy)
                        state <= S_LOAD_MSG;
                end

                S_LOAD_MSG: begin
                    msg[0] <= hex_ascii(signal[11:8]);
                    msg[1] <= hex_ascii(signal[7:4]);
                    msg[2] <= hex_ascii(signal[3:0]);
                    msg[3] <= 8'h0D;
                    msg[4] <= 8'h0A;
                    index  <= 3'd0;
                    state  <= S_START_TX;
                end

                S_START_TX: begin
                    tx_data  <= msg[index];
                    tx_start <= 1'b1;
                    state    <= S_WAIT_BUSY;
                end

                S_WAIT_BUSY: begin
                    if (tx_busy)
                        state <= S_WAIT_DONE;
                end

                S_WAIT_DONE: begin
                    if (!tx_busy)
                        state <= S_NEXT_CHAR;
                end

                S_NEXT_CHAR: begin
                    if (index == 3'd4)
                        state <= S_IDLE;
                    else begin
                        index <= index + 1'b1;
                        state <= S_START_TX;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule