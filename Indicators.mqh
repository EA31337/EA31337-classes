//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Includes.
#include "Timeframe.mqh"

/**
 * Class to deal with indicators.
 */
class Indicators {

public:


  /**
   * Copies indicator data given the handle.
   */
  int GetHandleValue(
    int _handle, // The indicator handle.
    int _index, // The indicator buffer number.
    int _shift // The position of the first element to copy.
  ) {
    #ifdef __MQL4__
    // @todo
    return EMPTY_VALUE;
    #else // __MQL5__
    double buf[];
    return CopyBuffer(_handle, buffer_num, start_pos, 1, buf) > 0 ? buf[0] : EMPTY_VALUE;
    #endif
  }

  /**
   * Calculates the Money Flow Index indicator and returns its value.
   *
   * @see http://docs.mql4.com/indicators/imfi
   */
  /* @todo
  double iMFI(string symbol,
      int tf,
      int period,
      int shift) {
    ENUM_TIMEFRAMES timeframe = Timeframe::TFMigrate(tf);
    int handle = (int) iMFI (symbol, timeframe, period, VOLUME_TICK);
    if (handle < 0) {
      Print ("The iMFI object is not created: Error", GetLastError ());
      return -1;
    }
    else {
      return GetHandleValue(handle, 0, shift);
    }

    // Overriding iMFI function.
#define iMFI iMFIMQL4
  }
  */

  /**
   * Calculates the  Larry Williams' Percent Range and returns its value.
   *
   * @see http://docs.mql4.com/indicators/iwpr
   */
  /* @todo
  double iWPR(string symbol,
      int tf,
      int period,
      int shift) {
    ENUM_TIMEFRAMES timeframe = Timeframe::TFMigrate(tf);

    int handle = iWPR (symbol, timeframe, period);
    if (handle < 0) {
      Print ("The iWPR object is not created: Error", GetLastError ());
      return -1;
    }
    else {
      return GetHandleValue(handle, 0, shift);
    }
    // Overriding iMPR function.
    #define iWPR iWPRMQL4
  }
  */

  /**
   * Calculates the Stochastic Oscillator and returns its value.
   *
   * @see http://docs.mql4.com/indicators/istochastic
   */
  /* @todo
  double iStochastic(string symbol,
      int tf,
      int Kperiod,
      int Dperiod,
      int slowing,
      int method,
      int field,
      int mode,
      int shift) {
    ENUM_TIMEFRAMES timeframe   = Timeframe::TFMigrate(tf);
    ENUM_MA_METHOD  ma_method   = MethodMigrate (method);
    ENUM_STO_PRICE  price_field = StoFieldMigrate (field);

    int handle = iStochastic (symbol, timeframe, Kperiod, Dperiod, slowing, ma_method, price_field);

    if (handle < 0) {
      Print ("The iStochastic object is not created: Error", GetLastError ());
      return -1;
    } else {
      return GetHandleValue(handle, mode, shift);
    }
  }
  */

  /**
   * Calculates the Standard Deviation indicator and returns its value.
   *
   * @see http://docs.mql4.com/indicators/istddev
   */
  /* @todo
  double iStdDev (string symbol,
      int tf,
      int ma_period,
      int ma_shift,
      int method,
      int price,
      int shift) {
    ENUM_TIMEFRAMES    timeframe     = Timeframe::TFMigrate(tf);
    ENUM_MA_METHOD     ma_method     = MethodMigrate (method);
    ENUM_APPLIED_PRICE applied_price = PriceMigrate (price);

    int handle = iStdDev (symbol, timeframe, ma_period, ma_shift, ma_method, applied_price);

    if (handle < 0) {
      Print ("The iStdDev object is not created: Error", GetLastError ());
      return -1;
    }
    else {
      return GetHandleValue(handle, 0, shift);
    }
  }
  */

};