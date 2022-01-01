## FSM structure
- **State register**: Store current state
- **Next state decode logic**: Decide next state based on current state (and input if Mealy)
- **Output logic**: Decode state (of states & input) to produce output
---
## Defining the FSM state
- See FSM description to define state vector value with text replacement macros

## MACROS
```
`define IDLE 2'd0
`define READ 2'd1
`define WRITE 2'd2
`define DONE 2'd3	
reg [1:0] state, nstate;

always @*
 case (state)
  `IDLE: nstate = do_write ? `WRITE : `READ;
 ...

//Scope is global-accross files and module from `define to `undef`
//Accepted by synthesis tools but not for FSM optimization 
```

## PARAMTERS
```
localparam IDLE = 2'd0,
	   READ =  2'd1,
	   WRITE = 2'd2,
	   DONE = 2'd3;
reg [1:0] state, nstate;

always @*
 case (state)
  IDLE: nstate = do_write ? WRITE : READ;
 ...

//Scope is local to declaring block
//Required by synthesis tools that perform FSM optimization
```

