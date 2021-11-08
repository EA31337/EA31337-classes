//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of IndicatorData class.
 */

// Includes.
#include "../IndicatorData.mqh"

// User inputs.
#ifdef __input__ input #endif string __MA_Parameters__ = "-- Settings for the Moving Average indicator --";  // >>> MA <<<
#ifdef __input__ input #endif int MA_Period_Fast = 14;                  // Period Fast
#ifdef __input__ input #endif int MA_Period_Medium = 20;                // Period Medium
#ifdef __input__ input #endif int MA_Period_Slow = 48;                  // Period Slow
#ifdef __input__ input #endif double MA_Period_Ratio = 1.0;             // Period ratio between timeframes (0.5-1.5)
#ifdef __input__ input #endif int MA_Shift = 0;                         // Shift
#ifdef __input__ input #endif int MA_Shift_Fast = 0;                    // Shift Fast (+1)
#ifdef __input__ input #endif int MA_Shift_Medium = 0;                  // Shift Medium (+1)
#ifdef __input__ input #endif int MA_Shift_Slow = 1;                    // Shift Slow (+1)
#ifdef __input__ input #endif int MA_Shift_Far = 4;                     // Shift Far (+2)
#ifdef __input__ input #endif ENUM_MA_METHOD MA_Method = 1;             // MA Method
#ifdef __input__ input #endif ENUM_APPLIED_PRICE MA_Applied_Price = 3;  // Applied Price

class I_MA : public IndicatorData {
 protected:
  // Indicator Buffers.
  enum ENUM_MA_MODE {
    MODE_MA_FAST = 0,
    MODE_MA_MEDIUM = 1,
    MODE_MA_SLOW = 2,
    MAX_OF_ENUM_MA_MODE  // Buffers count
  };

 public:
  /**
   * Class constructor.
   */
  void I_MA() : IndicatorData("Custom MA Indicator", MAX_OF_ENUM_MA_MODE) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ima
   * - https://www.mql5.com/en/docs/indicators/ima
   */
  static double iMA(string _symbol, ENUM_TIMEFRAMES _tf, uint _ma_period, int _ma_shift,
                    ENUM_MA_METHOD _ma_method,          // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
                    ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW,
                                                        // PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
                    int _shift = 0) {
#ifdef __MQL4__
    return ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
#else  // __MQL5__
    double _res[];
    int _handle = ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price);
    return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
#endif
  }
  double iMA(uint _ma_period, int _ma_shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _applied_price,
             int _shift = 0) {
    double _value = iMA(Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), _ma_period, _ma_shift,
                        _ma_method, _applied_price, _shift);
    return _value;
  }

  /**
   * Get period value from settings.
   */
  int GetPeriod(ENUM_MA_MODE _ma_type) {
    switch (_ma_type) {
      default:
      case MODE_MA_FAST:
        return MA_Period_Fast;
      case MODE_MA_MEDIUM:
        return MA_Period_Medium;
      case MODE_MA_SLOW:
        return MA_Period_Slow;
    }
  }

  /**
   * Get shift value from settings.
   */
  int GetShift(ENUM_MA_MODE _ma_type) {
    switch (_ma_type) {
      default:
      case MODE_MA_FAST:
        return MA_Shift_Fast;
      case MODE_MA_MEDIUM:
        return MA_Shift_Medium;
      case MODE_MA_SLOW:
        return MA_Shift_Slow;
    }
  }

  /**
   * Get method value from settings.
   */
  ENUM_MA_METHOD GetMethod(ENUM_MA_MODE _ma_type) {
    switch (_ma_type) {
      default:
      case MODE_MA_FAST:
        return MA_Method;
      case MODE_MA_MEDIUM:
        return MA_Method;
      case MODE_MA_SLOW:
        return MA_Method;
    }
  }

  /**
   * Get applied price value from settings.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice(ENUM_MA_MODE _ma_type) {
    switch (_ma_type) {
      default:
      case MODE_MA_FAST:
        return MA_Applied_Price;
      case MODE_MA_MEDIUM:
        return MA_Applied_Price;
      case MODE_MA_SLOW:
        return MA_Applied_Price;
    }
  }

  /**
   * Calculates the Moving Average indicator.
   */
  bool Update(int shift = CURR) {
    bool _res = true;
    double _ma_value;
    for (ENUM_MA_MODE mode = 0; mode <= MODE_MA_SLOW; mode++) {
      _ma_value = iMA(Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetPeriod(mode),
                      GetShift(mode), GetMethod(mode), GetAppliedPrice(mode), shift);
      _res &= Add(_ma_value, mode, shift);
    }
    return _res;
  }
};

//////////////////////////////////////////////////////////////////////////
// create a custom mt4 indicator to show values on mt4 chart
//////////////////////////////////////////////////////////////////////////

#property indicator_chart_window
#property indicator_buffers MAX_OF_ENUM_MA_MODE

double FastMa[];
double MediumMa[];
double SlowMa[];

I_MA myMa;

/**
 * Implements OnInit().
 */
int OnInit() {
  IndicatorBuffers(MAX_OF_ENUM_MA_MODE);
  SetIndexBuffer(MODE_MA_FAST, FastMa);
  SetIndexBuffer(MODE_MA_MEDIUM, MediumMa);
  SetIndexBuffer(MODE_MA_SLOW, SlowMa);

  SetIndexStyle(MODE_MA_FAST, DRAW_LINE, STYLE_SOLID, 1, clrRed);
  SetIndexStyle(MODE_MA_MEDIUM, DRAW_LINE, STYLE_SOLID, 1, clrGreen);
  SetIndexStyle(MODE_MA_SLOW, DRAW_LINE, STYLE_SOLID, 1, clrGreen);
  return (INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[],
                const double &high[], const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  uint start_at = GetTickCount();

  int oldest_bar = rates_total - prev_calculated - 1;
  for (int i = oldest_bar; i >= 0; i--) {
    bool ok = myMa.Update(i);
    if (!ok) continue;

    FastMa[i] = myMa.GetDouble(MODE_MA_FAST, i);
    MediumMa[i] = myMa.GetDouble(MODE_MA_MEDIUM, i);
    SlowMa[i] = myMa.GetDouble(MODE_MA_SLOW, i);
  }

  PrintFormat("elapse %dms", GetTickCount() - start_at);

  return (rates_total);
}
