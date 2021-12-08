// Params for dummy tick-based indicator.
struct IndicatorTickDummyParams : IndicatorParams {
  IndicatorTickDummyParams() : IndicatorParams(INDI_TICK, 2, TYPE_DOUBLE) {}
};

// Dummy tick-based indicator.
class IndicatorTickDummy : public IndicatorTick<IndicatorTickDummyParams, double> {
 public:
  IndicatorTickDummy(string _symbol, int _shift = 0, string _name = "")
      : IndicatorTick(INDI_TICK, _symbol, _shift, _name) {
    SetSymbol(_symbol);
  }

  string GetName() override { return "IndicatorTickDummy"; }

  void OnBecomeDataSourceFor(IndicatorBase* _base_indi) override {
    // Feeding base indicator with historic entries of this indicator.
    Print(GetName(), " became a data source for ", _base_indi.GetName());

    EmitEntry(TickToEntry(1000, TickAB<double>(1.0f, 1.01f)));
    EmitEntry(TickToEntry(1500, TickAB<double>(1.5f, 1.51f)));
    EmitEntry(TickToEntry(2000, TickAB<double>(2.0f, 2.01f)));
    EmitEntry(TickToEntry(3000, TickAB<double>(3.0f, 3.01f)));
    EmitEntry(TickToEntry(4000, TickAB<double>(4.0f, 4.01f)));
    EmitEntry(TickToEntry(4100, TickAB<double>(4.1f, 4.11f)));
    EmitEntry(TickToEntry(4200, TickAB<double>(4.2f, 4.21f)));
    EmitEntry(TickToEntry(4800, TickAB<double>(4.8f, 4.81f)));
  };
};
