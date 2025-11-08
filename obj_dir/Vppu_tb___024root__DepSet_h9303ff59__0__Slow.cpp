// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vppu_tb.h for the primary calling header

#include "Vppu_tb__pch.h"
#include "Vppu_tb__Syms.h"
#include "Vppu_tb___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vppu_tb___024root___dump_triggers__stl(Vppu_tb___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vppu_tb___024root___eval_triggers__stl(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_triggers__stl\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered.setBit(0U, (IData)(vlSelfRef.__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vppu_tb___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
