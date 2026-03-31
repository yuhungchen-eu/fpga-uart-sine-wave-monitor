module waveform_gen (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       step_en,
    output reg [11:0] signal_out
);

    reg [5:0] phase_idx = 6'd0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase_idx <= 6'd0;
        else if (step_en)
            phase_idx <= phase_idx + 1'b1;
    end

    // 64-point sine LUT, unsigned 0..4095
    always @(*) begin
        case (phase_idx)
            6'd0:  signal_out = 12'd2048;
            6'd1:  signal_out = 12'd2248;
            6'd2:  signal_out = 12'd2447;
            6'd3:  signal_out = 12'd2642;
            6'd4:  signal_out = 12'd2831;
            6'd5:  signal_out = 12'd3013;
            6'd6:  signal_out = 12'd3185;
            6'd7:  signal_out = 12'd3345;
            6'd8:  signal_out = 12'd3495;
            6'd9:  signal_out = 12'd3629;
            6'd10: signal_out = 12'd3749;
            6'd11: signal_out = 12'd3851;
            6'd12: signal_out = 12'd3939;
            6'd13: signal_out = 12'd4007;
            6'd14: signal_out = 12'd4056;
            6'd15: signal_out = 12'd4085;
            6'd16: signal_out = 12'd4095;
            6'd17: signal_out = 12'd4085;
            6'd18: signal_out = 12'd4056;
            6'd19: signal_out = 12'd4007;
            6'd20: signal_out = 12'd3939;
            6'd21: signal_out = 12'd3851;
            6'd22: signal_out = 12'd3749;
            6'd23: signal_out = 12'd3629;
            6'd24: signal_out = 12'd3495;
            6'd25: signal_out = 12'd3345;
            6'd26: signal_out = 12'd3185;
            6'd27: signal_out = 12'd3013;
            6'd28: signal_out = 12'd2831;
            6'd29: signal_out = 12'd2642;
            6'd30: signal_out = 12'd2447;
            6'd31: signal_out = 12'd2248;
            6'd32: signal_out = 12'd2048;
            6'd33: signal_out = 12'd1848;
            6'd34: signal_out = 12'd1649;
            6'd35: signal_out = 12'd1454;
            6'd36: signal_out = 12'd1265;
            6'd37: signal_out = 12'd1083;
            6'd38: signal_out = 12'd911;
            6'd39: signal_out = 12'd751;
            6'd40: signal_out = 12'd601;
            6'd41: signal_out = 12'd467;
            6'd42: signal_out = 12'd347;
            6'd43: signal_out = 12'd245;
            6'd44: signal_out = 12'd157;
            6'd45: signal_out = 12'd89;
            6'd46: signal_out = 12'd40;
            6'd47: signal_out = 12'd11;
            6'd48: signal_out = 12'd0;
            6'd49: signal_out = 12'd11;
            6'd50: signal_out = 12'd40;
            6'd51: signal_out = 12'd89;
            6'd52: signal_out = 12'd157;
            6'd53: signal_out = 12'd245;
            6'd54: signal_out = 12'd347;
            6'd55: signal_out = 12'd467;
            6'd56: signal_out = 12'd601;
            6'd57: signal_out = 12'd751;
            6'd58: signal_out = 12'd911;
            6'd59: signal_out = 12'd1083;
            6'd60: signal_out = 12'd1265;
            6'd61: signal_out = 12'd1454;
            6'd62: signal_out = 12'd1649;
            6'd63: signal_out = 12'd1848;
            default: signal_out = 12'd2048;
        endcase
    end

endmodule