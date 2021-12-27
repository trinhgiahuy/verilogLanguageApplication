/*
always @(a or b or c or posedge clk or sel)
  begin
	if(sel == 1)
		tmp_and = c;
		tmp_op = c;
	else
		tmp_and = b;
		tmp_op = d;
	
	d  <=  a and tmp_a;
	op <= tmp_op;
	
  end
 */
 
always @(posedge clk)
	tmp_and <= sel ? c : b;

always @(posedge clk)
	tmp_op <= sel ? c : a & tmp_and;

