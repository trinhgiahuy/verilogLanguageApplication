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

**Conditional Operator Review** : can be replace a simple combinational procedure with a continuous assignment. Target must be net. Event control is assumed
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


**Remember:** continous assignment to nets and procedure assignment to variables. The net can be a vector or scalar, indexed part select, constant bit or part select of a vector.
Concatenation is also support with scallar

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

**Combination Feedback Loop** - **BE CAREFUL**

Zero-delay feedback loops may cause simulator to apprear to "lock up". The process never finish or suspends, The simulator never gets to do anything else.

```
* Short feedback loop deliberately generate a clock

always @* 
  clk_out = #5 !(clk_in && enable)

* A continuous assignment is its own process. Whenever clk_out changes, the value is update continuously
  assign #5 clk_in = clk_out;
```
---

### Generate 


