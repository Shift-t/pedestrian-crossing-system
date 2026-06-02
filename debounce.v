`timescale 1ns / 1ps
module debounce(clock,noisyclk,cleanclk);
        parameter delay=500000;
  input clock,noisyclk;
  output cleanclk;

  reg  [19:0] count;
  reg new,cleanclk;

  always @(posedge clock)
          if (noisyclk!= new)
        begin
        new <= noisyclk;
        count <=0;
        end

        else if (count==delay)
        cleanclk <=        new;
        else
        count<= count+1;
endmodule
