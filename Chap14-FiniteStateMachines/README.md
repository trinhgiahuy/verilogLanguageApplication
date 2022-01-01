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
---
## FSM : 1 Block
```
localparam IDLE = 2'd0, READ = 2'd1, 
	   WRITE = 2'd2, DONE = 2'd3;
reg[1:0] state;
reg exec, rd_wr;

always @(posedge clock)
 if (reset)
  state <= IDLE;
 else
  case (state)
   IDLE: begin
    exec <= 0;
    rd_wr <= do_write;
    state <= do_write ? WRITE : READ;
   end

   READ: if (!do_write)
    {state,exec} <= {DONE,1'b1};
   WRITE: if (do_write)
    {state,exec} <= {DONE,1'b1};
   DONE: state <= IDLE;
  endcase
```

## FSM: 2 Blocks
- Decode he next state in te seperate combinational block

```
localparam IDLE = 2'd0, READ = 2'd1, 
	   WRITE = 2'd2, DONE = 2'd3;
reg[1:0] state, nstate;
reg exec, rd_wr;

always @*
 case (state)
  IDLE: nstate = do_write ? WRITE : READ;
  READ: nstate = !do_write ? DONE : READ;
  WRITE: nstate = do_write ? DONE : WRITE;
  DONE: nstate = IDLE;
 endcase

always @(posedge clock)
 if (reset)
  state <= IDLE;
 else
  begin
  case (nstate)
   READ: {rd_wr,exec} <= 2'b00;
   WRITE: {rrd_wr,exec} <= 2'b10;
   DONE: exec <= 1;
  endcase
 end
```
## FSM: 3 Blocks
- Decode output in a third block. Here 3rd block is sequential

```
localparam IDLE = 2'd0, READ = 2'd1, 
	   WRITE = 2'd2, DONE = 2'd3;
reg[1:0] state, nstate;
reg exec, rd_wr;

always @*
 case (state)
  IDLE: nstate = do_write ? WRITE : READ;
  READ: nstate = !do_write ? DONE : READ;
  WRITE: nstate = do_write ? DONE : WRITE;
  DONE: nstate = IDLE;
 endcase

always @(posedge clock)
 if(reset)
  state <= IDLE;
 else
  state <= nstate;

always @(posedge clock)
 if(!reset)
  case(nstate)
   READ: {rd_wr,exec} <= 2'b00;
   WRITE: {rd_wr,exec} <= 2'b10;
   DONE: exec <= 1;
  endcase
```

## FSM: Combinational outputs
```
..

always @*
 case(state)
  IDLE: {rd_wr,exec} = 2'bxx;
  READ: {rd_wr,exec} = 2'b00;
  WRITE: {rd_wr,exec} = 2'b10;
  DONE: {rd_wr,exec} = 2'x1;
 endcase
```
## Optimizing Register Count
- Registering output is preferable for synthesis as it simplifies timing constraints.

State | Encoding | rd_wr  | exec    |
------|----------|--------|---------|
IDLE  | 01	 | ?	  | ?	    |
READ  | 00	 | 0	  | 0	    | 
WRITE | 10	 | 1      | 0       |
DONE  | 11	 | ? 	  | 1       |
match |		 |state[1]| state[0]|
```
localparam READ = 2'd0, IDLE = 2'd1,
	   WRITE = 2'd2, DONE = 2'd3;

reg[1:0] state, nstate


```








