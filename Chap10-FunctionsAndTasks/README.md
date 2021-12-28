## Verilog Subroutines Introduction

**Function subroutines**
* Have 1 or more inputs and return a single value
* Are invoked as an expression term

**Task subroutines**
* Have 0 or more inputs/outputs
* Are invoked as a procedural statement

---
## Declaring Functnions

- Function declared only within a module
- A function cannot contain any time-controlled statements like **#, @, wait, posedge, negedge**
- Function must have at least 1 input port, must not have output port & no inout ports
- Function cannot have ***non-blocking assignment*** or `force-release` or `assign-deassign`
- Function cannot have any triggers
- ?? Function can assign to a module variable, not to a module net
- With ***function port list***, you can specify the *integer, real,realtime, time or vector range*. A vector (by default) is unsigned. You can declare signed
```
function integer zcount;
 input [7:0] in_bus;
 integer i;
 begin
  zcount = 0;
  for (i = 0; i <= 7; i = i+7)
   if(!in_bus[i])
    zcount = zcount + 1;
 end 
endfunction

//Alternative syntax with port list
function [3:0] zcount
(input [7:0] in_bus);
 integer i;
 begin
  zcount = 0;
  for (i = 0; i <= 7; i = i+1)
   if(!in_bus[i])
    zcount = zcount + 1;
 end
endfunction
```
---
## Constant functions

* Cannot be placed within any generate scope
* Cannot contain hierachical references
* Ignore system task calls (except will execute $display in simulator but not elaborator)
* Cannot themselves make constant function calls in any context requiring constant expressions
* Can access only functions & module paramters & nothing else declared outside the function definition
* Module paramters must be previously assigned use of *defparam* can produce undefined result

```
paramter addw = 5;
paramter datw = 8;

reg [addw-1:0] address;
reg [datw-1:0] mem [1:memsize(addw)];

function integer memsize;
 input [15:0] width;
 begin
  case (width)
    ((width%2)==0): memsize = 1024;
    default:        memsize = 512;
  endcase
 end
endfunction
```
---
## Declaring Tasks

* Task is declared only within a module, tasks declared outside modules are **global tasks**, can be called within any module
* Can have any *input,output or inout* ports
* Can contain simulation time consuming elements such as ***@,posedge and others***
* can enable other tasks or functions



DIFFERENCE BTW FUNCTION AND TASK


| Functions               								   | Tasks					    			  |
|------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
|Cannot have time-controlling, statement/delay, hence executes in same simulation time unit|Can contain, may only coplete at some other time			  |
|cannot enable a task									   |Can enable tasks and functions                  			  |
|Should have at least 1input, cannot have output/inout arguments			   |Can have zero or more arguments of any type     			  |
|Can return only a single value                                   			   |Can return a value, but can achieve same effect using output arguments|


* If a task is made automatic, each invocation of the task is allocated to a different space in simulation memory and behave differently.

* Tasks can invoke the scheduler, which means task assignments can be blocking or nonblocking, task can delay their completion for any amount of time

* A task does not invoke the scheduler <=> can be rewrite as function

```
task zcount(output register count, input [7:0] in_bus);
 integer i;
  begin
   count = 0;
   for (i=0; i<=7; i=i+1)
    if(!in_bus[i])
     count = count + 1;
  end
endtask

^
|
v

function integer zcount(input [7:0] in_bus);
 integer i;
  begin
   count = 0;
   for (i=0; i<=7; i=i+1)
    if(!in_bus[i])     
endfunction

```
---
## Disable task or named block

```
module tb
 initial display();
 
 initial begin
 // After 50 time units, disable a particular named 
 // block T_DISPLAY inside the task called 'display'
 #50 disable display.T_DISPLAY
 
 task display();
  begin: T_DISPLAY
   $display("[%0t] T_TASK started", $time);
   #100;
   $display("[%0t] T_TASK ended", $time);
  end

  begin: S_DISPLAY
   #10;
   $display("[%0t] S_TASK started", $time);
   #20;
   $display("[%0t] S_TASK ended", $time);
  end
 endtask
endmodule
```
Simulation log

```
xcelium> run
[0] T_TASK started
[60] S_TASK stared
[80] S_TASKK ended
...
```
----------
## Arugments Are passed by value
- The simulator assigns expression value to input arguments upon invocation
- The simulator assigns output value to output argumeent variable upon return

```
task cpu_driver_bad;
 (input data_read,
 input [7:0] write_data,
 output data_valid,
 output [7:0] cpu_data);

 begin
  #40 data_valid = 1'b1;
  wait(data_read == 1'b1);		// Task hangs here
  #20 cpu_data = write_data;
  wait(data_read == 1'b0);
  #20 cpu_data = 8'hzz;
  data_valid = 1'b0;			// Assignment to data_valid is not made, this only be update at the
                                        // end of task, but task never complete, task_read is never updated
  end
endtask

...

cpu_driver_bad(8'hff, data_read, data_valid, cpu_data);

// PROBLEM: input arg data_read is sampled when task is called and used throughout the task execution.
// External changes in data_read are not seen within task during lifetime of task => Task hang at first wait statement
```
![](img/passByValue.png)

---
## Example of direct reference to module variables

```
task cpu_driver_good;
 input [7:0] write_data;

 begin
  #40 data_valid = 1'b1;
  wait(data_read == 1'b1);		
  #20 cpu_data = write_data;		// Here data_read,cpu_read,write_data are variables of declaring module
  wait(data_read == 1'b0);
  #20 cpu_data = 8'hzz;
  data_valid = 1'b0;			// Direct references to module variables from within a function or task are resolved to varibles within the                
  end					// DEFINING module's scope, not the CALLING module's scope
endtask

...

cpu_driver_good(8'hff);

// This modified task references the data_valid and data_read module variables instead of having their valu passed as argument
// Wait statement can detect transition of the data_read variable and task operate correctly.
```
![](img/driverGood.png)

---
## Subroutine can access module variable
```
module  mytasks();
 task clockit (input integer n);
  repeat(n) @(negedge busif_tb.clk);
 endtask

 task cpu_driver;
  input [7:0] write_data;
  begin
   #40 busif_tb.data_valid = 1'b1;
   wait(busif_tb.data_read == 1'b1);		
   #20 busif_tb.cpu_data = write_data;		// Upward reference. Using dot(.) hierachy operator
   wait(busif_tb.data_read == 1'b0);
   #20 busif_tb.cpu_data = 8'hzz;
   busif_tb.data_valid = 1'b0;
endmodule

module busif_tb;
 ...
 always #50 clk = ~clk;
 
 // instanitate tasks module
 mytask m1 ();
 
 initial
  begin: STIMULUS
   m1.clockit(5);
   wait(!interupt);
   m1.cpu_driver(8'h00);
   wait(!interupt);
   m1.cpu_driver(8'haa);			// Downward reference
   ...
endmodule
```
* Hierachical reference can be absolute, starting at top-level instance and tranversing downward path.
* Hierachical reference can be relative, starting at the scope of reference and tranversing downward path
* Hierachical reference can be upwardm but such reference can have only single instance or module name, which resolves to the nearest upward instance or module with that name


## CHAP SUMMARY
1. Which subroutines contain timming control ?
- Only tasks can
2. A call to which subroutines acn appear outside procedure ?
- Can use function as an expression, a function call can appear on the right side of a continuous assignment.
3. What is default type of subroutine port ?
- A subroutine port is by default a single-bit reg. You can declare it any variable type. Subroutines cannot declare nets.
4. Which method are subroutine arguements passed (value, pointer, reference) ?
- Subroutine arguments are passed by value.

