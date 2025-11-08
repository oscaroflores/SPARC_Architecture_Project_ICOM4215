// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vppu_tb.h for the primary calling header

#include "Vppu_tb__pch.h"
#include "Vppu_tb___024root.h"

VL_ATTR_COLD void Vppu_tb___024root___eval_initial__TOP(Vppu_tb___024root* vlSelf);
VlCoroutine Vppu_tb___024root___eval_initial__TOP__Vtiming__0(Vppu_tb___024root* vlSelf);
VlCoroutine Vppu_tb___024root___eval_initial__TOP__Vtiming__1(Vppu_tb___024root* vlSelf);

void Vppu_tb___024root___eval_initial(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_initial\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vppu_tb___024root___eval_initial__TOP(vlSelf);
    Vppu_tb___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vppu_tb___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

void Vppu_tb___024root___eval_act(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_act\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vppu_tb___024root___nba_sequent__TOP__0(Vppu_tb___024root* vlSelf);

void Vppu_tb___024root___eval_nba(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_nba\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        Vppu_tb___024root___nba_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[1U] = 1U;
    }
}

VL_INLINE_OPT void Vppu_tb___024root___nba_sequent__TOP__0(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___nba_sequent__TOP__0\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (vlSelfRef.ppu_tb__DOT__reset) {
        vlSelfRef.ppu_tb__DOT__EX_ctrl = 0U;
        vlSelfRef.ppu_tb__DOT__MEM_ctrl = 0U;
        vlSelfRef.ppu_tb__DOT__instr_ID = 0U;
        vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual = 0U;
        vlSelfRef.ppu_tb__DOT__dut__DOT__npc_actual = 4U;
    } else {
        if (vlSelfRef.ppu_tb__DOT__S) {
            vlSelfRef.ppu_tb__DOT__EX_ctrl = 0U;
            vlSelfRef.ppu_tb__DOT__MEM_ctrl = 0U;
        } else {
            vlSelfRef.ppu_tb__DOT__EX_ctrl = vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP;
            vlSelfRef.ppu_tb__DOT__MEM_ctrl = vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size;
        }
        vlSelfRef.ppu_tb__DOT__instr_ID = (((vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory
                                             [(0x1ffU 
                                               & vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual)] 
                                             << 0x18U) 
                                            | (vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory
                                               [(0x1ffU 
                                                 & ((IData)(1U) 
                                                    + vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual))] 
                                               << 0x10U)) 
                                           | ((vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory
                                               [(0x1ffU 
                                                 & ((IData)(2U) 
                                                    + vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual))] 
                                               << 8U) 
                                              | vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory
                                              [(0x1ffU 
                                                & ((IData)(3U) 
                                                   + vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual))]));
        vlSelfRef.ppu_tb__DOT__dut__DOT__pc_actual 
            = vlSelfRef.ppu_tb__DOT__dut__DOT__npc_actual;
        vlSelfRef.ppu_tb__DOT__dut__DOT__npc_actual 
            = vlSelfRef.ppu_tb__DOT__dut__DOT__npc_next;
    }
    vlSelfRef.ppu_tb__DOT__WB_ctrl = ((~ (IData)(vlSelfRef.ppu_tb__DOT__reset)) 
                                      & ((~ (IData)(vlSelfRef.ppu_tb__DOT__S)) 
                                         & (IData)(vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE)));
    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 0U;
    vlSelfRef.ppu_tb__DOT__SOH_OP = 8U;
    vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 0U;
    vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 0U;
    vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Enable = 0U;
    vlSelfRef.ppu_tb__DOT__dut__DOT__L = 0U;
    vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE = 0U;
    vlSelfRef.ppu_tb__DOT__B = 0U;
    vlSelfRef.ppu_tb__DOT__CALL = 0U;
    if ((1U == (vlSelfRef.ppu_tb__DOT__instr_ID >> 0x1eU))) {
        vlSelfRef.ppu_tb__DOT__CALL = 1U;
    }
    vlSelfRef.ppu_tb__DOT__JMPL = 0U;
    if ((1U != (vlSelfRef.ppu_tb__DOT__instr_ID >> 0x1eU))) {
        if ((0U != (vlSelfRef.ppu_tb__DOT__instr_ID 
                    >> 0x1eU))) {
            if ((2U == (vlSelfRef.ppu_tb__DOT__instr_ID 
                        >> 0x1eU))) {
                if ((0x10U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                        >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 0U;
                } else if ((0x18U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 1U;
                } else if ((0x14U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 2U;
                } else if ((0x1cU == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 3U;
                } else if ((0x11U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 4U;
                } else if ((0x12U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 5U;
                } else if ((0x13U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 6U;
                } else if ((0x17U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 7U;
                } else if ((0x15U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 8U;
                } else if ((0x16U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 9U;
                } else if ((0x25U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 0xaU;
                } else if ((0x26U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 0xbU;
                } else if ((0x27U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                    vlSelfRef.ppu_tb__DOT__dut__DOT__ALU_OP = 0xcU;
                }
            }
            if ((2U != (vlSelfRef.ppu_tb__DOT__instr_ID 
                        >> 0x1eU))) {
                if ((3U == (vlSelfRef.ppu_tb__DOT__instr_ID 
                            >> 0x1eU))) {
                    if ((9U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                         >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__L = 1U;
                    } else if ((0xaU == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                  >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 1U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__L = 1U;
                    } else if ((0U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 2U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__L = 1U;
                    } else if ((1U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__L = 1U;
                    } else if ((2U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 1U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__L = 1U;
                    } else if ((3U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 3U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__L = 1U;
                    } else if ((5U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 1U;
                    } else if ((6U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 1U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 1U;
                    } else if ((4U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 2U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 1U;
                    } else if ((7U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 3U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 1U;
                    } else if ((0xdU == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                  >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 0U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 1U;
                    } else if ((0xfU == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                  >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Size = 2U;
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_RW = 1U;
                    }
                    if ((9U != (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                         >> 0x13U)))) {
                        if ((0xaU != (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                               >> 0x13U)))) {
                            if ((0U != (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                 >> 0x13U)))) {
                                if ((1U != (0x3fU & 
                                            (vlSelfRef.ppu_tb__DOT__instr_ID 
                                             >> 0x13U)))) {
                                    if ((2U != (0x3fU 
                                                & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                   >> 0x13U)))) {
                                        if ((3U != 
                                             (0x3fU 
                                              & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                 >> 0x13U)))) {
                                            if ((5U 
                                                 == 
                                                 (0x3fU 
                                                  & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                     >> 0x13U)))) {
                                                vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Enable = 1U;
                                            } else if (
                                                       (6U 
                                                        == 
                                                        (0x3fU 
                                                         & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                            >> 0x13U)))) {
                                                vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Enable = 1U;
                                            } else if (
                                                       (4U 
                                                        == 
                                                        (0x3fU 
                                                         & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                            >> 0x13U)))) {
                                                vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Enable = 1U;
                                            } else if (
                                                       (7U 
                                                        == 
                                                        (0x3fU 
                                                         & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                            >> 0x13U)))) {
                                                vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Enable = 1U;
                                            } else if (
                                                       (0xdU 
                                                        == 
                                                        (0x3fU 
                                                         & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                            >> 0x13U)))) {
                                                vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Enable = 1U;
                                            } else if (
                                                       (0xfU 
                                                        == 
                                                        (0x3fU 
                                                         & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                            >> 0x13U)))) {
                                                vlSelfRef.ppu_tb__DOT__dut__DOT__RAM_Enable = 1U;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if ((0U == (vlSelfRef.ppu_tb__DOT__instr_ID 
                    >> 0x1eU))) {
            if ((2U != (7U & (vlSelfRef.ppu_tb__DOT__instr_ID 
                              >> 0x16U)))) {
                if ((4U == (7U & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                  >> 0x16U)))) {
                    vlSelfRef.ppu_tb__DOT__SOH_OP = 0U;
                    vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE = 1U;
                }
            }
            if ((2U == (7U & (vlSelfRef.ppu_tb__DOT__instr_ID 
                              >> 0x16U)))) {
                vlSelfRef.ppu_tb__DOT__B = 1U;
                vlSelfRef.ppu_tb__DOT__JMPL = 1U;
            }
        } else {
            if ((2U == (vlSelfRef.ppu_tb__DOT__instr_ID 
                        >> 0x1eU))) {
                vlSelfRef.ppu_tb__DOT__SOH_OP = ((0x2000U 
                                                  & vlSelfRef.ppu_tb__DOT__instr_ID)
                                                  ? 0xfU
                                                  : 8U);
            } else if ((3U == (vlSelfRef.ppu_tb__DOT__instr_ID 
                               >> 0x1eU))) {
                vlSelfRef.ppu_tb__DOT__SOH_OP = ((0x2000U 
                                                  & vlSelfRef.ppu_tb__DOT__instr_ID)
                                                  ? 0xfU
                                                  : 8U);
            }
            if ((2U != (vlSelfRef.ppu_tb__DOT__instr_ID 
                        >> 0x1eU))) {
                if ((3U == (vlSelfRef.ppu_tb__DOT__instr_ID 
                            >> 0x1eU))) {
                    if ((9U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                         >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE = 1U;
                    } else if ((0xaU == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                  >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE = 1U;
                    } else if ((0U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE = 1U;
                    } else if ((1U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE = 1U;
                    } else if ((2U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE = 1U;
                    } else if ((3U == (0x3fU & (vlSelfRef.ppu_tb__DOT__instr_ID 
                                                >> 0x13U)))) {
                        vlSelfRef.ppu_tb__DOT__dut__DOT__RF_LE = 1U;
                    }
                }
            }
        }
    }
    vlSelfRef.ppu_tb__DOT__dut__DOT__npc_next = ((IData)(4U) 
                                                 + vlSelfRef.ppu_tb__DOT__dut__DOT__npc_actual);
}

void Vppu_tb___024root___timing_commit(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___timing_commit\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (1ULL & vlSelfRef.__VactTriggered.word(0U)))) {
        vlSelfRef.__VtrigSched_h9020d552__0.commit(
                                                   "@(posedge ppu_tb.clk)");
    }
}

void Vppu_tb___024root___timing_resume(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___timing_resume\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VtrigSched_h9020d552__0.resume(
                                                   "@(posedge ppu_tb.clk)");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vppu_tb___024root___eval_triggers__act(Vppu_tb___024root* vlSelf);

bool Vppu_tb___024root___eval_phase__act(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_phase__act\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<2> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vppu_tb___024root___eval_triggers__act(vlSelf);
    Vppu_tb___024root___timing_commit(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vppu_tb___024root___timing_resume(vlSelf);
        Vppu_tb___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vppu_tb___024root___eval_phase__nba(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_phase__nba\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vppu_tb___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vppu_tb___024root___dump_triggers__nba(Vppu_tb___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vppu_tb___024root___dump_triggers__act(Vppu_tb___024root* vlSelf);
#endif  // VL_DEBUG

void Vppu_tb___024root___eval(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY(((0x64U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vppu_tb___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("test/ppu_tb.v", 3, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY(((0x64U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vppu_tb___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("test/ppu_tb.v", 3, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vppu_tb___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vppu_tb___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vppu_tb___024root___eval_debug_assertions(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_debug_assertions\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
