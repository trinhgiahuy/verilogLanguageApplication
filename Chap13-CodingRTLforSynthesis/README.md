## Modeling combinational Logic
Combination logic: Output is at all tims a combinational function solely of inputs
* As a net declaration
```
wire w =  expression;
```
* As a continuous assignment
```
wire w; assign w = expression;
```
* As an **always statement**
```
reg r; always @* r = expression;
```

The event list must not contain any **posedge or negedge** event

Assignment must be blocking, they are sufficient and simulate more efficiently

---

## Complete Event List
Do not include temporary variables - those written & then read in the same procedure & no where else

```
always @(a or b or c)
 begin: comb_blk
  reg temp;
  temp = a + b;
  q = temp + c;
 end
```

## Incomplete Assignment
If an execution path through a combinational procedure exist that does not update the value of some output, then that
output variable must retain its previous value => Synthesis tool infers a latch to implement this behavior

Example of incomplete assignment (both cases)
```
always @(a or b)
 if (b)
  y = a;

always @(a or b)
 case (b)
  1: y = a; 
 endcase

// How logic syn implement when b is 0 ?
```
---
## Modeling Sequential Logic
Outputs are sampled in registers on a clock edge, thus storage is required.

The event list must contain **only posedge and negedge events**.

To avoid clock/data races, make nonblocking assignments to storage variables.

For **non-temporary variables**, assign with nonblocking statements

```
//Sequential logic

always @(posedge clk)
 if (count == 9)
  count <= 4'd0;
 else
  count <= count + 4'd1;
```
---
## Reset Behavior
Use an **if..else** to add set/reset to a procedure.

For asynchronous resets, add active set/reset edge to event list

```
//Asynchronous reset
always @(posedge clk or posedge rst)
 if (rst)
  count <= 4'd0;
 else
  if (count == 9)
    count <= 4'd0;
  else
    count <= count + 4'd1;

//Synchronous reset
always @(posedge clk)
 ... [same as above]
```

**NOTE:** Incomplete assignment in a sequential procedure does not infer a latch 

With blocking assignments, the order of assignment is important

Write code to this block

a------|FF|---b----|FF|------c

```
//3: WORKS
always @(posedge clk)
 begin
  c = b;
  b = a;
 end

//4: BROKEN
always @(posedge clk)
 begin
  b = a;
  c = b;
 end

//Example3: reads var b before write => Synthesis infer 2 registers
//Example4: reads var b only after writting it => b is temp var => Synthesis infer 1 register
```
---
## Temporary variables in sequential procedures
# Persistent variable
- Read first & then written (in same procedure)
- Synthesis must infer a register to hodl value for next read

```
// 2 flop
always @(posedge clk)
  begin: dff2
    reg tmp;
    q <= tmp;
    tmp = d;
  end

d-----|FF|---tmp----|FF|-----q
```
# Temporary variable
- Write first & then read (in same procedure)
- Var is alias for expression so no reg is infered
```
//1 flop
always @(posedge clk)
 begin: dff1
  reg tmp;
  tmp = d;
  q <= tmp;
 end

d-----|FF|---q
```
## Modeling Latch Logic
- A comniational block that for some combination of inputs does not provide an output value inferes storage, i.e latch
- Make blocking assignments to only the temporary variables
- Make nonblocking assignments to the latch variable
```
always @(enb or rst or d)
 begin: latch
  reg tmp;
  tmp = d;
  if (rst)
   q <= 0;
  else
   if (enb)
    q <= tmp;
 end

d------|LL|-----q
enb---o|  |

```
## Modeling Three-State Logic
Synthesis infers three-state logic when you assign a net/var the high-impedance value (Z)

```
wire data_bus;
assign data_bus = enable ? data_1 : 8'bz;
assign data_bus = enable ? data_2 : 8'bz;
----------------------
reg data_bus;
always @*
 begin
  if (enable1)
   data_bus = data_1;
  else
   data_bus = 8'bz;
  if (enable2)
   data_bus = data_2;
  else
   data_bus = 8'bz;
 end
```
---
## Synthesis Attribute

```
(* name [=const_exp], {,name [=const_exp] } *)

(* synthesis, fsm_state = "gray" *)					// Standard Attribute
reg [2:0] state;

// acme synthesis state_vector -encoding gray				// Nonstandart Metacomment
always @(posede clk)
 ...
```
---
## Pragma full_case
Synthesis tool accept pragma to complete a **case** statement
```
module full (
 output reg a,b
 input [1:0] sel
);

always @*
 begin
 // a = 1'bx;
 // b = 1'bx;
 (* synthesis, full_case *)
 case (sel)
  2'b00: begin a = 1'b0; b = 1'b0; end
  2'b01: begin a = 1'b0; b = 1'b1; end
  2'b10: begin a = 1'b1; b = ... end
 // default begin a = 1'bx; b = 1'bx; end				// Equivalent to pragma 
 endcase
 end
endmodule
```
---
## Pragma parallel_case
```
module parallel (
 output reg a,b,
 input [1:0] sel
);

always @*
 begin
  a = 1'b0;
  b = 1'b0;
  (*synthesis, parallel_case *)
  casez (sel)
   2'b?1: a = 1'b1;
   2'b1?: b = 1'b1;
  endcase
 end
endmodule
```
Avoid usage of full_case and parallel_case directive with any Verilog case statement

## Pragma implementation

```
module adder (input [7:0] a,b, output [8:0] sum);
 assign sum = a + (*synthesis, implementation = "cla" *) + b;	// Recommend carry-lookahead for performance
endmodule

// Implementation attribute recommend an architecture for operator implementation.
// The syntheis tool can legally ignore recommendation
```



		

