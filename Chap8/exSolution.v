// Method 1:
always @*
  y = (add==1) ? a+b : c;

// Method 2:
   assign y = (add=1) ? a+b : c;
   
