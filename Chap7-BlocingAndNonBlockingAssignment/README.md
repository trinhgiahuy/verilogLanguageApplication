# Blocking And Non-Blocking Assignment

----
## Blocking Assignment

The simulator executes a blocking assignment by evaluating the right-side expression, retainning its value, blocking further execution of the block until it update left-side variable
If assignment includes intra-assignment timing control, simulator updates the variables after the timming control exprires, the continues block execution
If assignment does not include intra-assignment timming control, simulator updates the variable immediately.

```
module seqblocking(seq);
  output reg [2:0] seq;
  integer i;
  
  initial
    begin
      seq = 3'b000;
      for (i=0; i<= 4; i=i+1)
        begin
          #10 seq = seq + 1;
          if (seq == 3'b100)		// If the current value is 4, the reset value to 0
            seq = 3'b000;
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
| 40  |  000  |    // Here current value is 4 **Reset value to 0**
| 50  |  001  |    


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
* The value of b **depends** on which procedure executes first

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
      for (i=0; i<= 4; i=i+1)
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

----
## Use non-blocking assignment in sequential procedure

Non-blocking assignments avoid race conditions, here 

Example
```
initial 
  begin 
    a = 0;
    b = 0;
  end

always @(posedge clock)
  a <= a + 1;

always @(posedge clock)
  b <= a;

```
* If the simulator first execute the upper block, it schedules an `a` var update to get the incremented and the a var does not yet change. 
The simulator execute the lower block where it schedules a `b` var update to get the old unchange a var value

* If the simulator first execute the lower block, it schedules a `b` var update to get the not yet changed a var value. 
The simulator then execute the upper block where it schedules an `a` var update to get the incremented value.

* After executing these, all other triggered blocks to the point where they block, the simulator completes the nonblocking assignment to update the var value

**The final `b` value does not depend upon the procedure execution order**

**The non-blocking assignment does not affect the order of execution**

---

## Making assignment to temporary variables
you can use blocking assignment to intermediate/temporary variables within sequential procedures
* Declare temp vars locallly to discorage their use of outside
* Assign inputs to temp var with blocking assignment
* Perform algorithm with temp vars and blocking assignment
* Assign tmp vars to output with nonblocking assignment

**DO NOT MIX BLOCKING AND NONBLOCKING ASSIGNMENT TO SAME VARS**

```
always @(posedge clk)
  begin: BLK
    integer tmp;
    tmp = a+b;
    q <= tmp;
  end

always @(posedge clk)
  begin: BLK
    integer tempa, tempb;
    tempa = in_p;
    ...
    tempb = f(tempa);
    ...
    out_p <= tempb;
  end
```

## Multiple assignmetns and assignment type
* All assignments should be the same type
* Subsequent assignments override the previous assignment

Example of 2 cases

```
always@ (a,b,c)
  begin
    m = a;
    n = b;  // m and n are temp vars
    p = m + n;
    m = c;
    q = m + n;
  end

c---			c--
    \			   \
     +--p		    +--q	         
b---/			b--/

// For blocking assignment, simulator
// Immediately updates the assignment a to m & calculate new value for p
// Immediately updates the assignment c to m & calculate new value for q

always@ (a,b,c)
  begin
    m <= a;
    n <= b;  // m and n are **not** temp vars
    p <= m + n;
    m <= c;
    q <= m + n;
  end


a---			c--
    \			   \
     +--p		    +--q	         
b---/			b--/

// For nonblocking assignment, simulator
// Schedules the assignment of a to m and immidiately replaces it with a **SCHEDULED** assignment of c to m.
// Upon updating the m var it gets the value of c not a, The simulator reexecute the procedure block due to transition of m&n,
// Calculate new val of p & q that use c value of m
```
