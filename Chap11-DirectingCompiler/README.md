## Subtitute Text : The `define Directive

Define a text substitution macro
```
`define width 7
wire a,b,c;
reg [2:0] f;
reg ['width:0] mem [1:1024];

`define e {b,c,a};


always @(posedge clk)
 f <= `e; 		// Compiler replaces macro with its definition
```

## The `include directive

* Use include files to ensure that team-wide module descriptions use same declarations: constants, tasks and functions
* The included file contain another `include directive

globals.txt
```
// Clock and  simulator constants
// could also include tasks, etc.
localparam PERIOD = 10;
localparam POSEDGE_FIRST = 1;
localparam START_TIME = 2;
localparam NUMBER_CYCLES = 100;
```

```
// Include global variables
`include "globals.txt"
reg clk;
initial
 begin: CLKGEN
  clk = ~POSEDGE_FIRST;
  #START_TIME
  repeat(2*NUMBER_CYCLES)
   #(PERIOD/2) clk = ~clk;
  $display($time,,"Test Done");
  $finish;
end
```

## The `timescale directive

`timescale unit/precision, unit of *fs, ps, ns, us, ms, s*

* The simulator rounds time specifications to the precision of the module and scales.

* Timescale must appear outside of the module

* You can specify at as each command line option. The -timescale option, `irun -timescale 1ns/10ps`

---

## The `pragma directive.
- Provides a mean for implementations to extend the set of compiler directives, 
* The **reset** pragma resets the pragmas provided as pragma expressions
* The **resetall** pragma resets all pragmas
* the **protect** pragma encrypts subsequent source code.

```
module smux
#(paramter integer W=1)
(output [W-1:0] y, input s, 
 input  [W-1:0] a, b);
`pragma protect begin
assign y = s ? b : a;   		| area to protect
`pragma protect end 
endmodule
```
---

## Disable implicit net declaration
- You implicitly declare a net when you previously undeclared identifier in a port expression or terminal list or as the lvalue of continuous assignment. The net by default will becomes a **wire**
- You can set the value of `default_nettype directive **tri tri0 tri1 trianhd trio trireg wand wire wor none(from verilog 2001)**
- Set **`default_nettype none**, undeclared signal will become syntax error => Reduce potential for typographical error

Compiler Directives 	        	|													|
----------------------------------------|-------------------------------------------------------------------------------------------------------|
`celldefine    `endcelldefine   	| Tags a library cell											|
`default_nettype	        	| Set the net type for implicit net declaration								|
`define        `undef			| Define  and undefine a text macro									|
`ifdef  `else  `endif			| condiionally compile code depending upon text macro existence						|
`include				| Include a source file											|
`resetall				| Resets directives to their initial state								|
`timescale				| Set the time units and time precision									|
`unconnected_drive `nounconnected_drive | Pulls up/Pull down unconnected module inputs								|
`ifndef        `elsif			| Verilog-2001: more conditional compilation								|
`line					| Verilog-2001: Overrides reported source file and line upon error					|
`begin_ketwords  `end_keywords		| Verilog-2001: Reserves keywords for use as identifiers						|
`pragna					| Verilog-2005: Changes how compulter interprets subsequent source					| 