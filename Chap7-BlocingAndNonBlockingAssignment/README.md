# Blocking And Non-Blocking Assignment

----
## Blocking Assignment

The simulator executes a blocking assignment by evaluating the right-side expression, retainning its value, blocking further execution of the block until it update left-side variable
If assignment includes intra-assignment timing control, simulator updates the variables after the timming control exprires, the continues block execution
If assignment does not include intra-assignment timming control, simulator updates the variable immediately.

---

blocking assignment can lead to race conditions, when the same event triggers multiple procedure

Example
```
initial 
  begin 
    a = 0;
    b = 0;
  end

always @(posedge clock)
  a = a + 1;

always @(posedge clock)
  b = a;
```

* Both procedures execute on the positive clock edge.
* Blocking assignments to a and b finish immmediately upon the statement execution
* The value of b *depends* on which procedure executes first

Blocking assignment order affects functionality

```
always @(posedge clock)
  begin
    b = a;		// it assigns a to b and update immediately updates the b value
    c = b;		// it assigns b to c and update immediately updates the c value
    d = c;		// it assigns c to d and update immediately updates the d value // b and c are intermediate (temporary) variables
  end			// will become d  = c = b = a

// Each variable is written before it is read, all the variables have the value of a. The b & c will not exist in a hardware implementations


always @(posedge clock)
  begin
    
    d = c;		// it assigns c to d and update immediately updates the d value		    
    c = b;		// it assigns b to c and update immediately updates the c value
    b = a;		// it assigns a to b and update immediately updates the b value
  end	


// Each variable is read before is written, all variables can have different values. All vars exist in a hardware implemmentations.
```
For this illustration, the statement order would not affect functionality if the **assignments were nonblocking**

---
## Non-blocking assignment

The simulator execute the nonblocking assignment by evaluating the right-side expression, retaining its value, scheduling the update and continue execute the block until it encounter a blocking construct
The simulator schedules the variables ipdate for a point in the simulation where all currently active blocks have executed up the point where they are all blocked.
This ensure the any other active block reads the old value of variable, not the new variable

```
module seqnonblock(seq);
  output reg [2:0] seq;
  integer i;
  
  initial
    begin
      seq <= 3'b000;
      for (i=0; i<4; i=i+1)
        begin
          #10 seq <= seq + 1;
          if (seq == 3'b100)		// If the current value is 4, the reset value to 0
            seq <= 3'b000;
          end
   end
endmodule
```

|Time | Value |
|-----|-------|
| 00  |  000  |
| 10  |  001  |
| 20  |  010  |
| 30  |  011  |
| 40  |  100  |    // Here current value is 4
| 50  |  000  |    // Reset value to 0








