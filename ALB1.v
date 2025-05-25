module ALB (
    input             clk,
    input             resetb,
    input      [7:0]  R_in,
    input      [7:0]  S_in,
    input             CI_in,
    input      [1:0]  ALB_MI,
    output reg [7:0]  F,
    output            CO,
    output            ZO,
    output            NO,
    output            VO
);

    reg [7:0] R, S;
    reg       CI;

    always @(posedge clk or negedge resetb) begin
        if (!resetb) begin
            R <= 8'b0;
            S <= 8'b0;
            CI <= 1'b0;
        end else begin
            R <= R_in;
            S <= S_in;
            CI <= CI_in;
        end
    end

    wire [8:0] add_result  = {1'b0, R} + {1'b0, S} + CI;
    wire [8:0] sub_result  = {1'b0, R} + {1'b0, ~S} + CI;  // R - S - 1 + CI
    wire [7:0] and_result  = R & S;
    wire [7:0] or_result   = R | S;

    assign CO = (ALB_MI == 2'b00) ? sub_result[8] :
                (ALB_MI == 2'b10) ? add_result[8] : 1'b0;

    assign ZO = (F == 8'b00000000);
    assign NO = F[7];
    assign VO = (ALB_MI == 2'b10) ?
                ((R[7] == S[7]) && (F[7] != R[7])) :
                (ALB_MI == 2'b00) ?
                ((R[7] != S[7]) && (F[7] != R[7])) :
                1'b0;

    always @(*) begin
        case (ALB_MI)
            2'b00: F = sub_result[7:0];
            2'b01: F = and_result;
            2'b10: F = add_result[7:0];
            2'b11: F = or_result;
            default: F = 8'b00000000;
        endcase
    end

endmodule
