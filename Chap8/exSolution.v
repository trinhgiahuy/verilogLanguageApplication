// Method 1: Procedural assignment
always @*
  y = (add==1) ? a+b : c;

// Method 2: Continuous assignment
   assign y = (add=1) ? a+b : c;
   
