/**
 * @file
 * Wrappers to be used by MQL4 code to allow calling MQL5's indicator functions like iMA() in MQL4.
 */

#ifndef __MQL__
#pragma once
#endif

#ifdef INDICATOR_LEGACY_VERSION_MT4
#define INDICATOR_LEGACY_VERSION_DEFINED
#endif

#ifdef INDICATOR_LEGACY_VERSION_MT5
#define INDICATOR_LEGACY_VERSION_DEFINED
#endif

#ifndef INDICATOR_LEGACY_VERSION_DEFINED
#define INDICATOR_LEGACY_VERSION_MT5
#define INDICATOR_LEGACY_VERSION_DEFINED
#endif

#ifdef __MQL4__

#include <EA31337-classes/Indicator/IndicatorData.h>
#include <EA31337-classes/Std.h>
#include <EA31337-classes/Storage/ObjectsCache.h>
#include <EA31337-classes/Util.h>
#include <EA31337-classes/Platform.h>

#ifdef INDICATOR_LEGACY_VERSION_MT5

/**
 * Replacement for future OnCalculate().
 */
int OnCalculate(const int rates_total, const int prev_calculated, const datetime& time[], const double& open[],
                const double& high[], const double& low[], const double& close[], const long& tick_volume[],
                const long& volume[], const int& spread[]) {
  // We need to call Platform::Tick() and maybe also IndicatorData::EmitHistory() before.
  Platform::OnCalculate(rates_total, prev_calculated);
                
  int _num_calculated =
      OnCalculateMT5(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);

  return _num_calculated;
}

#define OnCalculate OnCalculateMT5

/**
 * Wrapper class to be used by MQL4 code to allow calling MQL5's indicator functions like iMA() in MQL4.
 */
class IndicatorLegacy : public Dynamic {
  // Handle to be used by BarsCalculated(), CopyBuffer() and so on.
  int handle;

  // Name of the indicator.
  string name;

 public:
  /**
   * Constructor.
   */
  IndicatorLegacy(string _name) : name(_name) { handle = indis.Size(); }

  /**
   * Returns indicator's handle.
   */
  int GetHandle() { return handle; }

  /**
   * Returns name of the indicator.
   */
  string GetName() { return name; }

  /**
   * Returns value for a given shift.
   */
  virtual double GetValue(int _shift) = 0;

  /**
   * Returns number of bars calculated for this indicator.
   */
  int GetBarsCalculated() {
    // @todo We probably need to replace it with some more specific check per indicator.
    return Bars;
  }

  // Dictionary of registered indicators (key -> indicator).
  static DictStruct<string, Ref<IndicatorLegacy>> indis;

  // Dictionary of registered indicators (handle -> indicator).
  static DictStruct<int, Ref<IndicatorLegacy>> indis_handles;

  /**
   * Returns number of bars calculated for a given indicator's handle.
   */
  static int GetBarsCalculated(int _handle) {
    if (_handle < 0 || _handle >= (int)indis.Size()) {
      Print("Error: Given handle index is out of bounds! Given handle index ", _handle, " and there is ", indis.Size(),
            " handles available.");
      DebugBreak();
      return 0;
    }

    IndicatorLegacy* _indi = indis_handles[_handle].Ptr();
    return PTR_ATTRIB(_indi, GetBarsCalculated());
  }
};

DictStruct<string, Ref<IndicatorLegacy>> IndicatorLegacy::indis;
DictStruct<int, Ref<IndicatorLegacy>> IndicatorLegacy::indis_handles;

/**
 * MQL4 wrapper of MQL5's BarsCalculated().
 */
int BarsCalculated(int _handle) { return IndicatorLegacy::GetBarsCalculated(_handle); }

/**
 * MQL4 wrapper of MQL5's CopyBuffer().
 */
int CopyBuffer(int _handle, int _mode, int _start, int _count, double& _buffer[]) {
  IndicatorLegacy* _indi = IndicatorLegacy::indis_handles[_handle].Ptr();

  if (_mode != 0) {
    Print("Only mode 0 is supported for ", PTR_ATTRIB(_indi, GetName()),
          " legacy indicator as MQL4 supports only a single mode.");
    DebugBreak();
    return 0;
  }

  int _num_copied = 0;
  int _buffer_size = ArraySize(_buffer);

  if (_buffer_size < _count) {
    _buffer_size = ArrayResize(_buffer, _count);
  }

  for (int i = 0; i < _count; ++i) {
    double _value = PTR_ATTRIB(_indi, GetValue(_start + i));

    if (_value == WRONG_VALUE) {
      break;
    }

    _buffer[_buffer_size - i - 1] = _value;
    ++_num_copied;
  }

  return _num_copied;
}

/**
 * Defines wrapper class and global iNAME() indicator function (e.g., iMA(), iATR()).
 */
// Print(#FN_NAME " key = ", _key); \
#define DEFINE_LEGACY_INDICATOR(FN_NAME, BUILTIN_NAME, TYPED_PARAMS_COMMA, TYPED_PARAMS_NO_UDL_SEMICOLON, UNTYPED_PARAMS_COMMA_KEY, UNTYPED_PARAMS_COMMA_VALUES, ASSIGNMENTS_COMMA, UNTYPED_PARAMS_NO_UDL_COMMA_VALUES) \
class BUILTIN_NAME##Legacy : public IndicatorLegacy { \
 TYPED_PARAMS_NO_UDL_SEMICOLON; \
public: \
 BUILTIN_NAME##Legacy(string _name, TYPED_PARAMS_COMMA) : IndicatorLegacy(_name), ASSIGNMENTS_COMMA {} \
 virtual double GetValue(int _shift) { \
   double _value = ::BUILTIN_NAME(UNTYPED_PARAMS_NO_UDL_COMMA_VALUES, _shift); \
   if (false) Print(GetName(), "[-", _shift, "]: ", _value); \
   return _value; \
 } \
}; \
int FN_NAME(TYPED_PARAMS_COMMA) { \
 Ref<IndicatorLegacy> _indi; \
 int _handle = INVALID_HANDLE; \
 string _key = Util::MakeKey(#FN_NAME, UNTYPED_PARAMS_COMMA_KEY); \
 if (IndicatorLegacy::indis.KeyExists(_key)) { \
   _indi = IndicatorLegacy::indis[_key]; \
 } \
 else { \
   _indi = new BUILTIN_NAME##Legacy(#BUILTIN_NAME, UNTYPED_PARAMS_COMMA_VALUES); \
   IndicatorLegacy::indis.Set(_key, _indi); \
   IndicatorLegacy::indis_handles.Set(PTR_ATTRIB(_indi.Ptr(), GetHandle()), _indi); \
 } \
 return PTR_ATTRIB(_indi.Ptr(), GetHandle()); \
}

/**
 * 1-parameter helper for DEFINE_LEGACY_INDICATOR.
 */
#define DEFINE_LEGACY_INDICATOR_1(FN_NAME, INDI_NAME, T1, N1) \
  DEFINE_LEGACY_INDICATOR(INDI_NAME, T1 _##N1, T1 N1, _##N1, _##N1, N1(_##N1), N1);

/**
 * 2-parameter helper for DEFINE_LEGACY_INDICATOR.
 */
#define DEFINE_LEGACY_INDICATOR_2(FN_NAME, INDI_NAME, T1, N1, T2, N2)                                            \
  DEFINE_LEGACY_INDICATOR(FN_NAME, INDI_NAME, T1 _##N1 COMMA T2 _##N2, T1 N1 SEMICOLON T2 N2, _##N1 COMMA _##N2, \
                          _##N1 COMMA _##N2, N1(_##N1) COMMA N2(_##N2), N1 COMMA N2);

/**
 * 3-parameter helper for DEFINE_LEGACY_INDICATOR.
 */
#define DEFINE_LEGACY_INDICATOR_3(FN_NAME, INDI_NAME, T1, N1, T2, N2, T3, N3)                       \
  DEFINE_LEGACY_INDICATOR(FN_NAME, INDI_NAME, T1 _##N1 COMMA T2 _##N2 COMMA T3 _##N3,               \
                          T1 N1 SEMICOLON T2 N2 SEMICOLON T3 N3, _##N1 COMMA _##N2 COMMA _##N3,     \
                          _##N1 COMMA _##N2 COMMA _##N3, N1(_##N1) COMMA N2(_##N2) COMMA N3(_##N3), \
                          N1 COMMA N2 COMMA N3);

/**
 * 4-parameter helper for DEFINE_LEGACY_INDICATOR.
 */
#define DEFINE_LEGACY_INDICATOR_4(FN_NAME, INDI_NAME)                                                           \
  DEFINE_LEGACY_INDICATOR(FN_NAME, INDI_NAME, T1 _##N1 COMMA T2 _##N2 COMMA T3 _##N3 COMMA T4 _##N4,            \
                          T1 N1 SEMICOLON T2 N2 SEMICOLON T3 N3 SEMICOLON T4 N4,                                \
                          _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4, _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4, \
                          N1(_##N1) COMMA N2(_##N2) COMMA N3(_##N3) COMMA N4(_##N4), N1 COMMA N2 COMMA N3 COMMA N4);

/**
 * 5-parameter helper for DEFINE_LEGACY_INDICATOR.
 */
#define DEFINE_LEGACY_INDICATOR_5(FN_NAME, INDI_NAME)                                                               \
  DEFINE_LEGACY_INDICATOR(FN_NAME, INDI_NAME, T1 _##N1 COMMA T2 _##N2 COMMA T3 _##N3 COMMA T4 _##N4 COMMA T5 _##N5, \
                          T1 N1 SEMICOLON T2 N2 SEMICOLON T3 N3 SEMICOLON T4 N4 SEMICOLON T5 N5,                    \
                          _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4 COMMA _##N5,                                    \
                          _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4 COMMA _##N5,                                    \
                          N1(_##N1) COMMA N2(_##N2) COMMA N3(_##N3) COMMA N4(_##N4) COMMA N5(_##N5),                \
                          N1 COMMA N2 COMMA N3 COMMA N4 COMMA N5);

/**
 * 6-parameter helper for DEFINE_LEGACY_INDICATOR.
 */
#define DEFINE_LEGACY_INDICATOR_6(FN_NAME, INDI_NAME)                                                                \
  DEFINE_LEGACY_INDICATOR(FN_NAME, INDI_NAME,                                                                        \
                          T1 _##N1 COMMA T2 _##N2 COMMA T3 _##N3 COMMA T4 _##N4 COMMA T5 _##N5 COMMA T6 _##N6,       \
                          T1 N1 SEMICOLON T2 N2 SEMICOLON T3 N3 SEMICOLON T4 N4 SEMICOLON T5 N5 SEMICOLON T6 N6,     \
                          _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4 COMMA _##N5 COMMA _##N6,                         \
                          _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4 COMMA _##N5 COMMA _##N6,                         \
                          N1(_##N1) COMMA N2(_##N2) COMMA N3(_##N3) COMMA N4(_##N4) COMMA N5(_##N5) COMMA N6(_##N6), \
                          N1 COMMA N2 COMMA N3 COMMA N4 COMMA N5 COMMA N6);

/**
 * 7-parameter helper for DEFINE_LEGACY_INDICATOR.
 */
#define DEFINE_LEGACY_INDICATOR_7(FN_NAME, INDI_NAME)                                                            \
  DEFINE_LEGACY_INDICATOR(                                                                                       \
      FN_NAME, INDI_NAME,                                                                                        \
      T1 _##N1 COMMA T2 _##N2 COMMA T3 _##N3 COMMA T4 _##N4 COMMA T5 _##N5 COMMA T6 _##N6 COMMA T7 _##N7,        \
      T1 N1 SEMICOLON T2 N2 SEMICOLON T3 N3 SEMICOLON T4 N4 SEMICOLON T5 N5 SEMICOLON T6 N6 SEMICOLON T7 N7,     \
      _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4 COMMA _##N5 COMMA _##N6 COMMA _##N7,                             \
      _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4 COMMA _##N5 COMMA _##N6 COMMA _##N7,                             \
      N1(_##N1) COMMA N2(_##N2) COMMA N3(_##N3) COMMA N4(_##N4) COMMA N5(_##N5) COMMA N6(_##N6) COMMA N7(_##N7), \
      N1 COMMA N2 COMMA N3 COMMA N4 COMMA N5 COMMA N6 COMMA N7);

/**
 * 8-parameter helper for DEFINE_LEGACY_INDICATOR.
 */
#define DEFINE_LEGACY_INDICATOR_8(FN_NAME, INDI_NAME)                                                                  \
  DEFINE_LEGACY_INDICATOR(FN_NAME, INDI_NAME,                                                                          \
                          T1 _##N1 COMMA T2 _##N2 COMMA T3 _##N3 COMMA T4 _##N4 COMMA T5 _##N5 COMMA T6 _##N6 COMMA T7 \
                              _##N7 COMMA T8 _##N8,                                                                    \
                          T1 N1 SEMICOLON T2 N2 SEMICOLON T3 N3 SEMICOLON T4 N4 SEMICOLON T5 N5 SEMICOLON T6 N6        \
                              SEMICOLON T7 N7 SEMICOLON T8 N8,                                                         \
                          _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4 COMMA _##N5 COMMA _##N6 COMMA _##N7 COMMA _##N8,   \
                          _##N1 COMMA _##N2 COMMA _##N3 COMMA _##N4 COMMA _##N5 COMMA _##N6 COMMA _##N7 COMMA _##N8,   \
                          N1(_##N1) COMMA N2(_##N2) COMMA N3(_##N3) COMMA N4(_##N4) COMMA N5(_##N5) COMMA N6(_##N6)    \
                              COMMA N7(_##N7) COMMA N8(_##N8),                                                         \
                          N1 COMMA N2 COMMA N3 COMMA N4 COMMA N5 COMMA N6 COMMA N7 COMMA N8);

/**
 * Replacement for future StringConcatenate().
 */
#define StringConcatenate StringConcatenateMT5

/**
 * MQL4 wrapper of MQL5's StringConcatenate().
 */
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J, typename K, typename L, typename M>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i, J _j, K _k, L _l,
                         M _m) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
            (string)_i + (string)_j + (string)_k + (string)_l + (string)_m;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J, typename K, typename L>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i, J _j, K _k, L _l) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
            (string)_i + (string)_j + (string)_k + (string)_l;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J, typename K>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i, J _j, K _k) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
            (string)_i + (string)_j + (string)_k;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i, J _j) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
            (string)_i + (string)_j;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
            (string)_i;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D, typename E, typename F>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e, F _f) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D, typename E>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d, E _e) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d + (string)_e;
  return StringLen(_result);
}
template <typename A, typename B, typename C, typename D>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c, D _d) {
  _result = (string)_a + (string)_b + (string)_c + (string)_d;
  return StringLen(_result);
}
template <typename A, typename B, typename C>
int StringConcatenateMT5(string& _result, A _a, B _b, C _c) {
  _result = (string)_a + (string)_b + (string)_c;
  return StringLen(_result);
}
template <typename A, typename B>
int StringConcatenateMT5(string& _result, A _a, B _b) {
  _result = (string)_a + (string)_b;
  return StringLen(_result);
}
template <typename A>
int StringConcatenateMT5(string& _result, A _a) {
  _result = (string)_a;
  return StringLen(_result);
}

// ----- LEGACY INDICATOR DEFINITIONS

// int iAC(string symbol, ENUM_TIMEFRAMES period);
DEFINE_LEGACY_INDICATOR_2(iAC, iAC, string, symbol, int, period);

// int iAD(string symbol, ENUM_TIMEFRAMES period, ENUM_APPLIED_VOLUME applied_volume);
DEFINE_LEGACY_INDICATOR_2(iAD, iAD, string, symbol, int, period);

// int iATR(string symbol, ENUM_TIMEFRAMES period, int ma_period);
DEFINE_LEGACY_INDICATOR_3(iATR, iATR, string, symbol, int, period, int, ma_period);

// int iRSI(string symbol, ENUM_TIMEFRAMES period, int ma_period, int applied_price);
#define T1 string
#define N1 symbol
#define T2 int
#define N2 period
#define T3 int
#define N3 ma_period
#define T4 int
#define N4 applied_price
DEFINE_LEGACY_INDICATOR_4(iRSI, iRSI)
#undef T1
#undef N1
#undef T2
#undef N2
#undef T3
#undef N3
#undef T4
#undef N4
#undef T5
#undef N5
#undef T6
#undef N6

// int iMA(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method,
#define T1 string
#define N1 symbol
#define T2 int
#define N2 period
#define T3 int
#define N3 ma_period
#define T4 int
#define N4 ma_shift
#define T5 int
#define N5 ma_method
#define T6 int
#define N6 applied_price
DEFINE_LEGACY_INDICATOR_6(iMA, iMA)
#undef T1
#undef N1
#undef T2
#undef N2
#undef T3
#undef N3
#undef T4
#undef N4
#undef T5
#undef N5
#undef T6
#undef N6

#endif  // INDICATOR_LEGACY_VERSION_MT5
#endif  // __MQL4__

#ifdef __MQL5__
#ifdef INDICATOR_LEGACY_VERSION_MT4

/**
 * Replacement for future StringConcatenate().
 */
#define StringConcatenate StringConcatenateMT4

/**
 * MQL5 wrapper of MQL4's StringConcatenate().
 */
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J, typename K, typename L, typename M>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i, J _j, K _k, L _l,
                            M _m) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
         (string)_i + (string)_j + (string)_k + (string)_l + (string)_m;
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J, typename K, typename L>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i, J _j, K _k, L _l) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
         (string)_i + (string)_j + (string)_k + (string)_l;
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J, typename K>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i, J _j, K _k) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
         (string)_i + (string)_j + (string)_k;
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i, J _j) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
         (string)_i + (string)_j;
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h +
         (string)_i;
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g + (string)_h;
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e, F _f, G _g) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f + (string)_g;
}
template <typename A, typename B, typename C, typename D, typename E, typename F>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e, F _f) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e + (string)_f;
}
template <typename A, typename B, typename C, typename D, typename E>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d, E _e) {
  return (string)_a + (string)_b + (string)_c + (string)_d + (string)_e;
}
template <typename A, typename B, typename C, typename D>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c, D _d) {
  return (string)_a + (string)_b + (string)_c + (string)_d;
}
template <typename A, typename B, typename C>
string StringConcatenateMT4(string& _result, A _a, B _b, C _c) {
  return (string)_a + (string)_b + (string)_c;
}
template <typename A, typename B>
string StringConcatenateMT4(string& _result, A _a, B _b) {
  return (string)_a + (string)_b;
}
template <typename A>
string StringConcatenateMT4(string& _result, A _a) {
  return (string)_a;
}

#endif  // INDICATOR_LEGACY_VERSION_MT4
#endif  // __MQL5__
