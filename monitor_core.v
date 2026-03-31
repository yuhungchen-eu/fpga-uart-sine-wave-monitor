module monitor_core #(
    parameter [11:0] THRESHOLD = 12'd3200
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [11:0] signal_in,
    output reg         threshold_flag,
    output reg [11:0]  peak_value,
    output reg [15:0]  event_count
);

    reg prev_flag;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            threshold_flag <= 1'b0;
            prev_flag      <= 1'b0;
            peak_value     <= 12'd0;
            event_count    <= 16'd0;
        end else begin
            threshold_flag <= (signal_in >= THRESHOLD);

            if (signal_in > peak_value)
                peak_value <= signal_in;

            if ((signal_in >= THRESHOLD) && !prev_flag)
                event_count <= event_count + 1'b1;

            prev_flag <= (signal_in >= THRESHOLD);
        end
    end

endmodule