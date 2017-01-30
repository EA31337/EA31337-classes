//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
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
#include "Chart.mqh"

/**
 * Class to deal with indicators.
 */
class Indicators : public Chart {

  // Structs.
  struct IndicatorsParams {
    double foo;
  };
  // Struct variables.
  IndicatorsParams i_params;

  public:

    /**
     * Class constructor.
     */
    void Indicators(IndicatorsParams &_params, ENUM_TIMEFRAMES _tf = NULL, string _symbol = NULL) {
      i_params = _params;
    }
    void Indicators()
    {
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iac
     * - https://www.mql5.com/en/docs/indicators/iac
     */
    static double iAC(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iAC(_symbol, _tf, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iAC(_symbol, _tf);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iAC(int _shift = 0) {
      double _value = iAC(GetSymbol(), GetTf(), _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iad
     * - https://www.mql5.com/en/docs/indicators/iad
     */
    static double iAD(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iAD(_symbol, _tf, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iAD(_symbol, _tf, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iAD(int _shift = 0) {
      double _value = iAD(GetSymbol(), GetTf(), _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iadx
     * - https://www.mql5.com/en/docs/indicators/iadx
     */
    static double iADX(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price, // (MT5): not used
        int _mode,                         // (MT4 _mode): 0 - MODE_MAIN, 1 - MODE_PLUSDI, 2 - MODE_MINUSDI
        int _shift = 0                     // (MT5 _mode): 0 - MAIN_LINE, 1 - PLUSDI_LINE, 2 - MINUSDI_LINE
        ) {
      #ifdef __MQL4__
      return ::iADX(_symbol, _tf, _period, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iADX(_symbol, _tf, _period);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iADX(uint _period, ENUM_APPLIED_PRICE _applied_price, int _mode, int _shift = 0) {
      double _value = iADX(GetSymbol(), GetTf(), _period, _applied_price, _mode, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ialligator
     * - https://www.mql5.com/en/docs/indicators/ialligator
     */
    static double iAlligator(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _jaw_period,
        uint _jaw_shift,
        uint _teeth_period,
        uint _teeth_shift,
        uint _lips_period,
        uint _lips_shift,
        ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _mode,                         // (MT4 _mode): 1 - MODE_GATORJAW, 2 - MODE_GATORTEETH, 3 - MODE_GATORLIPS
        int _shift = 0                     // (MT5 _mode): 0 - GATORJAW_LINE, 1 - GATORTEETH_LINE, 2 - GATORLIPS_LINE
        ) {
      #ifdef __MQL4__
      return ::iAlligator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iAlligator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iAlligator(uint _jaw_period, uint _jaw_shift, uint _teeth_period, uint _teeth_shift, uint _lips_period, uint _lips_shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _applied_price, int _mode, int _shift = 0) {
      double _value = iAlligator(GetSymbol(), GetTf(), _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iao
     * - https://www.mql5.com/en/docs/indicators/iao
     */
    static double iAO(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iAO(_symbol, _tf, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iAO(_symbol, _tf);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iAO(int _shift = 0) {
      double _value = iAO(GetSymbol(), GetTf(), _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iatr
     * - https://www.mql5.com/en/docs/indicators/iatr
     */
    static double iATR(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iATR(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iATR(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iATR(uint _period, int _shift = 0) {
      double _value = iATR(GetSymbol(), GetTf(), _period, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ibearspower
     * - https://www.mql5.com/en/docs/indicators/ibearspower
     */
    static double iBearsPower(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price, // (MT5): not used
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iBearsPower(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBearsPower(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iBearsPower(uint _period, ENUM_APPLIED_PRICE _applied_price,int _shift = 0) {
      double _value = iBearsPower(GetSymbol(), GetTf(), _period, _applied_price, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ibands
     * - https://www.mql5.com/en/docs/indicators/ibands
     */
    static double iBands(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        double _deviation,
        int _bands_shift,
        ENUM_APPLIED_PRICE _applied_price,   // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _mode,                           // (MT4 _mode): 0 - MODE_MAIN, 1 - MODE_UPPER, 2 - MODE_LOWER
        int _shift = 0                       // (MT5 _mode): 0 - BASE_LINE, 1 - UPPER_BAND, 2 - LOWER_BAND
        ) {
      #ifdef __MQL4__
      return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iBands(uint _period, double _deviation, int _bands_shift, ENUM_APPLIED_PRICE _applied_price, int _mode, int _shift = 0) {
      double _value = iBands(GetSymbol(), GetTf(), _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ibullspower
     * - https://www.mql5.com/en/docs/indicators/ibullspower
     */
    static double iBullsPower(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iBullsPower(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBullsPower(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iBullsPower(uint _period, ENUM_APPLIED_PRICE _applied_price, int _shift = 0) {
      double _value = iBullsPower(GetSymbol(), GetTf(), _period, _applied_price, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/icci
     * - https://www.mql5.com/en/docs/indicators/icci
     */
    static double iCCI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iCCI(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iCCI(_symbol, _tf, _period, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iCCI(uint _period, ENUM_APPLIED_PRICE _applied_price, int _shift = 0){
      double _value = iCCI(GetSymbol(), GetTf(), _period, _applied_price, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/idemarker
     * - https://www.mql5.com/en/docs/indicators/idemarker
     */
    static double iDeMarker(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iDeMarker(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iDeMarker(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iDeMarker(uint _period, int _shift = 0) {
      double _value = iDeMarker(GetSymbol(), GetTf(), _period, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ienvelopes
     * - https://www.mql5.com/en/docs/indicators/ienvelopes
     */
    static double iEnvelopes(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _ma_period,
        ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        int _ma_shift,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        double _deviation,
        int _mode,                         // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER
        int _shift = 0                     // (MT5 _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
        ) {
      #ifdef __MQL4__
      return ::iEnvelopes(_symbol, _tf, _ma_period, _ma_method, _ma_shift, _applied_price, _deviation, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iEnvelopes(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _deviation);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iEnvelopes(uint _ma_period,
        ENUM_MA_METHOD _ma_method,
        int _ma_shift,
        ENUM_APPLIED_PRICE _applied_price,
        double _deviation,
        int _mode,
        int _shift = 0) {
      double _value = iEnvelopes(GetSymbol(), GetTf(), _ma_period, _ma_method, _ma_shift, _applied_price, _deviation, _mode, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iforce
     * - https://www.mql5.com/en/docs/indicators/iforce
     */
    static double iForce(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iForce(_symbol, _tf, _period, _ma_method, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iForce(_symbol, _tf, _period, _ma_method, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iForce(
        uint _period,
        ENUM_MA_METHOD _ma_method,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0
        ) {
      double _value = iForce(GetSymbol(), GetTf(), _period, _ma_method, _applied_price, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ifractals
     * - https://www.mql5.com/en/docs/indicators/ifractals
     */
    static double iFractals(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _mode,                 // (MT4 _mode): 1 - MODE_UPPER, 2 - MODE_LOWER
        int _shift = 0             // (MT5 _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
        ) {
      #ifdef __MQL4__
      return ::iFractals(_symbol, _tf, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iFractals(_symbol, _tf);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iFractals(
        int _mode,
        int _shift = 0) {
      double _value = iFractals(GetSymbol(), GetTf(), _mode, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/igator
     * - https://www.mql5.com/en/docs/indicators/igator
     */
    static double iGator(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _jaw_period,
        uint _jaw_shift,
        uint _teeth_period,
        uint _teeth_shift,
        uint _lips_period,
        uint _lips_shift,
        ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _mode,                         // (MT4 _mode): 1 - MODE_UPPER,      2 - MODE_LOWER
        int _shift = 0                     // (MT5 _mode): 0 - UPPER_HISTOGRAM, 2 - LOWER_HISTOGRAM
        ) {
      #ifdef __MQL4__
      return ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iGator(
        uint _jaw_period,
        uint _jaw_shift,
        uint _teeth_period,
        uint _teeth_shift,
        uint _lips_period,
        uint _lips_shift,
        ENUM_MA_METHOD _ma_method,
        ENUM_APPLIED_PRICE _applied_price,
        int _mode,
        int _shift = 0) {
      double _value = iGator(GetSymbol(), GetTf(), _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iichimoku
     * - https://www.mql5.com/en/docs/indicators/iichimoku
     */
    static double iIchimoku(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _tenkan_sen,
        int _kijun_sen,
        int _senkou_span_b,
        int _mode,             // (MT4 _mode): 1 - MODE_TENKANSEN, 2 - MODE_KIJUNSEN, 3 - MODE_SENKOUSPANA, 4 - MODE_SENKOUSPANB, 5 - MODE_CHIKOUSPAN
        int _shift = 0         // (MT5 _mode): 0 - TENKANSEN_LINE, 1 - KIJUNSEN_LINE, 2 - SENKOUSPANA_LINE, 3 - SENKOUSPANB_LINE, 4 - CHIKOUSPAN_LINE
        ) {
      #ifdef __MQL4__
      return ::iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iIchimoku(
        int _tenkan_sen,
        int _kijun_sen,
        int _senkou_span_b,
        int _mode,
        int _shift = 0) {
       double _value = iIchimoku(GetSymbol(), GetTf(), _tenkan_sen, _kijun_sen, _senkou_span_b, _mode, _shift);
       CheckLastError();
       return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ibwmfi
     * - https://www.mql5.com/en/docs/indicators/ibwmfi
     */
    static double iBWMFI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iBWMFI(_symbol, _tf, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBWMFI(_symbol, _tf, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iBWMFI(int _shift = 0) {
      double _value = iBWMFI(GetSymbol(), GetTf(), _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/imomentum
     * - https://www.mql5.com/en/docs/indicators/imomentum
     */
    static double iMomentum(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMomentum(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iMomentum(_symbol, _tf, _period, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iMomentum(
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      double _value = iMomentum(GetSymbol(), GetTf(), _period, _applied_price, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Calculates the Money Flow Index indicator and returns its value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/imfi
     * - https://www.mql5.com/en/docs/indicators/imfi
     */
    static double iMFI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMFI(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iMFI(_symbol, _tf, _period, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iMFI(
        int _period,
        int _shift = 0) {
      double _value = iMFI(GetSymbol(), GetTf(), _period, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iosma
     * - https://www.mql5.com/en/docs/indicators/iosma
     */
    static double iOsMA(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _fast_ema_period,
        uint _slow_ema_period,
        uint _signal_period,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iOsMA(_symbol, _tf, _fast_ema_period, _slow_ema_period, _signal_period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iOsMA(_symbol, _tf, _fast_ema_period, _slow_ema_period, _signal_period, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iOsMA(
        uint _fast_ema_period,
        uint _slow_ema_period,
        uint _signal_period,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      double _value = iOsMA(GetSymbol(), GetTf(), _fast_ema_period, _slow_ema_period, _signal_period, _applied_price, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iobv
     * - https://www.mql5.com/en/docs/indicators/iobv
     */
    static double iOBV(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iOBV(_symbol, _tf, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iOBV(_symbol, _tf, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iOBV(
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      double _value = iOBV(GetSymbol(), GetTf(), _applied_price, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/isar
     * - https://www.mql5.com/en/docs/indicators/isar
     */
    static double iSAR(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        double _step,
        double _max,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iSAR(_symbol ,_tf, _step, _max, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iSAR(_symbol , _tf, _step, _max);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iSAR(
        double _step,
        double _max,
        int _shift = 0) {
      double _value = iSAR(GetSymbol(), GetTf(), _step, _max, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/irsi
     * - https://www.mql5.com/en/docs/indicators/irsi
     */
    static double iRSI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iRSI(_symbol , _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iRSI(_symbol, _tf, _period, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iRSI(
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      double _value = iRSI(GetSymbol(), GetTf(), _period, _applied_price, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/irvi
     * - https://www.mql5.com/en/docs/indicators/irvi
     */
    static double iRVI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _mode,                     // (MT4 _mode): 0 - MODE_MAIN, 1 - MODE_SIGNAL
        int _shift = 0                 // (MT5 _mode): 0 - MAIN_LINE, 1 - SIGNAL_LINE
        ) {
      #ifdef __MQL4__
      return ::iRVI(_symbol, _tf, _period, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = :: iRVI(_symbol, _tf, _period);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iRVI(
        uint _period,
        int _mode,
        int _shift = 0) {
      double _value = iRVI(GetSymbol(), GetTf(), _period, _mode, _shift);
      CheckLastError();
      return _value;
    }

    /**
     * Calculates the Standard Deviation indicator and returns its value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/istddev
     * - https://www.mql5.com/en/docs/indicators/istddev
     */
    static double iStdDev (
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _ma_period,
        uint _ma_shift,
        ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iStdDev (
        uint _ma_period,
        uint _ma_shift,
        ENUM_MA_METHOD _ma_method,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
     double _value = iStdDev(GetSymbol(), GetTf(), _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
     CheckLastError();
     return _value;
    }

    /**
     * Calculates the Stochastic Oscillator and returns its value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/istochastic
     * - https://www.mql5.com/en/docs/indicators/istochastic
     */
    static double iStochastic(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _Kperiod,
        int _Dperiod,
        int _slowing,
        ENUM_MA_METHOD _ma_method,    // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        ENUM_STO_PRICE _price_field,  // (MT4 _price_field):      0      - Low/High,       1        - Close/Close
                                      // (MT5 _price_field): STO_LOWHIGH - Low/High, STO_CLOSECLOSE - Close/Close
        int _mode,                    // (MT4 _mode): 0 - MODE_MAIN, 1 - MODE_SIGNAL
        int _shift = 0                // (MT5 _mode): 0 - MAIN_LINE, 1 - SIGNAL_LINE
        ) {
      #ifdef __MQL4__
      return ::iStochastic(_symbol, _tf, _Kperiod, _Dperiod, _slowing, _ma_method, _price_field, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iStochastic(_symbol, _tf, _Kperiod, _Dperiod, _slowing, _ma_method, _price_field);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iStochastic(
        int _Kperiod,
        int _Dperiod,
        int _slowing,
        ENUM_MA_METHOD _ma_method,
        ENUM_STO_PRICE _price_field,
        int _mode,
        int _shift = 0) {
       double _value = iStochastic(GetSymbol(), GetTf(), _Kperiod, _Dperiod, _slowing, _ma_method, _price_field, _mode, _shift);
       CheckLastError();
       return _value;
    }

    /**
     * Calculates the Larry Williams' Percent Range and returns its value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iwpr
     * - https://www.mql5.com/en/docs/indicators/iwpr
     */
    static double iWPR(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iWPR(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iWPR(_symbol, _tf, _period);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iWPR(
        uint _period,
        int _shift = 0) {
      return  iWPR(GetSymbol(), GetTf(), _period, _shift);
    }

    /* Custom indicators */

    /**
     * Returns value for iHeikenAshi indicator.
     */
    enum ENUM_HA_MODE {
    #ifdef __MQL4__
      HA_LOW   = 0,
      HA_HIGH  = 1,
      HA_OPEN  = 2,
      HA_CLOSE = 3
    #else
      HA_OPEN  = 0,
      HA_HIGH  = 1,
      HA_LOW   = 2,
      HA_CLOSE = 3
    #endif
    };
    static double iHeikenAshi(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      ENUM_HA_MODE _mode,
      int _shift = 0
      ) {
      #ifdef __MQL4__
      return ::iCustom(_symbol, _tf, "Heiken Ashi", _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iCustom(_symbol, _tf, "Examples\\Heiken_Ashi");
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iHeikenAshi(
      ENUM_HA_MODE _mode,
      int _shift = 0) {
     double _value = iHeikenAshi(GetSymbol(), GetTf(), _mode, _shift);
     CheckLastError();
     return _value;
    }

    /**
     * Returns value for ZigZag indicator.
     */
    static double iZigZag(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      int _depth,
      int _deviation,
      int _backstep,
      int _shift = 0
      ) {
      #ifdef __MQL4__
      return ::iCustom(_symbol, _tf, "ZigZag", _depth, _deviation, _backstep, 0, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iCustom(_symbol, _tf, "Examples\\ZigZag", _depth, _deviation, _backstep);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iZigZag(int _depth, int _deviation, int _backstep, int _shift = 0) {
      double _value = iZigZag(GetSymbol(), GetTf(), _depth, _deviation, _backstep, _shift);
      CheckLastError();
      return _value;
    }

};
