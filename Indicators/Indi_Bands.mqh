//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
#include "../Indicator.mqh"
#include "Indi_StdDev.mqh"
#include "Indi_MA.mqh"

// Indicator line identifiers used in Bands.
enum ENUM_BANDS_LINE {
#ifdef __MQL4__
  BAND_BASE = MODE_MAIN,    // Main line.
  BAND_UPPER = MODE_UPPER,  // Upper limit.
  BAND_LOWER = MODE_LOWER,  // Lower limit.
#else
  BAND_BASE = BASE_LINE,    // Main line.
  BAND_UPPER = UPPER_BAND,  // Upper limit.
  BAND_LOWER = LOWER_BAND,  // Lower limit.
#endif
  FINAL_BANDS_LINE_ENTRY,
};

// Structs.
struct BandsParams : IndicatorParams {
  unsigned int period;
  double deviation;
  unsigned int shift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void BandsParams(unsigned int _period, double _deviation, int _shift, ENUM_APPLIED_PRICE _ap)
      : period(_period), deviation(_deviation), shift(_shift), applied_price(_ap) {
    itype = INDI_BANDS;
    max_modes = FINAL_BANDS_LINE_ENTRY;
    SetDataType(TYPE_DOUBLE);
  };
};

/**
 * Implements the Bollinger Bands® indicator.
 */
class Indi_Bands : public Indicator {
 protected:
  // Structs.
  BandsParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Bands(BandsParams &_p)
      : params(_p.period, _p.deviation, _p.shift, _p.applied_price), Indicator((IndicatorParams)_p) {}
  Indi_Bands(BandsParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.period, _p.deviation, _p.shift, _p.applied_price), Indicator(INDI_BANDS, _tf) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ibands
   * - https://www.mql5.com/en/docs/indicators/ibands
   */
  static double iBands(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, double _deviation, int _bands_shift,
                       ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW,
                                                           // PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
                       ENUM_BANDS_LINE _mode = BAND_BASE,  // (MT4/MT5): 0 - MODE_MAIN/BASE_LINE, 1 -
                                                           // MODE_UPPER/UPPER_BAND, 2 - MODE_LOWER/LOWER_BAND
                       int _shift = 0, Indicator *_obj = NULL) {
    ResetLastError();

#ifdef __MQL4__
    return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (GetLastError() > 0) {
      return EMPTY_VALUE;
    } else if (_bars_calc <= 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }
  
  static double iBandsOnIndicator(Indicator* _indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, double _deviation, int _bands_shift,
                       ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW,
                                                           // PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
                       ENUM_BANDS_LINE _mode = BAND_BASE,  // (MT4/MT5): 0 - MODE_MAIN/BASE_LINE, 1 -
                                                           // MODE_UPPER/UPPER_BAND, 2 - MODE_LOWER/LOWER_BAND
                       int _shift = 0, Indicator *_obj = NULL) {

    double _price_buffer[];
    double _indi_value_buffer[];
    double _std_dev;
    double _line_value;
    
    ArrayResize(_price_buffer, _period);
    ArrayResize(_indi_value_buffer, _period);
    
    for (int i = _bands_shift; i < (int)_period; i++) {
      int current_shift = _shift + (i - _bands_shift);
      // Prices.
      switch (_applied_price) {
        case PRICE_OPEN:
          _price_buffer[i] = Chart::iOpen(_symbol, _tf, current_shift);
          break;
        case PRICE_CLOSE:
          _price_buffer[i] = Chart::iClose(_symbol, _tf, current_shift);
          break;
        case PRICE_LOW:
          _price_buffer[i] = Chart::iLow(_symbol, _tf, current_shift);
          break;
        case PRICE_HIGH:
          _price_buffer[i] = Chart::iHigh(_symbol, _tf, current_shift);
          break;
        default:
          Print("Invalid _applied_price given for iBandsOnIndicator. ", _applied_price, " passed!");
          return 0;
      }
      
      // Getting current indicator value.
      switch (_indi.GetDataType()) {
        case TYPE_DOUBLE:
          _indi_value_buffer[i - _bands_shift] = _indi[i - _bands_shift].value.GetValueDbl(_indi.GetIDataType());
          break;
        case TYPE_INT:
          _indi_value_buffer[i - _bands_shift] = (double)_indi[i - _bands_shift].value.GetValueInt(_indi.GetIDataType());
          break;
      }      
    }

   // Base band.
   _line_value = Indi_MA::SimpleMA(_shift, _period, _price_buffer);

   // Standard deviation.
   _std_dev = Indi_StdDev::iStdDevOnArray(_shift, _price_buffer, _indi_value_buffer, _period);
   
   switch (_mode) {
     case BAND_BASE:
       // Already calculated.
       return _line_value;
     case BAND_UPPER:
       return _line_value + /* band deviations */ _deviation * _std_dev;
     case BAND_LOWER:
       return _line_value - /* band deviations */ _deviation * _std_dev;
   }

   return 0;
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_BANDS_LINE _mode, int _shift = 0) {
    ResetLastError();
    
    double _value;
    
    if (params.indi_data == NULL) {
      istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
      _value = Indi_Bands::iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(),
                                         GetAppliedPrice(), _mode, _shift, GetPointer(this));
      istate.is_ready = true;
    }
    else {
      // Calculating bands value from specified indicator.
      _value = Indi_Bands::iBandsOnIndicator(params.indi_data, GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(),
                                         GetAppliedPrice(), _mode, _shift, GetPointer(this));

      if (iparams.is_draw) {
        draw.DrawLineTo(StringFormat("%s_%d", GetName(), _mode), GetBarTime(_shift), _value);
      }

      istate.is_ready = _LastError == ERR_NO_ERROR;
    }

    istate.is_changed = false;
    
    return _value;
  }
  
  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position) && false) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.value.SetValue(params.idtype, GetValue(BAND_BASE, _shift), BAND_BASE);
      _entry.value.SetValue(params.idtype, GetValue(BAND_UPPER, _shift), BAND_UPPER);
      _entry.value.SetValue(params.idtype, GetValue(BAND_LOWER, _shift), BAND_LOWER);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID,
         true
        //!_entry.value.HasValue(params.idtype, (double) NULL)
        //&& !_entry.value.HasValue(params.idtype, EMPTY_VALUE)
        //&& _entry.value.GetMinDbl(params.idtype) > 0
        //&& _entry.value.GetValueDbl(params.idtype, BAND_LOWER) < _entry.value.GetValueDbl(params.idtype, BAND_UPPER)
      );
      //if (_entry.IsValid())
        idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get deviation value.
   */
  double GetDeviation() { return params.deviation; }

  /**
   * Get bands shift value.
   */
  unsigned int GetBandsShift() { return params.shift; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set deviation value.
   */
  void SetDeviation(double _deviation) {
    istate.is_changed = true;
    params.deviation = _deviation;
  }

  /**
   * Set bands shift value.
   */
  void SetBandsShift(int _shift) {
    istate.is_changed = true;
    params.shift = _shift;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idtype); }
};
