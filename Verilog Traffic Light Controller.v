//`timescale 1ns/1ps

module traffic_light_controller(clk,reset,Emergency_green,auto_mode_manual,yellow_manual,green_manual,vsw,fault,system_off,traffic_lights);

input clk;   //clock input

input reset;   //Reset input(Asynchronous)

input auto_mode_manual;  //mode select input (Automatic :1 ,manual :0)

input vsw;


//emergency signals

input[3:0] Emergency_green; //REFINEMENT


//manual mode input registers 


//input [6:0] red_manual;          

input [7:0] yellow_manual;   

input [7:0] green_manual;

//outputs

output reg fault;                    //Fault signal

output reg system_off;                //System Off signal

output reg [11:0] traffic_lights;     // D_001  RED,YELLOW,GREEN lights for 4 roads  

reg [3:0]ps,ns;  

reg power_off;

wire delibrately_off;                     //present and next states

wire east_green_comp_out , east_yellow_comp_out, north_green_comp_out , north_yellow_comp_out , west_green_comp_out , west_yellow_comp_out ,south_green_comp_out , south_yellow_comp_out;

wire clear;

wire [7:0] east_green_out,north_green_out,west_green_out,south_green_out,east_yellow_out,north_yellow_out,west_yellow_out,south_yellow_out;

reg [7:0] internal_green[0:3];

reg [7:0] internal_yellow[0:3];
 
//define states 

parameter GREEN=2'b00; 

parameter YELLOW=2'b01;

parameter RED=2'b10;


//define timing paramters 

parameter RED_DELAY=84;

parameter YELLOW_DELAY=4;	

parameter GREEN_DELAY=24;

parameter FREQUENCY=2;//000000;
 
//counter parameters

parameter counter_length = $clog2(FREQUENCY);

reg [7:0]count;

reg [counter_length:0] sub_counter;

integer sec_count;

integer int; 

parameter [3:0] east_green=  4'b0000;

parameter [3:0] east_yellow= 4'b0001;

parameter [3:0] north_green= 4'b0010;

parameter [3:0] north_yellow=4'b0011;

parameter [3:0] west_green=  4'b0100;

parameter [3:0] west_yellow= 4'b0101;

parameter [3:0] south_green= 4'b0110;

parameter [3:0] south_yellow=4'b0111;

parameter [3:0] all_red=     4'b1000;

parameter [3:0] all_yellow=  4'b1001;


always @(posedge clk or posedge reset)

begin

if (reset)

ps<=all_red;

else

ps<=ns;

end


always @( ps or vsw or east_green_comp_out or east_yellow_comp_out or north_green_comp_out or north_yellow_comp_out or west_green_comp_out or west_yellow_comp_out or south_green_comp_out or south_yellow_comp_out or Emergency_green )

begin

if (~vsw) ns<=all_yellow;
else begin

case(Emergency_green)

4'b0001: ns<=east_green;

4'b0010: ns<=north_green;

4'b0100: ns<=west_green;

4'b1000: ns<=south_green;

default: begin 

case(ps)
all_red: ns<=east_green;

all_yellow: ns<=east_green;

east_green : if(east_green_comp_out) begin  ns<=east_yellow;  end   else begin ns<= ps; end 

east_yellow: if(east_yellow_comp_out) begin  ns<=north_green;  end   else begin ns<= ps; end 

north_green: if(north_green_comp_out)begin  ns<=north_yellow; end   else begin ns<= ps; end 

north_yellow: if(north_yellow_comp_out)  begin  ns<=west_green;   end   else begin ns<= ps; end 

west_green : if(west_green_comp_out) begin  ns<=west_yellow;  end   else begin ns<= ps; end 

west_yellow : if(west_yellow_comp_out) begin  ns<=south_green;  end   else begin ns<= ps; end 

south_green: if(south_green_comp_out)begin  ns<=south_yellow; end   else begin ns<= ps; end 

south_yellow: if(south_yellow_comp_out)  begin  ns<=east_green;   end   else begin ns<= ps; end 


default : ns<=all_yellow;
endcase

end

endcase 

end

end

/*always @( ps or count )

begin
 
if (~vsw) clear =1;

else begin

case(ps)

east_green : if((count>east_green_out)||((count==east_green_out) && (sub_counter==(FREQUENCY-1))))     begin  clear =1;  end   else begin clear=0; end 

east_yellow: if((count>east_yellow_out)||((count==east_yellow_out) && (sub_counter==(FREQUENCY-1))))   begin  clear =1;  end   else begin clear=0; end 
 
north_green: if((count>north_green_out)||((count==north_green_out) && (sub_counter==(FREQUENCY-1))))    begin  clear =1; end   else begin clear=0; end 

north_yellow: if((count>north_yellow_out)||((count==north_yellow_out) && (sub_counter==(FREQUENCY-1)))) begin  clear =1;   end   else begin clear=0; end 

west_green : if((count>west_green_out)||((count==west_green_out) && (sub_counter==(FREQUENCY-1))))    begin  clear =1;  end   else begin clear=0; end 

west_yellow : if((count>west_yellow_out)||((count==west_yellow_out) && (sub_counter==(FREQUENCY-1)))) begin  clear =1;  end   else begin clear=0; end 

south_green: if((count>south_green_out)||((count==south_green_out) && (sub_counter==(FREQUENCY-1))))   begin  clear =1; end   else begin clear=0; end 

south_yellow: if((count>south_yellow_out)||((count==south_yellow_out) && (sub_counter==(FREQUENCY-1))))begin  clear =1;   end   else begin clear=0; end 

endcase

end
 
end*/
assign clear = (~vsw)? 1:((ps==east_green) && ((count>east_green_out)|| east_green_comp_out))? 1:
		((ps==east_yellow) && ((count>east_yellow_out)|| east_yellow_comp_out))? 1:
		((ps==north_green) && ((count>north_green_out)|| north_green_comp_out))? 1:
		((ps==north_yellow) && ((count>north_yellow_out)|| north_yellow_comp_out))? 1:
		((ps==west_green) && ((count>west_green_out)|| west_green_comp_out))? 1:
		((ps==west_yellow) && ((count>west_yellow_out)|| west_yellow_comp_out))? 1:
		((ps==south_green) && ((count>south_green_out)|| south_green_comp_out))? 1:
		((ps==south_yellow) && ((count>south_yellow_out)|| south_yellow_comp_out))? 1: 0;
		


always@(ps)

begin 

case(ps)

east_green:  traffic_lights  <= 12'b100100100001;

east_yellow: traffic_lights  <= 12'b100100001010;

north_green: traffic_lights  <= 12'b100100001100;

north_yellow:traffic_lights  <= 12'b100001010100;

west_green:  traffic_lights  <= 12'b100001100100;

west_yellow: traffic_lights  <= 12'b001010100100;

south_green :traffic_lights  <= 12'b001100100100;

south_yellow:traffic_lights  <= 12'b010100100001;

all_red:traffic_lights <=       12'b100100100100;

all_yellow:traffic_lights  <=   12'b010010010010;

default:traffic_lights <=12'b000000000000;

endcase

end


always @(posedge clk)

begin 

if(reset || clear ) begin

count<=0;

sub_counter <=0;

end

else if(sub_counter == (FREQUENCY-1)) begin

count<=count+1;

sub_counter<=0;

end

else begin 

sub_counter<=sub_counter+1;

end

end

/*always @(posedge clk)

begin

count<=count+1;

if(int==FREQUENCY)

else

begin

sec_count=sec_count+1;

count<=0;

end

end*/

always @(posedge clk or posedge reset) begin

if(reset) begin 

internal_green[0] <= GREEN_DELAY;

internal_green[1] <= GREEN_DELAY;

internal_green[2] <= GREEN_DELAY;

internal_green[3] <= GREEN_DELAY;

end else begin 

internal_green[0] <= green_manual - yellow_manual-1;

internal_green[1] <= green_manual - yellow_manual-1;

internal_green[2] <= green_manual - yellow_manual-1;

internal_green[3] <= green_manual - yellow_manual-1;

end 

end

always@(posedge clk or posedge reset)

begin

if(reset) begin 

internal_yellow[0]<=YELLOW_DELAY;

internal_yellow[1]<=YELLOW_DELAY;

internal_yellow[2]<=YELLOW_DELAY;

internal_yellow[3]<=YELLOW_DELAY;

end 

else begin 

internal_yellow[0]<=yellow_manual-1;

internal_yellow[1]<=yellow_manual-1;

internal_yellow[2]<=yellow_manual-1;

internal_yellow[3]<=yellow_manual-1;

end 

end


assign east_green_out=(auto_mode_manual)?  GREEN_DELAY: internal_green[0];

assign north_green_out=(auto_mode_manual)? GREEN_DELAY: internal_green[1];

assign west_green_out=(auto_mode_manual)?  GREEN_DELAY: internal_green[2];

assign south_green_out=(auto_mode_manual)? GREEN_DELAY: internal_green[3];

assign east_yellow_out=(auto_mode_manual)?  YELLOW_DELAY: internal_yellow[0];

assign north_yellow_out=(auto_mode_manual)? YELLOW_DELAY: internal_yellow[1];

assign west_yellow_out=(auto_mode_manual)?  YELLOW_DELAY: internal_yellow[2];

assign south_yellow_out=(auto_mode_manual)? YELLOW_DELAY: internal_yellow[3];


assign east_green_comp_out =  ((count==east_green_out) && (sub_counter==FREQUENCY-1)) ? 1:0;

assign north_green_comp_out = ((count==north_green_out) && (sub_counter==FREQUENCY-1)) ?1:0;

assign west_green_comp_out =  ((count==west_green_out) && (sub_counter==FREQUENCY-1))  ?1:0;

assign south_green_comp_out = ((count==south_green_out) && (sub_counter==FREQUENCY-1))? 1:0;

assign east_yellow_comp_out = ((count==east_yellow_out) && (sub_counter==FREQUENCY-1))?1:0;

assign north_yellow_comp_out= ((count==north_yellow_out) && (sub_counter==FREQUENCY-1))? 1:0;

assign west_yellow_comp_out = ((count==west_yellow_out) && (sub_counter==FREQUENCY-1))? 1:0;

assign south_yellow_comp_out =((count==south_yellow_out) && (sub_counter==FREQUENCY-1))? 1:0;

/*

always @(posedge clk or posedge reset) begin

if(reset) begin

clear<=0;

end else begin 

clear <= (east_green_comp_out)||(north_green_comp_out)||(west_green_comp_out)||(south_green_comp_out)||(east_yellow_comp_out)||(north_yellow_comp_out)||(west_yellow_comp_out)||(south_yellow_comp_out);

end 

end

*/


assign delibrately_off= ~vsw;

always @(posedge clk or posedge reset )

begin

if(reset)begin

system_off<=0;

fault<=0;

end

else begin

system_off <= delibrately_off;

fault <= (traffic_lights[0] && (traffic_lights[3] || traffic_lights[6] || traffic_lights[9]) || traffic_lights[3] && (traffic_lights[6] || traffic_lights[9]) || (traffic_lights[6] && traffic_lights[9]));

end

end

endmodule