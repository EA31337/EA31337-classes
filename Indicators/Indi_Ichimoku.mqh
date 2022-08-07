//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Includes.
#include "../Indicator/Indicator.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iIchimoku(string _symbol, int _tf, int _ts, int _ks, int _ssb, int _mode, int _shift) {
  ResetLastError();
  return Indi_Ichimoku::iIchimoku(_symbol, (ENUM_TIMEFRAMES)_tf, _ts, _ks, _ssb, _mode, _shift);
}
#endif

#ifndef __MQLBUILD__
// Indicator constants.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/lines
// Identifiers of indicator lines permissible when copying values of iIchimoku().
#define TENKANSEN_LINE 0    // Tenkan-sen line.
#define KIJUNSEN_LINE 1     // Kijun-sen line.
#define SENKOUSPANA_LINE 2  // Senkou Span A line.
#define SENKOUSPANB_LINE 3  // Senkou Span B line.
#define CHIKOUSPAN_LINE 4   // Chikou Span line.
#endif

// Enums.
// Ichimoku Kinko Hyo identifiers used in Ichimoku indicator.
enum ENUM_ICHIMOKU_LINE {
#ifdef __MQL4__
  LINE_TENKANSEN = MODE_TENKANSEN,      // Tenkan-sen line.
  LINE_KIJUNSEN = MODE_KIJUNSEN,        // Kijun-sen line.
  LINE_SENKOUSPANA = MODE_SENKOUSPANA,  // Senkou Span A line.
  LINE_SENKOUSPANB = MODE_SENKOUSPANB,  // Senkou Span B line.
  LINE_CHIKOUSPAN = MODE_CHIKOUSPAN,    // Chikou Span line.
#else
  LINE_TENKANSEN = TENKANSEN_LINE,      // Tenkan-sen line.
  LINE_KIJUNSEN = KIJUNSEN_LINE,        // Kijun-sen line.
  LINE_SENKOUSPANA = SENKOUSPANA_LINE,  // Senkou Span A line.
  LINE_SENKOUSPANB = SENKOUSPANB_LINE,  // Senkou Span B line.
  LINE_CHIKOUSPAN = CHIKOUSPAN_LINE,    // Chikou Span line.
#endif
  FINAL_ICHIMOKU_LINE_ENTRY,
};

// Structs.
struct IndiIchimokuParams : IndicatorParams {
  unsigned int tenkan_sen;
  unsigned int kijun_sen;
  unsigned int senkou_span_b;
  // Struct constructors.
  IndiIchimokuParams(unsigned int _ts = 9, unsigned int _ks = 26, unsigned int _ss_b = 52, int _shift = 0)
      : tenkan_sen(_ts), kijun_sen(_ks), senkou_span_b(_ss_b), IndicatorParams(INDI_ICHIMOKU) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\Ichimoku");
  };
  IndiIchimokuParams(IndiIchimokuParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Ichimoku Kinko Hyo indicator.
 */
class Indi_Ichimoku : public Indicator<IndiIchimokuParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() {}

 public:
  /**
   * Class constructor.
   */
  Indi_Ichimoku(IndiIchimokuParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_ICHIMOKU_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  }
  Indi_Ichimoku(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                int _indi_src_mode = 0)
      : Indicator(IndiIchimokuParams(),
                  IndicatorDataParams::GetInstance(FINAL_ICHIMOKU_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

 public:
  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Returns the indicator value.
   *
   * @param
   * _mode int
   * - MT4: 1 - MODE_TENKANSEN, 2 - MODE_KIJUNSEN, 3 - MODE_SENKOUSPANA, 4 - MODE_SENKOUSPANB, 5 - MODE_CHIKOUSPAN
   * - MT5: 0 - TENKANSEN_LINE, 1 - KIJUNSEN_LINE, 2 - SENKOUSPANA_LINE, 3 - SENKOUSPANB_LINE, 4 - CHIKOUSPAN_LINE
   * @docs
   * - https://docs.mql4.com/indicators/iichimoku
   * - https://www.mql5.com/en/docs/indicators/iichimoku
   */
  static double iIchimoku(string _symbol, ENUM_TIMEFRAMES _tf, int _tenkan_sen, int _kijun_sen, int _senkou_span_b,
                          int _mode, int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    return ::iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    if (Terminal::IsVisualMode()) {
      // To avoid error 4806 (ERR_INDICATOR_DATA_NOT_FOUND),
      // we check the number of calculated data only in visual mode.
      int _bars_calc = BarsCalculated(_handle);
      if (GetLastError() > 0) {
        return EMPTY_VALUE;
      } else if (_bars_calc <= 2) {
        SetUserError(ERR_USER_INVALID_BUFF_NUM);
        return EMPTY_VALUE;
      }
    }
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_Ichimoku::iIchimoku(GetSymbol(), GetTf(), GetTenkanSen(), GetKijunSen(), GetSenkouSpanB(), _mode,
                                          _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetTenkanSen(),
                         GetKijunSen(), GetSenkouSpanB() /*]*/, _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Alters indicator's struct value.
   */
  void GetEntryAlter(IndicatorDataEntry &_entry, int _shift) override {
    Indicator<IndiIchimokuParams>::GetEntryAlter(_entry, _shift);
#ifdef __MQL4__
    // In MQL4 value of LINE_TENKANSEN is 1 (not 0 as in MQL5),
    // so we are duplicating it.
    _entry.values[0] = GetEntryValue(LINE_TENKANSEN, _shift);
#endif
    _entry.values[LINE_SENKOUSPANA] = GetEntryValue(LINE_SENKOUSPANA, _shift + GetKijunSen());
    _entry.values[LINE_SENKOUSPANB] = GetEntryValue(LINE_SENKOUSPANB, _shift + GetKijunSen());
    _entry.values[LINE_CHIKOUSPAN] = GetEntryValue(LINE_CHIKOUSPAN, _shift + GetKijunSen());
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return Indicator<IndiIchimokuParams>::IsValidEntry(_entry) && _entry.IsGt<double>(0);
  }

  /* Getters */

  /**
   * Get period of Tenkan-sen line.
   */
  unsigned int GetTenkanSen() { return iparams.tenkan_sen; }

  /**
   * Get period of Kijun-sen line.
   */
  unsigned int GetKijunSen() { return iparams.kijun_sen; }

  /**
   * Get period of Senkou Span B line.
   */
  unsigned int GetSenkouSpanB() { return iparams.senkou_span_b; }

  /* Setters */

  /**
   * Set period of Tenkan-sen line.
   */
  void SetTenkanSen(unsigned int _tenkan_sen) {
    istate.is_changed = true;
    iparams.tenkan_sen = _tenkan_sen;
  }

  /**
   * Set period of Kijun-sen line.
   */
  void SetKijunSen(unsigned int _kijun_sen) {
    istate.is_changed = true;
    iparams.kijun_sen = _kijun_sen;
  }

  /**
   * Set period of Senkou Span B line.
   */
  void SetSenkouSpanB(unsigned int _senkou_span_b) {
    istate.is_changed = true;
    iparams.senkou_span_b = _senkou_span_b;
  }
};
