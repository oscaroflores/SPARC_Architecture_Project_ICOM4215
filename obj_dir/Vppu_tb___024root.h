// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vppu_tb.h for the primary calling header

#ifndef VERILATED_VPPU_TB___024ROOT_H_
#define VERILATED_VPPU_TB___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vppu_tb__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vppu_tb___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ ppu_tb__DOT__clk;
    CData/*0:0*/ ppu_tb__DOT__reset;
    CData/*0:0*/ ppu_tb__DOT__S;
    CData/*3:0*/ ppu_tb__DOT__EX_ctrl;
    CData/*1:0*/ ppu_tb__DOT__MEM_ctrl;
    CData/*0:0*/ ppu_tb__DOT__WB_ctrl;
    CData/*0:0*/ ppu_tb__DOT__CALL;
    CData/*0:0*/ ppu_tb__DOT__JMPL;
    CData/*0:0*/ ppu_tb__DOT__B;
    CData/*3:0*/ ppu_tb__DOT__SOH_OP;
    CData/*3:0*/ ppu_tb__DOT__dut__DOT__ALU_OP;
    CData/*1:0*/ ppu_tb__DOT__dut__DOT__RAM_Size;
    CData/*0:0*/ ppu_tb__DOT__dut__DOT__RAM_RW;
    CData/*0:0*/ ppu_tb__DOT__dut__DOT__RAM_Enable;
    CData/*0:0*/ ppu_tb__DOT__dut__DOT__L;
    CData/*0:0*/ ppu_tb__DOT__dut__DOT__RF_LE;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__ppu_tb__DOT__clk__0;
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ ppu_tb__DOT__instr_ID;
    IData/*31:0*/ ppu_tb__DOT__dut__DOT__pc_actual;
    IData/*31:0*/ ppu_tb__DOT__dut__DOT__npc_actual;
    IData/*31:0*/ ppu_tb__DOT__dut__DOT__npc_next;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<CData/*7:0*/, 512> ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory;
    VlUnpacked<CData/*0:0*/, 2> __Vm_traceActivity;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h9020d552__0;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<2> __VactTriggered;
    VlTriggerVec<2> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vppu_tb__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vppu_tb___024root(Vppu_tb__Syms* symsp, const char* v__name);
    ~Vppu_tb___024root();
    VL_UNCOPYABLE(Vppu_tb___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
