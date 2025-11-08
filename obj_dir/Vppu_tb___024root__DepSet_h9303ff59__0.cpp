// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vppu_tb.h for the primary calling header

#include "Vppu_tb__pch.h"
#include "Vppu_tb__Syms.h"
#include "Vppu_tb___024root.h"

VL_INLINE_OPT VlCoroutine Vppu_tb___024root___eval_initial__TOP__Vtiming__0(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlWide<3>/*95:0*/ __Vtemp_1;
    // Body
    __Vtemp_1[0U] = 0x2e766364U;
    __Vtemp_1[1U] = 0x755f7462U;
    __Vtemp_1[2U] = 0x7070U;
    vlSymsp->_vm_contextp__->dumpfile(VL_CVT_PACK_STR_NW(3, __Vtemp_1));
    vlSymsp->_traceDumpOpen();
    vlSelfRef.ppu_tb__DOT__clk = 0U;
    vlSelfRef.ppu_tb__DOT__reset = 1U;
    vlSelfRef.ppu_tb__DOT__S = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x2710ULL, 
                                         nullptr, "test/ppu_tb.v", 
                                         48);
    vlSelfRef.ppu_tb__DOT__reset = 0U;
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         52);
    vlSelfRef.ppu_tb__DOT__S = 1U;
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         56);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         56);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         56);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         56);
    co_await vlSelfRef.__VtrigSched_h9020d552__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge ppu_tb.clk)", 
                                                         "test/ppu_tb.v", 
                                                         56);
    vlSelfRef.ppu_tb__DOT__S = 0U;
    VL_WRITEF_NX("Simulation complete. PC=%10#, nPC=%10#\n",0,
                 32,vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual,
                 32,vlSelfRef.ppu_tb__DOT__dut__DOT__npc_actual);
    VL_FINISH_MT("test/ppu_tb.v", 60, "");
}

VL_INLINE_OPT VlCoroutine Vppu_tb___024root___eval_initial__TOP__Vtiming__1(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x1388ULL, 
                                             nullptr, 
                                             "test/ppu_tb.v", 
                                             37);
        vlSelfRef.ppu_tb__DOT__clk = (1U & (~ (IData)(vlSelfRef.ppu_tb__DOT__clk)));
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vppu_tb___024root___dump_triggers__act(Vppu_tb___024root* vlSelf);
#endif  // VL_DEBUG

void Vppu_tb___024root___eval_triggers__act(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_triggers__act\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered.setBit(0U, ((IData)(vlSelfRef.ppu_tb__DOT__clk) 
                                          & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__ppu_tb__DOT__clk__0))));
    vlSelfRef.__VactTriggered.setBit(1U, vlSelfRef.__VdlySched.awaitingCurrentTime());
    vlSelfRef.__Vtrigprevexpr___TOP__ppu_tb__DOT__clk__0 
        = vlSelfRef.ppu_tb__DOT__clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vppu_tb___024root___dump_triggers__act(vlSelf);
    }
#endif
}
