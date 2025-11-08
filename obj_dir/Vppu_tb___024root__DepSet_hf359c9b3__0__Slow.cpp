// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vppu_tb.h for the primary calling header

#include "Vppu_tb__pch.h"
#include "Vppu_tb___024root.h"

VL_ATTR_COLD void Vppu_tb___024root___eval_static(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_static\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__ppu_tb__DOT__clk__0 
        = vlSelfRef.ppu_tb__DOT__clk;
}

VL_ATTR_COLD void Vppu_tb___024root___eval_initial__TOP(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_initial__TOP\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlWide<4>/*127:0*/ __Vtemp_1;
    // Body
    __Vtemp_1[0U] = 0x2e747874U;
    __Vtemp_1[1U] = 0x61726765U;
    __Vtemp_1[2U] = 0x72656368U;
    __Vtemp_1[3U] = 0x70U;
    VL_READMEM_N(false, 8, 512, 0, VL_CVT_PACK_STR_NW(4, __Vtemp_1)
                 ,  &(vlSelfRef.ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory)
                 , 0, ~0ULL);
}

VL_ATTR_COLD void Vppu_tb___024root___eval_final(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_final\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vppu_tb___024root___dump_triggers__stl(Vppu_tb___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vppu_tb___024root___eval_phase__stl(Vppu_tb___024root* vlSelf);

VL_ATTR_COLD void Vppu_tb___024root___eval_settle(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_settle\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY(((0x64U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vppu_tb___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("test/ppu_tb.v", 3, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vppu_tb___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelfRef.__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vppu_tb___024root___dump_triggers__stl(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___dump_triggers__stl\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vppu_tb___024root___stl_sequent__TOP__0(Vppu_tb___024root* vlSelf);
VL_ATTR_COLD void Vppu_tb___024root____Vm_traceActivitySetAll(Vppu_tb___024root* vlSelf);

VL_ATTR_COLD void Vppu_tb___024root___eval_stl(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_stl\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered.word(0U))) {
        Vppu_tb___024root___stl_sequent__TOP__0(vlSelf);
        Vppu_tb___024root____Vm_traceActivitySetAll(vlSelf);
    }
}

VL_ATTR_COLD void Vppu_tb___024root___stl_sequent__TOP__0(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___stl_sequent__TOP__0\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
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

VL_ATTR_COLD void Vppu_tb___024root___eval_triggers__stl(Vppu_tb___024root* vlSelf);

VL_ATTR_COLD bool Vppu_tb___024root___eval_phase__stl(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___eval_phase__stl\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vppu_tb___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelfRef.__VstlTriggered.any();
    if (__VstlExecute) {
        Vppu_tb___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vppu_tb___024root___dump_triggers__act(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___dump_triggers__act\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge ppu_tb.clk)\n");
    }
    if ((2ULL & vlSelfRef.__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vppu_tb___024root___dump_triggers__nba(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___dump_triggers__nba\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ vlSelfRef.__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge ppu_tb.clk)\n");
    }
    if ((2ULL & vlSelfRef.__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vppu_tb___024root____Vm_traceActivitySetAll(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root____Vm_traceActivitySetAll\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vm_traceActivity[0U] = 1U;
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
}

VL_ATTR_COLD void Vppu_tb___024root___ctor_var_reset(Vppu_tb___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vppu_tb___024root___ctor_var_reset\n"); );
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->name());
    vlSelf->ppu_tb__DOT__clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11898107293945576402ull);
    vlSelf->ppu_tb__DOT__reset = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16238952030064043524ull);
    vlSelf->ppu_tb__DOT__S = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13836860701864698814ull);
    vlSelf->ppu_tb__DOT__instr_ID = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 4068343313455252441ull);
    vlSelf->ppu_tb__DOT__EX_ctrl = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 4951765884288386703ull);
    vlSelf->ppu_tb__DOT__MEM_ctrl = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 3693768634928116312ull);
    vlSelf->ppu_tb__DOT__WB_ctrl = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10753681697449368788ull);
    vlSelf->ppu_tb__DOT__CALL = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4730165324405656832ull);
    vlSelf->ppu_tb__DOT__JMPL = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17929676895389852656ull);
    vlSelf->ppu_tb__DOT__B = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8344335681964821153ull);
    vlSelf->ppu_tb__DOT__SOH_OP = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 16102152797149775165ull);
    vlSelf->ppu_tb__DOT__dut__DOT__pc_actual = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5525566363729635190ull);
    vlSelf->ppu_tb__DOT__dut__DOT__npc_actual = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 10199635332054910878ull);
    vlSelf->ppu_tb__DOT__dut__DOT__npc_next = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5736039123725635773ull);
    vlSelf->ppu_tb__DOT__dut__DOT__ALU_OP = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 1729792902180233621ull);
    vlSelf->ppu_tb__DOT__dut__DOT__RAM_Size = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 8093495248230720949ull);
    vlSelf->ppu_tb__DOT__dut__DOT__RAM_RW = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10717868270768654690ull);
    vlSelf->ppu_tb__DOT__dut__DOT__RAM_Enable = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4639462519562384438ull);
    vlSelf->ppu_tb__DOT__dut__DOT__L = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5767299700960383200ull);
    vlSelf->ppu_tb__DOT__dut__DOT__RF_LE = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3221525825021423259ull);
    for (int __Vi0 = 0; __Vi0 < 512; ++__Vi0) {
        vlSelf->ppu_tb__DOT__dut__DOT__IMEM__DOT__Memory[__Vi0] = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 11432181249983083543ull);
    }
    vlSelf->__Vtrigprevexpr___TOP__ppu_tb__DOT__clk__0 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13300499237927555714ull);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
