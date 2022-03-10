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
  ChartMt(ENUM_TIMEFRAMES _tf) : ChartBase(_tf) {}

  /**
   * Returns new or existing instance of Chart for a given timeframe.
   */
  static ChartMt* GetInstance(ENUM_TIMEFRAMES _tf) {
    ChartMt* _ptr;
    string _key = Util::MakeKey((int)_tf);
    if (!Objects<ChartMt>::TryGet(_key, _ptr)) {
      _ptr = Objects<ChartMt>::Set(_key, new ChartMt(_tf));
    }
    return _ptr;
  }

  // Virtual methods.

  virtual datetime GetBarTime(CONST_REF_TO(string) _symbol, int _shift = 0) override {
    return ::iTime(_symbol, GetTf(), _shift);
  }

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  virtual double GetPrice(ENUM_APPLIED_PRICE _ap, CONST_REF_TO(string) _symbol, int _shift = 0) override {
    switch (_ap) {
      case PRICE_OPEN:
        return ::iOpen(_symbol, GetTf(), _shift);
      case PRICE_HIGH:
        return ::iHigh(_symbol, GetTf(), _shift);
      case PRICE_LOW:
        return ::iLow(_symbol, GetTf(), _shift);
      case PRICE_CLOSE:
        return ::iClose(_symbol, GetTf(), _shift);
    }
    Print("Invalid applied price!");
    DebugBreak();
    return 0;
  }

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetVolume(CONST_REF_TO(string) _symbol, int _shift = 0) override {
    return ::iVolume(_symbol, GetTf(), _shift);
  }

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  virtual int GetHighest(CONST_REF_TO(string) _symbol, int type, int _count = WHOLE_ARRAY, int _start = 0) override {
    return ::iHighest(_symbol, GetTf(), (ENUM_SERIESMODE)type, _count, _start);
  }

  /**
   * Returns the shift of the minimum value over a specific number of periods depending on type.
   */
  virtual int GetLowest(CONST_REF_TO(string) _symbol, int type, int _count = WHOLE_ARRAY, int _start = 0) override {
    return ::iLowest(_symbol, GetTf(), (ENUM_SERIESMODE)type, _count, _start);
  }

  /**
   * Returns the number of bars on the chart.
   */
  virtual int GetBars(CONST_REF_TO(string) _symbol) override {
#ifdef __MQL4__
    // In MQL4, for the current chart, the information about the amount of bars is in the Bars predefined variable.
    return ::iBars(_symbol, GetTf());
#else  // _MQL5__
    return ::Bars(_symbol, GetTf());
#endif
  }

  /**
   * Returns open time price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual datetime GetTime(CONST_REF_TO(string) _symbol, unsigned int _shift = 0) override {
#ifdef __MQL4__
    return ::iTime(_symbol, GetTf(), _shift);  // Same as: Time[_shift]
#else                                          // __MQL5__
    ARRAY(datetime, _arr);
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    // @todo: Improves performance by caching values.
    return (_shift >= 0 && ::CopyTime(_symbol, GetTf(), _shift, 1, _arr) > 0) ? _arr[0] : 0;
#endif
  }

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  virtual int GetBarShift(CONST_REF_TO(string) _symbol, datetime _time, bool _exact = false) override {
#ifdef __MQL4__
    return ::iBarShift(_symbol, GetTf(), _time, _exact);
#else  // __MQL5__
    if (_time < 0) return (-1);
    ARRAY(datetime, arr);
    datetime _time0;
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    CopyTime(_symbol, GetTf(), 0, 1, arr);
    _time0 = arr[0];
    if (CopyTime(_symbol, GetTf(), _time, _time0, arr) > 0) {
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
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  virtual double GetPeakPrice(CONST_REF_TO(string) _symbol, int _bars, int _mode, int _index) override {
    int _ibar = -1;
    // @todo: Add symbol parameter.
    double _peak_price = GetOpen(_symbol, 0);
    switch (_mode) {
      case MODE_HIGH:
        _ibar = GetHighest(_symbol, MODE_HIGH, _bars, _index);
        return _ibar >= 0 ? GetHigh(_symbol, _ibar) : false;
      case MODE_LOW:
        _ibar = GetLowest(_symbol, MODE_LOW, _bars, _index);
        return _ibar >= 0 ? GetLow(_symbol, _ibar) : false;
      default:
        return false;
    }
  }
};

/**
 * Wrapper struct that returns close prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/close
 */
struct ChartPriceClose {
 protected:
  const SymbolTf symbol_tf;

 public:
  ChartPriceClose() : symbol_tf(_Symbol, PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static double Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf.Tf()) PTR_DEREF GetClose(_symbol_tf.Symbol(), _shift);
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
  ChartPriceHigh() : symbol_tf(_Symbol, PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static double Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf.Tf()) PTR_DEREF GetHigh(_symbol_tf.Symbol(), _shift);
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
  ChartPriceLow() : symbol_tf(_Symbol, PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static double Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf.Tf()) PTR_DEREF GetLow(_symbol_tf.Symbol(), _shift);
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
  ChartPriceOpen() : symbol_tf(_Symbol, PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static double Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf.Tf()) PTR_DEREF GetOpen(_symbol_tf.Symbol(), _shift);
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
  ChartBarTime() : symbol_tf(_Symbol, PERIOD_CURRENT) {}
  datetime operator[](const int _shift) const { return Get(symbol_tf, _shift); }
  static datetime Get(const SymbolTf& _symbol_tf, const int _shift) {
    return ChartMt::GetInstance(_symbol_tf.Tf()) PTR_DEREF GetTime(_symbol_tf.Symbol(), _shift);
  }
};
