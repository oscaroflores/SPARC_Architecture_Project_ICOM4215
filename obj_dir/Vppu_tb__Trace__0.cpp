// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vppu_tb__Syms.h"


void Vppu_tb___024root__trace_chg_0_sub_0(Vppu_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vppu_tb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root__trace_chg_0\n"); );
    // Init
    Vppu_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vppu_tb___024root*>(voidSelf);
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vppu_tb___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vppu_tb___024root__trace_chg_0_sub_0(Vppu_tb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root__trace_chg_0_sub_0\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[1U]))) {
        bufp->chgIData(oldp+0,(vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual),32);
        bufp->chgIData(oldp+1,(vlSelfRef.ppu_tb__DOT__dut__DOT__npc_actual),32);
        bufp->chgIData(oldp+2,(vlSelfRef.ppu_tb__DOT__instr_ID),32);
        bufp->chgCData(oldp+3,(vlSelfRef.ppu_tb__DOT__EX_ctrl),4);
        bufp->chgCData(oldp+4,(vlSelfRef.ppu_tb__DOT__MEM_ctrl),2);
        bufp->chgBit(oldp+5,(vlSelfRef.ppu_tb__DOT__WB_ctrl));
        bufp->chgBit(oldp+6,(vlSelfRef.ppu_tb__DOT__CALL));
        bufp->chgBit(oldp+7,(vlSelfRef.ppu_tb__DOT__JMPL));
        bufp->chgBit(oldp+8,(vlSelfRef.ppu_tb__DOT__B));
        bufp->chgCData(oldp+9,(vlSelfRef.ppu_tb__DOT__SOH_OP),4);
        bufp->chgIData(oldp+10,(((IData)(4U) + vlSelfRef.ppu_tb__DOT__dut__DOT__npc_actual)),32);
        bufp->chgCData(oldp+11,(vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP),4);
        bufp->chgCData(oldp+12,(vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size),2);
        bufp->chgBit(oldp+13,(vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW));
        bufp->chgBit(oldp+14,(vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Enable));
        bufp->chgBit(oldp+15,(vlSelfRef.ppu_tb__DOT__dut__DOT__L));
        bufp->chgBit(oldp+16,(vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE));
        bufp->chgSData(oldp+17,((0x1ffU & vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual)),9);
    }
    bufp->chgBit(oldp+18,(vlSelfRef.ppu_tb__DOT__clk));
    bufp->chgBit(oldp+19,(vlSelfRef.ppu_tb__DOT__reset));
    bufp->chgBit(oldp+20,(vlSelfRef.ppu_tb__DOT__S));
    bufp->chgIData(oldp+21,((((vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory
                               [(0x1ffU & vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual)] 
                               << 0x18U) | (vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory
                                            [(0x1ffU 
                                              & ((IData)(1U) 
                                                 + vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual))] 
                                            << 0x10U)) 
                             | ((vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory
                                 [(0x1ffU & ((IData)(2U) 
                                             + vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual))] 
                                 << 8U) | vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory
                                [(0x1ffU & ((IData)(3U) 
                                            + vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual))]))),32);
    bufp->chgCData(oldp+22,(((IData)(vlSelfRef.ppu_tb__DOT__S)
                              ? 0U : (IData)(vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP))),4);
    bufp->chgCData(oldp+23,(((IData)(vlSelfRef.ppu_tb__DOT__S)
                              ? 0U : (IData)(vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size))),2);
    bufp->chgBit(oldp+24,(((~ (IData)(vlSelfRef.ppu_tb__DOT__S)) 
                           & (IData)(vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE))));
}

void Vppu_tb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root__trace_cleanup\n"); );
    // Init
    Vppu_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vppu_tb___024root*>(voidSelf);
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
}
