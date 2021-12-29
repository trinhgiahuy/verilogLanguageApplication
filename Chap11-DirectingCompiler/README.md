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

` `timescale unit/precision`