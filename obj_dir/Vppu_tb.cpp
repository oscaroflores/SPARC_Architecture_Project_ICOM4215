// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vppu_tb__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vppu_tb::Vppu_tb(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vppu_tb__Syms(contextp(), _vcname__, this)}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
    contextp()->traceBaseModelCbAdd(
        [this](VerilatedTraceBaseC* tfp, int levels, int options) { traceBaseModel(tfp, levels, options); });
}

Vppu_tb::Vppu_tb(const char* _vcname__)
    : Vppu_tb(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vppu_tb::~Vppu_tb() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vppu_tb___024root___eval_debug_assertions(Vppu_tb___024root* vlSelf);
#endif  // VL_DEBUG
void Vppu_tb___024root___eval_static(Vppu_tb___024root* vlSelf);
void Vppu_tb___024root___eval_initial(Vppu_tb___024root* vlSelf);
void Vppu_tb___024root___eval_settle(Vppu_tb___024root* vlSelf);
void Vppu_tb___024root___eval(Vppu_tb___024root* vlSelf);

void Vppu_tb::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vppu_tb::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vppu_tb___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vppu_tb___024root___eval_static(&(vlSymsp->TOP));
        Vppu_tb___024root___eval_initial(&(vlSymsp->TOP));
        Vppu_tb___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vppu_tb___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

void Vppu_tb::eval_end_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+eval_end_step Vppu_tb::eval_end_step\n"); );
#ifdef VM_TRACE
    // Tracing
    if (VL_UNLIKELY(vlSymsp->__Vm_dumping)) vlSymsp->_traceDump();
#endif  // VM_TRACE
}

//============================================================
// Events and timing
bool Vppu_tb::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty(); }

uint64_t Vppu_tb::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vppu_tb::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vppu_tb___024root___eval_final(Vppu_tb___024root* vlSelf);

VL_ATTR_COLD void Vppu_tb::final() {
    Vppu_tb___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vppu_tb::hierName() const { return vlSymsp->name(); }
const char* Vppu_tb::modelName() const { return "Vppu_tb"; }
unsigned Vppu_tb::threads() const { return 1; }
void Vppu_tb::prepareClone() const { contextp()->prepareClone(); }
void Vppu_tb::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vppu_tb::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vppu_tb___024root__trace_decl_types(VerilatedVcd* tracep);

void Vppu_tb___024root__trace_init_top(Vppu_tb___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vppu_tb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vppu_tb___024root*>(voidSelf);
    Vppu_tb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vppu_tb___024root__trace_decl_types(tracep);
    Vppu_tb___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vppu_tb___024root__trace_register(Vppu_tb___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vppu_tb::traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options) {
    (void)levels; (void)options;
    VerilatedVcdC* const stfp = dynamic_cast<VerilatedVcdC*>(tfp);
    if (VL_UNLIKELY(!stfp)) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vppu_tb::trace()' called on non-VerilatedVcdC object;"
            " use --trace-fst with VerilatedFst object, and --trace-vcd with VerilatedVcd object");
    }
    stfp->spTrace()->addModel(this);
    stfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vppu_tb___024root__trace_register(&(vlSymsp->TOP), stfp->spTrace());
}
