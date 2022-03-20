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
#include "../DictStruct.mqh"
#include "../Indicator.mqh"
#include "Indi_Bands.mqh"
#include "Indi_CCI.mqh"
#include "Indi_Envelopes.mqh"
#include "Indi_MA.mqh"
#include "Indi_Momentum.mqh"
#include "Indi_StdDev.mqh"
#include "Price/Indi_Price.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iRSI(string _symbol, int _tf, int _period, int _ap, int _shift) {
  ResetLastError();
  return Indi_RSI::iRSI(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, _shift);
}
double iRSIOnArray(double &_arr[], int _total, int _period, int _shift) {
  ResetLastError();
  return Indi_RSI::iRSIOnArray(_arr, _total, _period, _shift);
}
#endif

// Structs.
struct IndiRSIParams : IndicatorParams {
 protected:
  int period;
  ENUM_APPLIED_PRICE applied_price;

 public:
  IndiRSIParams(int _period = 14, ENUM_APPLIED_PRICE _ap = PRICE_OPEN, int _shift = 0)
      : applied_price(_ap), IndicatorParams(INDI_RSI, 1, TYPE_DOUBLE) {
    shift = _shift;
    SetDataValueRange(IDATA_RANGE_RANGE);
    //    SetDataSourceType(IDATA_ICUSTOM);
    SetCustomIndicatorName("Examples\\RSI");
    SetPeriod(_period);
  };
  IndiRSIParams(IndiRSIParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
  // Getters.
  ENUM_APPLIED_PRICE GetAppliedPrice() { return applied_price; }
  int GetPeriod() { return period; }
  // Setters.
  void SetPeriod(int _period) { period = _period; }
  void SetAppliedPrice(ENUM_APPLIED_PRICE _ap) { applied_price = _ap; }
  // Serializers.
  SERIALIZER_EMPTY_STUB;
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(THIS_REF, "period", period);
    s.PassEnum(THIS_REF, "applied_price", applied_price);
    s.Enter(SerializerEnterObject);
    IndicatorParams::Serialize(s);
    s.Leave();
    return SerializerNodeObject;
  }
};

// Storing calculated average gain and loss for SMMA calculations.
struct RSIGainLossData {
  double avg_gain;
  double avg_loss;
};

/**
 * Implements the Relative Strength Index indicator.
 */
class Indi_RSI : public Indicator<IndiRSIParams> {
  DictStruct<long, RSIGainLossData> aux_data;

 public:
  /**
   * Class constructor.
   */
  Indi_RSI(IndiRSIParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiRSIParams>(_p, _indi_src) {}
  Indi_RSI(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_RSI, _tf, _shift) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/irsi
   * - https://www.mql5.com/en/docs/indicators/irsi
   */
  static double iRSI(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                     ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE, int _shift = 0, IndicatorBase *_obj = NULL) {
#ifdef __MQL4__
    return ::iRSI(_symbol, _tf, _period, _applied_price, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iRSI(_symbol, _tf, _period, _applied_price), 0, _shift);
#endif
  }

  /**
   * Calculates non-SMMA version of RSI on another indicator (uses iRSIOnArray).
   */
  template <typename IT>
  static double iRSIOnArrayOnIndicator(IndicatorBase *_indi, string _symbol = NULL,
                                       ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                                       ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE, int _shift = 0,
                                       Indi_RSI *_obj = NULL) {
    int i;
    double indi_values[];
    ArrayResize(indi_values, _period);

    double result;

    for (i = _shift; i < (int)_shift + (int)_period; i++) {
      indi_values[_shift + _period - (i - _shift) - 1] = _indi[i][_obj.GetParams().indi_mode];
    }

    result = iRSIOnArray(indi_values, 0, _period - 1, 0);

    return result;
  }

  /**
   * Calculates SMMA-based (same as iRSI method) RSI on another indicator.
   *
   * @see https://school.stockcharts.com/doku.php?id=technical_indicators:relative_strength_index_rsi
   *
   * Reson behind iRSI with SSMA and not just iRSIOnArray() (from above website):
   *
   * "Taking the prior value plus the current value is a smoothing technique
   * similar to that used in calculating an exponential moving average. This
   * also means that RSI values become more accurate as the calculation period
   * extends. SharpCharts uses at least 250 data points prior to the starting
   * date of any chart (assuming that much data exists) when calculating its
   * RSI values. To exactly replicate our RSI numbers, a formula will need at
   * least 250 data points."
   */
  static double iRSIOnIndicator(IndicatorBase *_indi, Indi_RSI *_obj, string _symbol = NULL,
                                ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                                ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE, int _shift = 0) {
    long _bar_time_curr = _obj.GetBarTime(_shift);
    long _bar_time_prev = _obj.GetBarTime(_shift + 1);
    if (fmin(_bar_time_curr, _bar_time_prev) < 0) {
      // Return empty value on invalid bar time.
      return EMPTY_VALUE;
    }

    int i;
    double indi_values[];
    ArrayResize(indi_values, _period);

    double result;

    // SMMA-based version of RSI.
    RSIGainLossData last_data, new_data;
    unsigned int data_position;
    double diff;
    int _mode = _obj.GetDataSourceMode();

    if (!_obj.aux_data.KeyExists(_bar_time_prev, data_position)) {
      // No previous SMMA-based average gain and loss. Calculating SMA-based ones.
      double sum_gain = 0;
      double sum_loss = 0;

      for (i = 1; i < (int)_period; i++) {
        double price_new = _indi[(_shift + 1) + i - 1][_mode];
        double price_old = _indi[(_shift + 1) + i][_mode];

        if (price_new == 0.0 || price_old == 0.0) {
          // Missing history price data, skipping calculations.
          return 0.0;
        }

        diff = price_new - price_old;

        if (diff > 0) {
          sum_gain += diff;
        } else {
          sum_loss += -diff;
        }
      }

      // Calculating SMA-based values.
      last_data.avg_gain = sum_gain / _period;
      last_data.avg_loss = sum_loss / _period;
    } else {
      // Data already exists, retrieving it by position got by KeyExists().
      last_data = _obj.aux_data.GetByPos(data_position);
    }

    diff = _indi[_shift][_mode] - _indi[_shift + 1][_mode];

    double curr_gain = 0;
    double curr_loss = 0;

    if (diff > 0)
      curr_gain += diff;
    else
      curr_loss += -diff;

    new_data.avg_gain = (last_data.avg_gain * (_period - 1) + curr_gain) / _period;
    new_data.avg_loss = (last_data.avg_loss * (_period - 1) + curr_loss) / _period;

    _obj.aux_data.Set(_bar_time_curr, new_data);

    if (new_data.avg_loss == 0.0) {
      // @fixme Why 0 loss?
      return 0;
    }

    double rs = new_data.avg_gain / new_data.avg_loss;

    result = 100.0 - (100.0 / (1.0 + rs));

    return result;
  }

  /**
   * Calculates RSI on the array of values.
   */
  static double iRSIOnArray(double &array[], int total, int period, int shift) {
#ifdef __MQL4__
    return ::iRSIOnArray(array, total, period, shift);
#else
    double diff;
    if (total == 0) total = ArraySize(array);
    int stop = total - shift;
    if (period <= 1 || shift < 0 || stop <= period) return 0;
    bool isSeries = ArrayGetAsSeries(array);
    if (isSeries) ArraySetAsSeries(array, false);
    int i;
    double SumP = 0;
    double SumN = 0;
    for (i = 1; i <= period; i++) {
      diff = array[i] - array[i - 1];
      if (diff > 0)
        SumP += diff;
      else
        SumN += -diff;
    }
    double AvgP = SumP / period;
    double AvgN = SumN / period;
    for (; i < stop; i++) {
      diff = array[i] - array[i - 1];
      AvgP = (AvgP * (period - 1) + (diff > 0 ? diff : 0)) / period;
      AvgN = (AvgN * (period - 1) + (diff < 0 ? -diff : 0)) / period;
    }
    double rsi;
    if (AvgN == 0.0) {
      rsi = (AvgP == 0.0 ? 50.0 : 100.0);
    } else {
      rsi = 100.0 - (100.0 / (1.0 + AvgP / AvgN));
    }
    if (isSeries) ArraySetAsSeries(array, true);
    return rsi;
#endif
  }

  /**
   * Returns the indicator's value.
   *
   * For IDATA_ICUSTOM mode, use those three externs:
   *
   * extern unsigned int period;
   * extern ENUM_APPLIED_PRICE applied_price; // Required only for MQL4.
   * extern int shift;
   *
   * Also, remember to use iparams.SetCustomIndicatorName(name) method to choose
   * indicator name, e.g.,: iparams.SetCustomIndicatorName("Examples\\RSI");
   *
   * Note that in MQL5 Applied Price must be passed as the last parameter
   * (before mode and shift).
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    double _res[];
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value =
            Indi_RSI::iRSI(GetSymbol(), GetTf(), iparams.GetPeriod(), iparams.GetAppliedPrice(), _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name, /* [ */ iparams.GetPeriod(),
                         iparams.GetAppliedPrice() /* ] */, 0, _ishift);
        Print(_value);
        break;
      case IDATA_INDICATOR:
        _value = Indi_RSI::iRSIOnIndicator(GetDataSource(), THIS_PTR, GetSymbol(), GetTf(), iparams.GetPeriod(),
                                           iparams.GetAppliedPrice(), _ishift);
        break;
    }
    return _value;
  }

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorBase *FetchDataSource(ENUM_INDICATOR_TYPE _id) {
    if (_id == INDI_BANDS) {
      IndiBandsParams bands_params;
      return new Indi_Bands(bands_params);
    } else if (_id == INDI_CCI) {
      IndiCCIParams cci_params;
      return new Indi_CCI(cci_params);
    } else if (_id == INDI_ENVELOPES) {
      IndiEnvelopesParams env_params;
      return new Indi_Envelopes(env_params);
    } else if (_id == INDI_MOMENTUM) {
      IndiMomentumParams mom_params;
      return new Indi_Momentum(mom_params);
    } else if (_id == INDI_MA) {
      IndiMAParams ma_params;
      return new Indi_MA(ma_params);
    } else if (_id == INDI_RSI) {
      IndiRSIParams _rsi_params;
      return new Indi_RSI(_rsi_params);
    } else if (_id == INDI_STDDEV) {
      IndiStdDevParams stddev_params;
      return new Indi_StdDev(stddev_params);
    }

    return IndicatorBase::FetchDataSource(_id);
  }
};
