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

/**
 * @file
 * Class to provide generic chart operations.
 */

// Prevents processing this includes file for the second time.
#ifndef __MQL__
#pragma once
#endif

// Includes.
#include "Chart.symboltf.h"

#ifdef __DISABLED

// Includes.
#include "Bar.struct.h"
#include "ChartBase.h"

/**
 * Meta-trader's native market prices source.
 */
class ChartMt : public ChartBase {
 public:
  /**
   * Constructor.
   */
  ChartMt(string _symbol, ENUM_TIMEFRAMES _tf) : ChartBase(_symbol, _tf) {}

  /**
   * Returns new or existing instance of Chart for a given timeframe.
   */
  static ChartMt* GetInstance(const SymbolTf& _symbol_tf) {
    ChartMt* _ptr;
    if (!Objects<ChartMt>::TryGet(_symbol_tf.Key(), _ptr)) {
      _ptr = Objects<ChartMt>::Set(_symbol_tf.Key(), new ChartMt(_symbol_tf.Symbol(), _symbol_tf.Tf()));
    }
    return _ptr;
  }

  // Virtual methods.

  /**
   * Returns time of the bar with a given shift.
   */
  virtual datetime GetBarTime(int _shift = 0) override { return ::iTime(GetSymbol(), GetTf(), _shift); }

  /**
   * Returns the number of bars on the chart.
   */
  virtual int GetBars() override {
#ifdef __MQL4__
    // In MQL4, for the current chart, the information about the amount of bars is in the Bars predefined variable.
    return ::iBars(GetSymbol(), GetTf());
#else  // _MQL5__
    return ::Bars(GetSymbol(), GetTf());
#endif
  }

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  virtual int GetBarShift(datetime _time, bool _exact = false) override {
#ifdef __MQL4__
    return ::iBarShift(GetTf(), _time, _exact);
#else  // __MQL5__
    if (_time < 0) return (-1);
    ARRAY(datetime, arr);
    datetime _time0;
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    CopyTime(GetSymbol(), GetTf(), 0, 1, arr);
    _time0 = arr[0];
    if (CopyTime(GetSymbol(), GetTf(), _time, _time0, arr) > 0) {
      if (ArraySize(arr) > 2) {
        return ArraySize(arr) - 1;
      } else {
        return _time < _time0 ? 1 : 0;
      }
    } else {
      return -1;
    }
#endif
  }

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  virtual int GetHighest(int type, int _count = WHOLE_ARRAY, int _start = 0) override {
    return ::iHighest(GetSymbol(), GetTf(), (ENUM_SERIESMODE)type, _count, _start);
  }

  /**
   * Returns the shift of the minimum value over a specific number of periods depending on type.
   */
  virtual int GetLowest(int type, int _count = WHOLE_ARRAY, int _start = 0) override {
    return ::iLowest(GetSymbol(), GetTf(), (ENUM_SERIESMODE)type, _count, _start);
  }

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  virtual double GetPeakPrice(int _bars, int _mode, int _index) override {
    int _ibar = -1;
    // @todo: Add symbol parameter.
    double _peak_price = GetOpen(0);
    switch (_mode) {
      case MODE_HIGH:
        _ibar = GetHighest(MODE_HIGH, _bars, _index);
        return _ibar >= 0 ? GetHigh(_ibar) : false;
      case MODE_LOW:
        _ibar = GetLowest(MODE_LOW, _bars, _index);
        return _ibar >= 0 ? GetLow(_ibar) : false;
      default:
        return false;
    }
  }

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  virtual double GetPrice(ENUM_APPLIED_PRICE _ap, int _shift = 0) override {
    switch (_ap) {
      case PRICE_OPEN:
        return ::iOpen(GetSymbol(), GetTf(), _shift);
      case PRICE_HIGH:
        return ::iHigh(GetSymbol(), GetTf(), _shift);
      case PRICE_LOW:
        return ::iLow(GetSymbol(), GetTf(), _shift);
      case PRICE_CLOSE:
        return ::iClose(GetSymbol(), GetTf(), _shift);
    }
    Print("Invalid applied price!");
    DebugBreak();
    return 0;
  }

  /**
   * Returns open time price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual datetime GetTime(unsigned int _shift = 0) override {
#ifdef __MQL4__
    return ::iTime(GetTf(), _shift);  // Same as: Time[_shift]
#else                                 // __MQL5__
    ARRAY(datetime, _arr);
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    // @todo: Improves performance by caching values.
    return (_shift >= 0 && ::CopyTime(GetSymbol(), GetTf(), _shift, 1, _arr) > 0) ? _arr[0] : 0;
#endif
  }

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetVolume(int _shift = 0) override { return ::iVolume(GetSymbol(), GetTf(), _shift); }
};

#endif

/**
 * Wrapper struct that returns close prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/close
 */
struct ChartPriceClose {
 protected:
  const SymbolTf symbol_tf;

 public:
  ChartPriceClose() : symbol_tf(Symbol(), PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static double Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartStatic::iClose(_symbol_tf.Symbol(), _symbol_tf.Tf(), _shift);
  }
};

/**
 * Wrapper struct that returns the highest prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/high
 */
struct ChartPriceHigh {
 protected:
  const SymbolTf symbol_tf;

 public:
  ChartPriceHigh() : symbol_tf(Symbol(), PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static double Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf) PTR_DEREF GetHigh(_shift);
  }
};

/**
 * Wrapper struct that returns the lowest prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/low
 */
struct ChartPriceLow {
 protected:
  const SymbolTf symbol_tf;

 public:
  ChartPriceLow() : symbol_tf(Symbol(), PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static double Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf) PTR_DEREF GetLow(_shift);
  }
};

/**
 * Wrapper struct that returns open prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/open
 */
struct ChartPriceOpen {
 protected:
  const SymbolTf symbol_tf;

 public:
  ChartPriceOpen() : symbol_tf(Symbol(), PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static double Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf) PTR_DEREF GetOpen(_shift);
  }
};

/**
 * Wrapper struct that returns open time of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/time
 */
struct ChartBarTime {
 protected:
  const SymbolTf symbol_tf;

 public:
  ChartBarTime() : symbol_tf(Symbol(), PERIOD_CURRENT) {}
  datetime operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static datetime Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf) PTR_DEREF GetTime(_shift);
  }
};
