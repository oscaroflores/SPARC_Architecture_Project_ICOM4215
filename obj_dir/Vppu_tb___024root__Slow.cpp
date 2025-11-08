// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vppu_tb.h for the primary calling header

#include "Vppu_tb__pch.h"
#include "Vppu_tb__Syms.h"
#include "Vppu_tb___024root.h"

void Vppu_tb___024root___ctor_var_reset(Vppu_tb___024root* vlSelf);

Vppu_tb___024root::Vppu_tb___024root(Vppu_tb__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , __VdlySched{*symsp->_vm_contextp__}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vppu_tb___024root___ctor_var_reset(this);
}

void Vppu_tb___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vppu_tb___024root::~Vppu_tb___024root() {
}
