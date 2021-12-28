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


| Functions               								   | Tasks					    			  	|
|------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
|Cannot have time-controlling, statement/delay, hence executes in same simulation time unit|Can contain, may only coplete at some other time			  |
|cannot enable a task									   |Can enable tasks and functions                  			  |
|Should have at least 1input, cannot have output/inout arguments			   |Can have zero or more arguments of any type     			  |
|Can return only a single value                                   			   |Can return a value, but can achieve same effect using output arguments|