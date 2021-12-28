/*---My sol
task increaseBus; 
 input [31:0] abus;
 integer sel;
 sel <= 1;
 always @(posedge clk )
  begin
  for (sel = 0; sel < 4; sel = sel + 1)
   abus <= abus + 1;
  end
  sel <= 0;
endtask
*/
task increaseBus; 
 input [31:0] addr;
 integer sel;
 begin @(posedge clk )
  sel <= 1;
  abus <= addr;
  repeat(3) @(posedge clk)
   abus <= abus + 1;
  sel <= 0;
 end
endtask