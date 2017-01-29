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

// Globals enums.
enum ENUM_S_INDICATOR {
  //S_IND_AC         = 01, // Accelerator Oscillator
  //S_IND_AD         = 02, // Accumulation/Distribution
  //S_IND_ADX        = 03, // Average Directional Index
  //S_IND_ADXW       = 04, // ADX by Welles Wilder
  //S_IND_ALLIGATOR  = 05, // Alligator
  //S_IND_AMA        = 06, // Adaptive Moving Average
  //S_IND_AO         = 07, // Awesome Oscillator
  //S_IND_ATR        = 08, // Average True Range
  //S_IND_BANDS      = 09, // Bollinger Bands
  //S_IND_BEARS      = 10, // Bears Power
  //S_IND_BULLS      = 11, // Bulls Power
  //S_IND_BWMFI      = 12, // Market Facilitation Index
  //S_IND_CCI        = 13, // Commodity Channel Index
  //S_IND_CHAIKIN    = 14, // Chaikin Oscillator
  //S_IND_CUSTOM     = 15, // Custom indicator
  //S_IND_DEMA       = 16, // Double Exponential Moving Average
  //S_IND_DEMARKER   = 17, // DeMarker
  //S_IND_ENVELOPES  = 18, // Envelopes
  //S_IND_FORCE      = 19, // Force Index
  //S_IND_FRACTALS   = 20, // Fractals
  //S_IND_FRAMA      = 21, // Fractal Adaptive Moving Average
  //S_IND_GATOR      = 22, // Gator Oscillator
  //S_IND_ICHIMOKU   = 23, // Ichimoku Kinko Hyo
  S_IND_MA         = 24, // Moving Average
  S_IND_MACD       = 25, // MACD
  //S_IND_MFI        = 26, // Money Flow Index
  //S_IND_MOMENTUM   = 27, // Momentum
  //S_IND_OBV        = 28, // On Balance Volume
  //S_IND_OSMA       = 29, // OsMA
  //S_IND_RSI        = 30, // Relative Strength Index
  //S_IND_RVI        = 31, // Relative Vigor Index
  //S_IND_SAR        = 32, // Parabolic SAR
  //S_IND_STDDEV     = 33, // Standard Deviation
  //S_IND_STOCHASTIC = 34, // Stochastic Oscillator
  //S_IND_TEMA       = 35, // Triple Exponential Moving Average
  //S_IND_TRIX       = 36, // Triple Exponential Moving Averages Oscillator
  //S_IND_VIDYA      = 37, // Variable Index Dynamic Average
  //S_IND_VOLUMES    = 38, // Volumes
  //S_IND_WPR        = 39, // Williams' Percent Range
  S_IND_NONE       = 40  // (None)
};

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
     * Copies indicator data given the handle.
     */
    double GetHandleValue(
        int _handle, // The indicator handle.
        int _index, // The indicator buffer number.
        int _shift // The position of the first element to copy.
        ) {
      #ifdef __MQL4__
      // @todo
      return EMPTY_VALUE;
      #else // __MQL5__
      double _res[];
      return CopyBuffer(_handle, _index, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iAC(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iAC(_symbol, _tf, _shift);
      #else // __MQL5__
      int _handler = ::iAC(_symbol, _tf);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iAC(int _shift = 0) {
      return iAC(GetSymbol(), GetTf(), _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iAD(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iAD(_symbol, _tf, _shift);
      #else // __MQL5__
      int _handler = ::iAD(_symbol, _tf, VOLUME_TICK);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iAD(int _shift = 0) {
      return iAD(GetSymbol(), GetTf(), _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iADX(
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
      int _handler = ::iADX(_symbol, _tf, _period);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iADX(uint _period, ENUM_APPLIED_PRICE _applied_price, int _mode, int _shift = 0) {
      return iADX(GetSymbol(), GetTf(), _period, _applied_price, _mode, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iAlligator(
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
      int _handler = ::iAlligator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iAlligator(uint _jaw_period, uint _jaw_shift, uint _teeth_period, uint _teeth_shift, uint _lips_period, uint _lips_shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _applied_price, int _mode, int _shift = 0) {
      return iAlligator(GetSymbol(), GetTf(), _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iAO(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iAO(_symbol, _tf, _shift);
      #else // __MQL5__
      int _handler = ::iAO(_symbol, _tf);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iAO(int _shift = 0) {
      return iAO(GetSymbol(), GetTf(), _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iATR(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iATR(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      int _handler = ::iATR(_symbol, _tf, _period);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iATR(uint _period, int _shift = 0) {
      return iATR(GetSymbol(), GetTf(), _period, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iBearsPower(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price, // (MT5): not used
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iBearsPower(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      int _handler = ::iBearsPower(_symbol, _tf, _period);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iBearsPower(uint _period, ENUM_APPLIED_PRICE _applied_price,int _shift = 0) {
      return iBearsPower(GetSymbol(), GetTf(), _period, _applied_price, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iBands(
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
      int _handler = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iBands(uint _period, double _deviation, int _bands_shift, ENUM_APPLIED_PRICE _applied_price, int _mode, int _shift = 0) {
      return iBands(GetSymbol(), GetTf(), _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iBullsPower(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iBullsPower(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      int _handler = ::iBullsPower(_symbol, _tf, _period);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iBullsPower(uint _period, ENUM_APPLIED_PRICE _applied_price, int _shift = 0) {
      return iBullsPower(GetSymbol(), GetTf(), _period, _applied_price, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iCCI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iCCI(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      int _handler = ::iCCI(_symbol, _tf, _period, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iCCI(uint _period, ENUM_APPLIED_PRICE _applied_price, int _shift = 0){
      return iCCI(GetSymbol(), GetTf(), _period, _applied_price, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iDeMarker(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iDeMarker(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      int _handler = ::iDeMarker(_symbol, _tf, _period);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iDeMarker(uint _period, int _shift = 0) {
      return iDeMarker(GetSymbol(), GetTf(), _period, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iEnvelopes(
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
      int _handler = ::iEnvelopes(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _deviation);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iEnvelopes(uint _ma_period,
        ENUM_MA_METHOD _ma_method,
        int _ma_shift,
        ENUM_APPLIED_PRICE _applied_price,
        double _deviation,
        int _mode,
        int _shift = 0) {
      return iEnvelopes(GetSymbol(), GetTf(), _ma_period, _ma_method, _ma_shift, _applied_price, _deviation, _mode, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iForce(
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
      int _handler = ::iForce(_symbol, _tf, _period, _ma_method, VOLUME_TICK);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iForce(
        uint _period,
        ENUM_MA_METHOD _ma_method,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0
        ) {
      return iForce(GetSymbol(), GetTf(), _period, _ma_method, _applied_price, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iFractals(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _mode,                 // (MT4 _mode): 1 - MODE_UPPER, 2 - MODE_LOWER
        int _shift = 0             // (MT5 _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
        ) {
      #ifdef __MQL4__
      return ::iFractals(_symbol, _tf, _mode, _shift);
      #else // __MQL5__
      int _handler = ::iFractals(_symbol, _tf);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iFractals(
        int _mode,
        int _shift = 0) {
      return iFractals(GetSymbol(), GetTf(), _mode, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iGator(
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
      int _handler = ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
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
      return iGator(GetSymbol(), GetTf(), _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iIchimoku(
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
      int _handler = ::iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iIchimoku(
        int _tenkan_sen,
        int _kijun_sen,
        int _senkou_span_b,
        int _mode,
        int _shift = 0) {
       return iIchimoku(GetSymbol(), GetTf(), _tenkan_sen, _kijun_sen, _senkou_span_b, _mode, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iBWMFI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iBWMFI(_symbol, _tf, _shift);
      #else // __MQL5__
      int _handler = ::iBWMFI(_symbol, _tf, VOLUME_TICK);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iBWMFI(int _shift = 0) {
      return iBWMFI(GetSymbol(), GetTf(), _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iMomentum(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMomentum(_symbol, _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      int _handler = ::iMomentum(_symbol, _tf, _period, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iMomentum(
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      return iMomentum(GetSymbol(), GetTf(), _period, _applied_price, _shift);
    }

    /**
     * Calculates the Money Flow Index indicator and returns its value.
     *
     * @see http://docs.mql4.com/indicators/imfi
     */
    double iMFI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMFI(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      int _handle = ::iMFI(_symbol, _tf, _period, VOLUME_TICK);
      if (_handle == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handle, 0, _shift);
      #endif
    }
    double iMFI(
        int _period,
        int _shift = 0) {
      return iMFI(GetSymbol(), GetTf(), _period, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iMA(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _ma_period,
        int _ma_shift,
        ENUM_MA_METHOD _ma_method,          // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
        ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
      #else // __MQL5__
      int _handler = ::iMA(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iMA(
        uint _ma_period,
        int _ma_shift,
        ENUM_MA_METHOD _ma_method,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      return iMA(GetSymbol(), GetTf(), _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iOsMA(
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
      int _handler = ::iOsMA(_symbol, _tf, _fast_ema_period, _slow_ema_period, _signal_period, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iOsMA(
        uint _fast_ema_period,
        uint _slow_ema_period,
        uint _signal_period,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      return iOsMA(GetSymbol(), GetTf(), _fast_ema_period, _slow_ema_period, _signal_period, _applied_price, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iMACD(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _fast_ema_period,
        uint _slow_ema_period,
        uint _signal_period,
        ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _mode,                          // (MT4 _mode): 0 - MODE_MAIN, 1 - MODE_SIGNAL
        int _shift = 0                      // (MT5 _mode); 0 - MAIN_LINE, 1 - SIGNAL_LINE
        ) {
      #ifdef __MQL4__
      return ::iMACD(_symbol, _tf, _fast_ema_period, _slow_ema_period, _signal_period, _applied_price, _mode, _shift);
      #else // __MQL5__
      int _handler = ::iMACD(_symbol, _tf, _fast_ema_period, _slow_ema_period, _signal_period, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iMACD(
        uint _fast_ema_period,
        uint _slow_ema_period,
        uint _signal_period,
        ENUM_APPLIED_PRICE _applied_price,
        int _mode,
        int _shift = 0) {
      return iMACD(GetSymbol(), GetTf(), _fast_ema_period, _slow_ema_period, _signal_period, _applied_price, _mode, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iOBV(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iOBV(_symbol, _tf, _applied_price, _shift);
      #else // __MQL5__
      int _handler = ::iOBV(_symbol, _tf, VOLUME_TICK);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iOBV(
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      return iOBV(GetSymbol(), GetTf(), _applied_price, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iSAR(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        double _step,
        double _max,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iSAR(_symbol ,_tf, _step, _max, _shift);
      #else // __MQL5__
      int _handler = ::iSAR(_symbol , _tf, _step, _max);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iSAR(
        double _step,
        double _max,
        int _shift = 0) {
      return iSAR(GetSymbol(), GetTf(), _step, _max, _shift);
    }
    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iRSI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iRSI(_symbol , _tf, _period, _applied_price, _shift);
      #else // __MQL5__
      int _handler = ::iRSI(_symbol, _tf, _period, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iRSI(
        uint _period,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
      return iRSI(GetSymbol(), GetTf(), _period, _applied_price, _shift);
    }

    /**
     * Returns the indicator value.
     *
     * @docs
     * -
     */
    double iRVI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _mode,                     // (MT4 _mode): 0 - MODE_MAIN, 1 - MODE_SIGNAL
        int _shift = 0                 // (MT5 _mode): 0 - MAIN_LINE, 1 - SIGNAL_LINE
        ) {
      #ifdef __MQL4__
      return ::iRVI(_symbol, _tf, _period, _mode, _shift);
      #else // __MQL5__
      int _handler = :: iRVI(_symbol, _tf, _period);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iRVI(
        uint _period,
        int _mode,
        int _shift = 0) {
      return iRVI(GetSymbol(), GetTf(), _period, _mode, _shift);
    }

    /**
     * Calculates the Standard Deviation indicator and returns its value.
     *
     * @see http://docs.mql4.com/indicators/istddev
     */
    double iStdDev (
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
      int _handler = ::iStdDev(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iStdDev (
        uint _ma_period,
        uint _ma_shift,
        ENUM_MA_METHOD _ma_method,
        ENUM_APPLIED_PRICE _applied_price,
        int _shift = 0) {
     return iStdDev(GetSymbol(), GetTf(), _ma_period, _ma_shift, _ma_method, _applied_price, _shift);
    }

    /**
     * Calculates the Stochastic Oscillator and returns its value.
     *
     * @see http://docs.mql4.com/indicators/istochastic
     */
    double iStochastic(
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
      int _handler = ::iStochastic(_symbol, _tf, _Kperiod, _Dperiod, _slowing, _ma_method, _price_field);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
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
       return iStochastic(GetSymbol(), GetTf(), _Kperiod, _Dperiod, _slowing, _ma_method, _price_field, _mode, _shift);
    }

    /**
     * Calculates the Larry Williams' Percent Range and returns its value.
     *
     * @see http://docs.mql4.com/indicators/iwpr
     */
    double iWPR(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        int _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iWPR(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      int _handler = ::iWPR(_symbol, _tf, _period);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
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
    double iHeikenAshi(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      ENUM_HA_MODE _mode,
      int _shift = 0
      ) {
      #ifdef __MQL4__
      return ::iCustom(_symbol, _tf, "Heiken Ashi", _mode, _shift);
      #else // __MQL5__
      int _handler = ::iCustom(_symbol, _tf, "Examples\\Heiken_Ashi");
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, _mode, _shift);
      #endif
    }
    double iHeikenAshi(
      ENUM_HA_MODE _mode,
      int _shift = 0) {
     return iHeikenAshi(GetSymbol(), GetTf(), _mode, _shift);
    }

    /**
     * Returns value for ZigZag indicator.
     */
    double iZigZag(
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
      int _handler = ::iCustom(_symbol, _tf, "Examples\\ZigZag", _depth, _deviation, _backstep);
      if (_handler == INVALID_HANDLE) {
        logger.Error(GetLastErrorText(), __FUNCTION__);
        return -1;
      }
      return GetHandleValue(_handler, 0, _shift);
      #endif
    }
    double iZigZag(int _depth, int _deviation, int _backstep, int _shift = 0) {
      return iZigZag(GetSymbol(), GetTf(), _depth, _deviation, _backstep, _shift);
    }

};
