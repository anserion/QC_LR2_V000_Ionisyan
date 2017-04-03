//Copyright 2017 Andrey S. Ionisyan (anserion@gmail.com)
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type
  { TForm1 }

  TForm1 = class(TForm)
    Button_exit: TButton;
    CheckGroupA: TCheckGroup;
    CheckGroup_apb_pow2: TCheckGroup;
    CheckGroup_apb_pow3: TCheckGroup;
    CheckGroup_C: TCheckGroup;
    CheckGroup_b7: TCheckGroup;
    CheckGroup_apb_pow3_minus_b7: TCheckGroup;
    CheckGroup_apb_pow3_minus_b7_plus_a: TCheckGroup;
    CheckGroup_D: TCheckGroup;
    CheckGroupB: TCheckGroup;
    CheckGroup_AplusB: TCheckGroup;
    Memo_help: TMemo;
    procedure Button_exitClick(Sender: TObject);
    procedure CheckGroupAItemClick(Sender: TObject; Index: LongInt);
    procedure CheckGroupBItemClick(Sender: TObject; Index: LongInt);
  private
    { private declarations }
  public
    { public declarations }
    procedure calc_formula;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

type
   tbit=record
      value:(zero,one);
      g_location:LongInt;
      gate_location:LongInt;
   end;
   tbit_vector=array of tbit;
   tbit_table=array of tbit_vector;
   tgarbage_item=record
      prev1,prev2,prev3,next1,next2,next3:LongInt;
      x1,x2,x3,y1,y2,y3:tbit;
   end;
   tgarbage=array of tgarbage_item;

var garbage: tgarbage; g_last_item:LongInt;
//=====================================================================
//This is a bad quantum gates emulation via truth tables:
//EQU gate,
//Pauli_X gate (NOT),
//SWAP gate,
//CNOT gate,
//Toffoli gate (CCNOT)
//Fredkin gate (CSWAP)
//=====================================================================
{equal gate}
procedure tt_EQU_gate(var x:tbit);
begin end;

{Pauli-X gate (NOT-gate)}
procedure tt_NOT_gate(var x:tbit);
var y:tbit;
begin
   if x.value=zero then y.value:=one;
   if x.value=one then y.value:=zero;
   x:=y;
end;

{SWAP gate}
procedure tt_SWAP_gate(var x1,x2:tbit);
var y1,y2:tbit;
begin
   if (x1.value=zero)and(x2.value=zero) then begin y1.value:=zero; y2.value:=zero; end;
   if (x1.value=zero)and(x2.value=one) then begin y1.value:=one; y2.value:=zero; end;
   if (x1.value=one)and(x2.value=zero) then begin y1.value:=zero; y2.value:=one; end;
   if (x1.value=one)and(x2.value=one) then begin y1.value:=one; y2.value:=one; end;
   x1:=y1; x2:=y2;
end;

{CNOT gate}
procedure tt_CNOT_gate(var x1,x2:tbit);
var y1,y2:tbit;
begin
   if (x1.value=zero)and(x2.value=zero) then begin y1.value:=zero; y2.value:=zero; end;
   if (x1.value=zero)and(x2.value=one) then begin y1.value:=zero; y2.value:=one; end;
   if (x1.value=one)and(x2.value=zero) then begin y1.value:=one; y2.value:=one; end;
   if (x1.value=one)and(x2.value=one) then begin y1.value:=one; y2.value:=zero; end;
   x1:=y1; x2:=y2;
end;

{Toffoli gate}
procedure tt_CCNOT_gate(var x1,x2,x3:tbit);
var y1,y2,y3:tbit;
begin
if (x1.value=zero)and(x2.value=zero)and(x3.value=zero) then begin y1.value:=zero; y2.value:=zero; y3.value:=zero; end;
if (x1.value=zero)and(x2.value=zero)and(x3.value=one) then begin y1.value:=zero; y2.value:=zero; y3.value:=one; end;
if (x1.value=zero)and(x2.value=one)and(x3.value=zero) then begin y1.value:=zero; y2.value:=one; y3.value:=zero; end;
if (x1.value=zero)and(x2.value=one)and(x3.value=one) then begin y1.value:=zero; y2.value:=one; y3.value:=one; end;
if (x1.value=one)and(x2.value=zero)and(x3.value=zero) then begin y1.value:=one; y2.value:=zero; y3.value:=zero; end;
if (x1.value=one)and(x2.value=zero)and(x3.value=one) then begin y1.value:=one; y2.value:=zero; y3.value:=one; end;
if (x1.value=one)and(x2.value=one)and(x3.value=zero) then begin y1.value:=one; y2.value:=one; y3.value:=one; end;
if (x1.value=one)and(x2.value=one)and(x3.value=one) then begin y1.value:=one; y2.value:=one; y3.value:=zero; end;
x1:=y1; x2:=y2; x3:=y3;
end;

{Fredkin gate}
procedure tt_CSWAP_gate(var x1,x2,x3:tbit);
var y1,y2,y3:tbit;
begin
if (x1.value=zero)and(x2.value=zero)and(x3.value=zero) then begin y1.value:=zero; y2.value:=zero; y3.value:=zero; end;
if (x1.value=zero)and(x2.value=zero)and(x3.value=one) then begin y1.value:=zero; y2.value:=zero; y3.value:=one; end;
if (x1.value=zero)and(x2.value=one)and(x3.value=zero) then begin y1.value:=zero; y2.value:=one; y3.value:=zero; end;
if (x1.value=zero)and(x2.value=one)and(x3.value=one) then begin y1.value:=zero; y2.value:=one; y3.value:=one; end;
if (x1.value=one)and(x2.value=zero)and(x3.value=zero) then begin y1.value:=one; y2.value:=zero; y3.value:=zero; end;
if (x1.value=one)and(x2.value=zero)and(x3.value=one) then begin y1.value:=one; y2.value:=one; y3.value:=zero; end;
if (x1.value=one)and(x2.value=one)and(x3.value=zero) then begin y1.value:=one; y2.value:=zero; y3.value:=one; end;
if (x1.value=one)and(x2.value=one)and(x3.value=one) then begin y1.value:=one; y2.value:=one; y3.value:=one; end;
x1:=y1; x2:=y2; x3:=y3;
end;

//=====================================================================
//basic binary logic
//toffoli (CCNOT) quantum gate used
//=====================================================================
procedure CCNOT_gate(x1,x2,x3:tbit; var y1,y2,y3:tbit);
begin
garbage[g_last_item].x1:=x1;
garbage[g_last_item].x2:=x2;
garbage[g_last_item].x3:=x3;

garbage[g_last_item].prev1:=x1.g_location;
garbage[g_last_item].prev2:=x2.g_location;
garbage[g_last_item].prev3:=x3.g_location;

if x1.gate_location=1 then garbage[x1.g_location].next1:=g_last_item;
if x1.gate_location=2 then garbage[x1.g_location].next2:=g_last_item;
if x1.gate_location=3 then garbage[x1.g_location].next3:=g_last_item;

if x2.gate_location=1 then garbage[x2.g_location].next1:=g_last_item;
if x2.gate_location=2 then garbage[x2.g_location].next2:=g_last_item;
if x2.gate_location=3 then garbage[x2.g_location].next3:=g_last_item;

if x3.gate_location=1 then garbage[x3.g_location].next1:=g_last_item;
if x3.gate_location=2 then garbage[x3.g_location].next2:=g_last_item;
if x3.gate_location=3 then garbage[x3.g_location].next3:=g_last_item;

tt_CCNOT_gate(x1,x2,x3);

y1.gate_location:=1;
y2.gate_location:=2;
y3.gate_location:=3;

y1.value:=x1.value;
y2.value:=x2.value;
y3.value:=x3.value;

y1.g_location:=g_last_item;
y2.g_location:=g_last_item;
y3.g_location:=g_last_item;

garbage[g_last_item].y1:=y1;
garbage[g_last_item].y2:=y2;
garbage[g_last_item].y3:=y3;

g_last_item:=g_last_item+1;
end;

function q_garbage(location:LongInt): tbit;
var q_garbage_tmp:tbit;
begin
q_garbage_tmp.value:=zero;
q_garbage_tmp.g_location:=location;
q_garbage_tmp.gate_location:=1;
q_garbage:=q_garbage_tmp;
end;

function q_zero:tbit;
var g1,g2,z1_bit,z2_bit,z3_bit,q_zero_tmp:tbit;
begin
g1:=q_garbage(0); g2:=q_garbage(0);
z1_bit.value:=zero; z1_bit.g_location:=0; z1_bit.gate_location:=1;
z2_bit.value:=zero; z2_bit.g_location:=0; z2_bit.gate_location:=2;
z3_bit.value:=zero; z3_bit.g_location:=0; z3_bit.gate_location:=3;
CCNOT_gate(z1_bit,z2_bit,z3_bit,q_zero_tmp,g1,g2);
q_zero:=q_zero_tmp;
end;

function q_one:tbit;
var g1,g2,one1_bit,one2_bit,one3_bit,q_one_tmp:tbit;
begin
g1:=q_garbage(1); g2:=q_garbage(1);
one1_bit.value:=one; one1_bit.g_location:=1; one1_bit.gate_location:=1;
one2_bit.value:=one; one2_bit.g_location:=1; one2_bit.gate_location:=2;
one3_bit.value:=one; one3_bit.g_location:=1; one3_bit.gate_location:=3;
CCNOT_gate(one1_bit,one2_bit,one3_bit,q_one_tmp,g1,g2);
q_one:=q_one_tmp;
end;

function q_not(op1:tbit):tbit;
var g1,g2,q_not_tmp:tbit;
begin
g1:=q_garbage(op1.g_location); g2:=q_garbage(op1.g_location);
CCNOT_gate(q_one,q_one,op1,g1,g2,q_not_tmp);
q_not:=q_not_tmp;
end;

function q_and(op1,op2:tbit):tbit;
var g1,g2,q_and_tmp:tbit;
begin
g1:=q_garbage(op1.g_location); g2:=q_garbage(op2.g_location);
CCNOT_gate(op1,op2,q_zero,g1,g2,q_and_tmp);
q_and:=q_and_tmp;
end;

function q_nand(op1,op2:tbit):tbit;
var g1,g2,q_nand_tmp:tbit;
begin
g1:=q_garbage(op1.g_location); g2:=q_garbage(op2.g_location);
CCNOT_gate(op1,op2,q_one,g1,g2,q_nand_tmp);
q_nand:=q_nand_tmp;
end;

function q_xor(op1,op2:tbit):tbit;
var g1,g2,q_xor_tmp:tbit;
begin
g1:=q_garbage(op1.g_location); g2:=q_garbage(op2.g_location);
CCNOT_gate(op1,q_one,op2,g1,g2,q_xor_tmp);
q_xor:=q_xor_tmp;
end;

function q_link(x:tbit):tbit;
var g1,g2,q_link_tmp:tbit;
begin
g1:=q_garbage(x.g_location); g2:=q_garbage(x.g_location);
CCNOT_gate(x,x,q_zero,q_link_tmp,g1,g2);
q_link:=q_link_tmp;
end;

procedure q_fanout(x:tbit; var y1,y2:tbit);
var g1:tbit;
begin
g1:=q_garbage(x.g_location);
CCNOT_gate(x,x,q_zero,y1,g1,y2);
end;

function q_or(op1,op2:tbit):tbit;
begin q_or:=q_nand(q_not(op1),q_not(op2)); end;

function q_nor(op1,op2:tbit):tbit;
begin q_nor:=q_and(q_not(op1),q_not(op2)); end;

function q_and3(x1,x2,x3:tbit):tbit;
begin q_and3:=q_and(q_and(x1,x2),x3); end;

function q_and4(x1,x2,x3,x4:tbit):tbit;
begin q_and4:=q_and(q_and(x1,x2),q_and(x3,x4)); end;

function q_nand3(x1,x2,x3:tbit):tbit;
begin q_nand3:=q_not(q_and3(x1,x2,x3)); end;

function q_nand4(x1,x2,x3,x4:tbit):tbit;
begin q_nand4:=q_not(q_and4(x1,x2,x3,x4)); end;

function q_or4(x1,x2,x3,x4:tbit):tbit;
begin q_or4:=q_or(q_or(x1,x2),q_or(x3,x4)); end;

function q_or8(x1,x2,x3,x4,x5,x6,x7,x8:tbit):tbit;
begin q_or8:=q_or(q_or4(x1,x2,x3,x4),q_or4(x5,x6,x7,x8)); end;

//=====================================================================
//second level binary logic:
//multiplexers, buffers, coders. decoders
//=====================================================================
{multiplexer's}
function mux_2x1(x0,x1,a0:tbit):tbit;
begin mux_2x1:=q_or(q_and(x0,q_not(a0)),q_and(x1,a0)); end;

function mux_4x1(x0,x1,x2,x3,a0,a1:tbit):tbit;
var not_a0,not_a1:tbit;
begin
    not_a0:=q_not(a0);
    not_a1:=q_not(a1);
    mux_4x1:=q_or4(q_and3(x0,not_a1,not_a0),
                   q_and3(x1,not_a1,a0),
                   q_and3(x2,a1,not_a0),
                   q_and3(x3,a1,a0));
end;

function mux_8x1(x0,x1,x2,x3,x4,x5,x6,x7,a0,a1,a2:tbit):tbit;
var not_a0,not_a1,not_a2:tbit;
begin
    not_a0:=q_not(a0);
    not_a1:=q_not(a1);
    not_a2:=q_not(a2);
    mux_8x1:=q_or8(q_and4(x0,not_a2,not_a1,not_a0),
                   q_and4(x1,not_a2,not_a1,a0),
                   q_and4(x2,not_a2,a1,not_a0),
                   q_and4(x3,not_a2,a1,a0),
                   q_and4(x4,a2,not_a1,not_a0),
                   q_and4(x5,a2,not_a1,a0),
                   q_and4(x6,a2,a1,not_a0),
                   q_and4(x7,a2,a1,a0));
end;

{buffers}
procedure BUF(x,en:tbit; var y:tbit);
begin y:=MUX_2x1(y,x,en); end;

procedure IBUF(x,en:tbit; var y:tbit);
begin y:=MUX_2x1(x,y,en); end;

{encoder's}
procedure CD_2x1(x0,x1:tbit; var y0:tbit);
begin y0:=q_link(x1); end;

procedure CD_4x2(x0,x1,x2,x3:tbit; var y0,y1:tbit);
begin
    y0:=q_or(x1,x3);
    y1:=q_or(x2,x3);
end;

procedure CD_8x3(x0,x1,x2,x3,x4,x5,x6,x7:tbit; var y0,y1,y2:tbit);
begin
    y0:=q_or4(x1,x3,x5,x7);
    y1:=q_or4(x2,x3,x6,x7);
    y2:=q_or4(x4,x5,x6,x7);
end;

{decoder's}
procedure DC_1x2(x0:tbit; var y0,y1:tbit);
begin
    y0:=q_not(x0);
    y1:=q_link(x0);
end;

procedure DC_2x4(x0,x1:tbit; var y0,y1,y2,y3:tbit);
var not_x0,not_x1:tbit;
begin
    not_x0:=q_not(x0);
    not_x1:=q_not(x1);
    y0:=q_and(not_x1,not_x0);
    y1:=q_and(not_x1,x0);
    y2:=q_and(x1,not_x0);
    y3:=q_and(x1,x0);
end;

procedure DC_3x8(x0,x1,x2:tbit; var y0,y1,y2,y3,y4,y5,y6,y7:tbit);
var not_x0,not_x1,not_x2:tbit;
begin
    not_x0:=q_not(x0);
    not_x1:=q_not(x1);
    not_x2:=q_not(x2);
    y0:=q_and3(not_x2,not_x1,not_x0);
    y1:=q_and3(not_x2,not_x1,x0);
    y2:=q_and3(not_x2,x1,not_x0);
    y3:=q_and3(not_x2,x1,x0);
    y4:=q_and3(x2,not_x1,not_x0);
    y5:=q_and3(x2,not_x1,x0);
    y6:=q_and3(x2,x1,not_x0);
    y7:=q_and3(x2,x1,x0);
end;

//=====================================================================
//binary arithmetic modules:
//bits cutter, bits setter
//half_adder,
//full_adder,
//n-bit adder,
//n-bit subtractor,
//n-bit multiplier,
//n-bit equal compare,
//n-bit compare for a greater,
//n-bit compare for a equ, greater, lower
//n-bit divider
//=====================================================================

//bits cutter
function bin_cut_bits(start_pos,end_pos:LongInt; var x:tbit_vector):tbit_vector;
var tmp:tbit_vector; i:LongInt;
begin
   setlength(tmp,end_pos-start_pos+1);
   for i:=start_pos to end_pos do tmp[i-start_pos]:=q_link(x[i]);
   bin_cut_bits:=tmp;
end;

//bits setter
procedure bin_ins_bits(start_pos,end_pos:LongInt; var src,dst:tbit_vector);
var i:LongInt;
begin for i:=start_pos to end_pos do dst[i]:=q_link(src[i-start_pos]); end;

procedure bin_set_bits(start_pos,end_pos:LongInt; value:tbit; var x:tbit_vector);
var i:LongInt;
begin for i:=start_pos to end_pos do x[i]:=q_link(value); end;

{half-adder}
procedure bin_half_adder(a,b:tbit; var s,c:tbit);
begin
    c:=q_and(a,b);
    s:=q_xor(a,b);
end;

{full-adder}
procedure bin_full_adder(a,b,c_in:tbit; var s,c_out:tbit);
var s1,s2,p1,p2:tbit;
begin
    bin_half_adder(a,b,s1,p1);
    bin_half_adder(s1,c_in,s2,p2);
    s:=q_link(s2);
    c_out:=q_or(p1,p2);
end;

{n-bit adder}
procedure bin_add(a,b:tbit_vector; var s:tbit_vector);
var i,n:LongInt; c:tbit_vector;
begin
n:=length(a); setlength(c,n+1);
c[0]:=q_link(q_zero);
for i:=0 to n-1 do bin_full_adder(a[i],b[i],c[i],s[i],c[i+1]);
setlength(c,0);
end;

{n-bit subtractor}
procedure bin_sub(a,b:tbit_vector; var s:tbit_vector);
var i,n:LongInt; c:tbit_vector;
begin
n:=length(a); setlength(c,n+1);
c[0]:=q_link(q_one);
for i:=0 to n-1 do bin_full_adder(a[i],q_not(b[i]),c[i],s[i],c[i+1]);
setlength(c,0);
end;

{n-bit multiplier}
procedure bin_mul(a,b:tbit_vector; var s:tbit_vector);
var i,n:LongInt;
    tmp_sum,tmp_op1:tbit_table;
begin
n:=length(a);
setlength(tmp_op1,n); for i:=0 to n-1 do setlength(tmp_op1[i],n);
setlength(tmp_sum,n+1); for i:=0 to n do setlength(tmp_sum[i],n+1);
for i:=0 to n-1 do tmp_sum[0,i]:=q_link(q_zero);
for i:=0 to n-1 do
begin
    if b[i].value=one then
    begin
       bin_set_bits(0,i-1,q_zero,tmp_op1[i]);
       bin_ins_bits(i,n-1,a,tmp_op1[i]);
    end
    else bin_set_bits(0,n-1,q_zero,tmp_op1[i]);
    bin_add(tmp_op1[i],tmp_sum[i],tmp_sum[i+1]);
end;
bin_ins_bits(0,n-1,tmp_sum[n],s);
for i:=0 to n-1 do setlength(tmp_op1[i],0); setlength(tmp_op1,0);
for i:=0 to n do setlength(tmp_sum[i],0); setlength(tmp_sum,0);
end;

{n-bit equal compare}
procedure bin_is_equal(a,b:tbit_vector; var res:tbit);
var res_tmp:tbit_vector; i,n:LongInt;
begin
   n:=length(a); setlength(res_tmp,n+1);
   res_tmp[0]:=q_link(q_zero);
   for i:=0 to n-1 do res_tmp[i+1]:=q_or(res_tmp[i],q_xor(a[i],b[i]));
   res:=q_not(res_tmp[n]);
   setlength(res_tmp,0);
end;

{n-bit greater compare. if a>b then res:=1}
procedure bin_is_greater_than(a,b:tbit_vector; var res:tbit);
var tmp_res,tmp_carry,tmp_cmp,tmp_equ:tbit_vector;
   i,n:LongInt;
begin
   n:=length(a);
   setlength(tmp_res,n+1); setlength(tmp_carry,n+1);
   setlength(tmp_cmp,n); setlength(tmp_equ,n);

   tmp_res[n]:=q_link(q_zero);
   tmp_carry[n]:=q_link(q_one);
   for i:=n-1 downto 0 do
   begin
      tmp_cmp[i]:=q_and(a[i],q_not(b[i]));
      tmp_equ[i]:=q_not(q_xor(a[i],b[i]));
      tmp_carry[i]:=q_and(tmp_carry[i+1],tmp_equ[i]);
      tmp_res[i]:=q_or(tmp_res[i+1],q_and(tmp_carry[i+1],tmp_cmp[i]));
   end;

   res:=q_link(tmp_res[0]);
   setlength(tmp_res,0); setlength(tmp_carry,0);
   setlength(tmp_cmp,0); setlength(tmp_equ,0);
end;

{n-bit compare for a equ, greater, lower
if a=b then res_equ=1
if a>b then res_greater=1
if a<b then res_lower=1
}
procedure bin_cmp(a,b:tbit_vector; var res_equ,res_greater,res_lower:tbit);
var tmp_res_g,tmp_res_l,tmp_res_e: tbit_vector;
    tmp_greater,tmp_lower,tmp_equ: tbit_vector;
    i,n:LongInt;
begin
   n:=length(a);
   setlength(tmp_res_g,n+1); setlength(tmp_res_l,n+1); setlength(tmp_res_e,n+1);
   setlength(tmp_greater,n); setlength(tmp_lower,n); setlength(tmp_equ,n);

   tmp_res_g[n]:=q_link(q_zero);
   tmp_res_l[n]:=q_link(q_zero);
   tmp_res_e[n]:=q_link(q_one);
   for i:=n-1 downto 0 do
   begin
      tmp_greater[i]:=q_and(a[i],q_not(b[i]));
      tmp_lower[i]:=q_and(q_not(a[i]),b[i]);
      tmp_equ[i]:=q_xor(q_not(a[i]),b[i]);
      tmp_res_e[i]:=q_and(tmp_res_e[i+1],tmp_equ[i]);
      tmp_res_g[i]:=q_or(tmp_res_g[i+1],q_and(tmp_res_e[i+1],tmp_greater[i]));
      tmp_res_l[i]:=q_or(tmp_res_l[i+1],q_and(tmp_res_e[i+1],tmp_lower[i]));
   end;

   res_greater:=q_link(tmp_res_g[0]);
   res_lower:=q_link(tmp_res_l[0]);
   res_equ:=q_link(tmp_res_e[0]);

   setlength(tmp_res_g,0); setlength(tmp_res_l,0); setlength(tmp_res_e,0);
   setlength(tmp_greater,0); setlength(tmp_lower,0); setlength(tmp_equ,0);
end;

{n-bit divider}
procedure bin_div(a,b:tbit_vector; var q,r:tbit_vector);
var tmp_q,tmp_equal,tmp_greater: tbit_vector;
   tmp_r,tmp_b: tbit_table;
   i,n:LongInt;
begin
   n:=length(a);
   setlength(tmp_q,n); setlength(tmp_equal,n); setlength(tmp_greater,n);
   setlength(tmp_r,n+1); setlength(tmp_b,n+1);
   for i:=0 to n do
   begin
      setlength(tmp_r[i],2*n-1);
      setlength(tmp_b[i],2*n-1);
   end;

   bin_set_bits(n,2*n-1,q_zero,tmp_r[0]);
   bin_ins_bits(0,n-1,a,tmp_r[0]);
   for i:=0 to n-1 do
   begin
     bin_is_greater_than(bin_cut_bits(n-i-1,n+n-i-2,tmp_r[i]),b,tmp_greater[n-i-1]);
     bin_is_equal(bin_cut_bits(n-i-1,n+n-i-2,tmp_r[i]),b,tmp_equal[n-i-1]);
     tmp_q[n-i-1]:=q_or(tmp_greater[n-i-1],tmp_equal[n-i-1]);
     bin_set_bits(n+n-i-1,n+n-1,q_zero,tmp_b[i]);
     bin_set_bits(0,n-i-2,q_zero,tmp_b[i]);
     if tmp_q[n-i-1].value=zero then bin_set_bits(n-i-1,n+n-i-2,q_zero,tmp_b[i])
                          else bin_ins_bits(n-i-1,n+n-i-2,b,tmp_b[i]);
     bin_sub(tmp_r[i],tmp_b[i],tmp_r[i+1]);
   end;

   q:=tmp_q;
   bin_ins_bits(0,n-1,tmp_r[n],r);
   setlength(tmp_q,0); setlength(tmp_equal,0); setlength(tmp_greater,0);
   for i:=0 to n do
   begin
      setlength(tmp_r[i],0);
      setlength(tmp_b[i],0);
   end;
   setlength(tmp_r,0); setlength(tmp_b,0);
end;

//======================================================================

{ TForm1 }

procedure TForm1.calc_formula;
var clk_num,sim_time,i,n,garbage_size:LongInt;
    GCLK:tbit;
   a,b,c,d:tbit_vector;
   a_plus_b,apb_pow2,apb_pow3,b7,apb_pow3_minus_b7,
   apb_pow3_minus_b7_plus_a,seven:tbit_vector;
begin
//garbage tuning
garbage_size:=65536*16;
setlength(garbage,garbage_size);
for i:=0 to garbage_size-1 do
begin
   garbage[i].prev1:=-1; garbage[i].prev2:=-1; garbage[i].prev3:=-1;
   garbage[i].next1:=-1; garbage[i].next2:=-1; garbage[i].next3:=-1;
end;
garbage[0].prev1:=0; garbage[0].prev2:=0; garbage[0].prev3:=0;
garbage[0].next1:=0; garbage[0].next2:=0; garbage[0].next3:=0;
garbage[0].x1.value:=zero; garbage[0].x2.value:=zero; garbage[0].x3.value:=zero;
garbage[0].y1.value:=zero; garbage[0].y2.value:=zero; garbage[0].y3.value:=zero;
garbage[1].prev1:=1; garbage[1].prev2:=1; garbage[1].prev3:=1;
garbage[1].next1:=1; garbage[1].next2:=1; garbage[1].next3:=1;
garbage[1].x1.value:=one; garbage[1].x2.value:=one; garbage[1].x3.value:=one;
garbage[1].y1.value:=one; garbage[1].y2.value:=one; garbage[1].y3.value:=one;
g_last_item:=2;

//input data tuning
n:=10; setlength(a,n); setlength(b,n); setlength(c,n); setlength(d,n);

//intermediate variables tuning
setlength(a_plus_b,n);
setlength(apb_pow2,n);
setlength(apb_pow3,n);
setlength(b7,n);
setlength(apb_pow3_minus_b7,n);
setlength(apb_pow3_minus_b7_plus_a,n);
setlength(seven,n);
seven[0]:=q_one; seven[1]:=q_one; seven[2]:=q_one;
for i:=3 to n-1 do seven[i]:=q_zero;

//let's go
GCLK:=q_zero;  clk_num:=0; sim_time:=2;

while clk_num<sim_time do
begin
//get input data
for i:=0 to n-1 do
begin
     if CheckGroupA.Checked[i] then a[i]:=q_one else a[i]:=q_zero;
     if CheckGroupB.Checked[i] then b[i]:=q_one else b[i]:=q_zero;
end;

//-----------------------------------------
//test formula:
// c = ((a+b)^3 - 7*b + a) div b,
// d = ((a+b)^3 - 7*b + a) mod b
//-----------------------------------------
//1) a_plus_b=a+b
bin_add(a,b,a_plus_b);
//report
for i:=0 to n-1 do
    if a_plus_b[i].value=one then CheckGroup_AplusB.Checked[i]:=true
                             else CheckGroup_AplusB.Checked[i]:=false;
//2) apb_pow2=a_plus_b*a_plus_b
bin_mul(a_plus_b,a_plus_b,apb_pow2);
//report
for i:=0 to n-1 do
    if apb_pow2[i].value=one then CheckGroup_apb_pow2.Checked[i]:=true
                             else CheckGroup_apb_pow2.Checked[i]:=false;
//3) apb_pow3=apb_pow2*a_plus_b
bin_mul(apb_pow2,a_plus_b,apb_pow3);
//report
for i:=0 to n-1 do
    if apb_pow3[i].value=one then CheckGroup_apb_pow3.Checked[i]:=true
                             else CheckGroup_apb_pow3.Checked[i]:=false;
//4) b7=b*7
bin_mul(b,seven,b7);
//report
for i:=0 to n-1 do
    if b7[i].value=one then CheckGroup_b7.Checked[i]:=true
                             else CheckGroup_b7.Checked[i]:=false;
//5) apb_pow3_minus_b7=apb_pow3-b7
bin_sub(apb_pow3,b7,apb_pow3_minus_b7);
//report
for i:=0 to n-1 do
    if apb_pow3_minus_b7[i].value=one then CheckGroup_apb_pow3_minus_b7.Checked[i]:=true
                             else CheckGroup_apb_pow3_minus_b7.Checked[i]:=false;
//6) apb_pow3_minus_b7_plus_a=apb_pow3_minus_b7+a
bin_add(apb_pow3_minus_b7,a,apb_pow3_minus_b7_plus_a);
//report
for i:=0 to n-1 do
    if apb_pow3_minus_b7_plus_a[i].value=one then CheckGroup_apb_pow3_minus_b7_plus_a.Checked[i]:=true
                             else CheckGroup_apb_pow3_minus_b7_plus_a.Checked[i]:=false;
//7) c=apb_pow3_minus_b7_plus_a div b; d=apb_pow3_minus_b7_plus_a mod b
bin_div(apb_pow3_minus_b7_plus_a,b,c,d);
//report
for i:=0 to n-1 do
begin
    if c[i].value=one then CheckGroup_c.Checked[i]:=true else CheckGroup_c.Checked[i]:=false;
    if d[i].value=one then CheckGroup_d.Checked[i]:=true else CheckGroup_d.Checked[i]:=false;
end;

GCLK:=q_not(GCLK); clk_num:=clk_num+1;
end;

//clear memory
setlength(a,0);
setlength(b,0);
setlength(c,0);
setlength(d,0);
setlength(a_plus_b,0);
setlength(apb_pow2,0);
setlength(apb_pow3,0);
setlength(b7,0);
setlength(apb_pow3_minus_b7,0);
setlength(apb_pow3_minus_b7_plus_a,0);
setlength(seven,0);
setlength(garbage,0);
end;

procedure TForm1.Button_exitClick(Sender: TObject);
begin
  close;
end;

procedure TForm1.CheckGroupAItemClick(Sender: TObject; Index: LongInt);
begin
  calc_formula;
end;

procedure TForm1.CheckGroupBItemClick(Sender: TObject; Index: LongInt);
begin
  calc_formula;
end;

end.

