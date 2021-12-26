## Using Continuous and Procedural Assignment

Continuous Assignment Review 

- Only outside procedural block
- Continously drive nets
- Order of declaration does not affect the functionalities.

The simulator updates the continous assignments in any simulation cycle in which their inputs transition. 

```
wire [8:0] sum;
assign sum = a + b;		|can declare in either order
assign sum = c + d; 		|sum is result of a+b and c+d
```

For multiple continous assignment, the **wire**, **wand** and **wor** will resolve value conflict differently, as below

```
wire

|   | 0  | 1  | Z  | X  |
|---|----|----|----|----|
| 0 | 0  | X  | 0  | X  |
| 1 | X  | 1  | 1  | X  |
| Z | 0  | 1  | Z  | X  |
| X | X  | X  | X  | X  |

wand

|   | 0  | 1  | Z  | X  |
|---|----|----|----|----|
| 0 | 0  | 0  | 0  | 0  |
| 1 | 0  | 1  | 1  | X  |
| Z | 0  | 1  | Z  | X  |
| X | 0  | X  | X  | X  |

wor

|   | 0  | 1  | Z  | X  |
|---|----|----|----|----|
| 0 | 0  | 1  | 0  | X  |
| 1 | 1  | 1  | 1  | 1  |
| Z | 0  | 1  | Z  | X  |
| X | X  | 1  | X  | X  |

```

procedure blocks start with **always** or **initial**. It reacts to input transition and generates output transition
Statement within a sequential block (begin-end) execiute sequentially

For multiple procedural assignments within a sequential block, execute sequentially, subsequent assignment override the previous assignments

```
reg [8:0] sum
...
always @*
  begin
     sum = a + b;	|
     sum = c + d;	| sum will be c+d
```

Another ex, these 2 code fragments are equivalent

```
always @(a or b or sel)
  begin
    if (sel)
      y = b;
     else
      y = a;
    end
---
always @(a or b or sel)
  begin
    y = a;
    if (sel)
      y = b;
    end

```

## Conditional Operator Review 

can be replace a simple combinational procedure with a continuous assignment. Target must be net. Event control is assumed
```
module procedural_if(
  input  [3:0]  a,b,c,
  input  [2:0]  sel,
  output reg y
);

always @(a or b or c or sel)
  if (sel == 3'b000)
    y = a;
  else if (sel <= 3'b000)
    y = b;
  else
    y = c;
endmodule

---

module continuous_if(
  input [3:0]  a,b,c,
  input [2:0]  sel,
  output y
);

assign y = (sel == 3'b000) ? a :
    	   (sel <= 3b'000) ? b :
           c;
endmodule
```


## Remember:
* Continous assignment to nets, using **assign** and only outside procedure block.The net can be a vector or scalar, indexed part select, constant bit or part select of a vector.
Concatenation is also support with scallar.
* Multiple continous assignment to net: Verilog resolves the value of multiple drivers of a net
* Procedure assignment to variables, using **=** and only inside procedure block. 
* Multiple procedure assignment to variable: The last procedural assignment to variable "wins"


```
module Conti_Assignment (addr1,addr2,wr,din,valid1,valid2,dout);
  input [31:0] addr1,addr2;
  input [31:0] din;
  output [31:0] dout;
  input valid1,valid2,wr;
  
  wire valid;
  wire [31:0] addr;
  
  //Net (scalar) continuous assignment
  assign valid = valid1 | valid2;
  
  //Vector continuous assignment
  assign addr[31:0] = addr1[31:0] ^ addr2[31:0];
  
  //Part select & Concatenation in Continuous assignment
  assign dout[31:0] = (valid & wr) ? {din[31:2],2'b11} : 32'd0;
  
endmodule
```
---
**Regular & Implicit Assignment**

- Regular continious assignment, declaration of a net and its continuous assignment are done in 2 different statements.
- Implicit assignment, continuous assignment can be done on a net when it is declared itself. 

```
module Implicit_Conti_Assignment (addr1,addr2,wr,din,valid1,valid2,dout);
  input [31:0] addr1,addr2;
  input [31:0] din;
  output [31:0] dout;
  input valid1,valid2,wr;
  
  
  //Net (scalar) Implict continuous assignment
  wire valid = (valid1 | valid2);
  
  //Implicit net declaration -dout 
  assign dout[31:0] = (valid & wr) ? {din[31:2],2'b11} : 32'd0;
  
endmodule
```
### Procedural Assignment

- The procedural assignmet update value of reg, real, integer or time variable. The constant part select, indexed part select and bit select are possbible for vector reg.

2 types of procedural assignments called blocking and non-blocking. 

- Blocking assignment (" = ")gets executed in order statements are specified. Non-blocking (" <= ") allows scheduling of assignments. It will not block the execution.
-

[Example of blocking and non-blocking here]

---

## Combination Feedback Loop - **BE CAREFUL**

Zero-delay feedback loops may cause simulator to apprear to "lock up". The process never finish or suspends, The simulator never gets to do anything else.

```
* Short feedback loop deliberately generate a clock

always @* 
  clk_out = #5 !(clk_in && enable)

* A continuous assignment is its own process. Whenever clk_out changes, the value is update continuously
  assign #5 clk_in = clk_out;
```
---

## Generate 

### Conditional if generation

* instances, functions, tasks, variables, and procedural blocks
* label not required to create generate-if scope
```
module multiplier(a,b,product);
  parameter a_width = 8, b_width = 8;
  localparam product_width = a_width + b_width;  		--cannot be modified directly with the defparam statement or the module instance statement #
  input [a_width-1:0] a;
  input [b_width-1:0] b;
  output [product_width-1:0] product;

    generate
      if ((a_width < 8) || (b_width < 8)) begin : mult
	 CLA_multiplier #(a_width,b_width) u1(a,b,product);
	 // Instantiate a CLA multiplier
      end 
      else begin: mult
	 WALLACE_multiplier #(a_width,b_width) u1(a,b,product);  --the hierarchincal instance name is mult.u1
      end
   endgenerate
endmodule
```

### Conditional case generation

* instances, functions, tasks, variables, and procedural blocks
* label not required to create generate-case scope
```
generate
  case (WIDTH)
    1: begin: adder // 1-bit adder implementation
         adder_1bit x1(co,sum,a,b,ci);
       end
    2: begin : adder //2-bit adder implementation
         adder_2bit x1(co,sum,a,b,ci);
       end
    default:
       begin: adder // other - CLA
         adder_cla #(WIDTH) x1(co,sum,a,b,ci);
       end
  endcase
endgenerate
```

### Iterative generation

* instances variables, and procedural blocks (**no function task**)
* label is required to create generate-for scope

A paramterized gray-code-to-binary-code converter module using a loop to generate continuous assignment
```
module gray2bin1(bin, gray);
  paramter SIZE = 8; // this module is paramterizable
  output [SIZE-1:0] bin;
  input [SIZE-1:0] gray;

  genvar i;
  generate
    for (i=0; i <SIZE; i=i+1) begin: bitnum  //require label for scoping name
      assign bin[i] = ^gray[SIZE-1:i];  // i refer to the implicitly defined localparam whose value in each instance of the generate block is the value of the genvar when it was elaborated.
    end
  endgenerate
endmodule
```


