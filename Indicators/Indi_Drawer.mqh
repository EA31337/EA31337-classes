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
#include "../Action.mqh"
#include "../DictStruct.mqh"
#include "../Indicator.enum.h"
#include "../Indicator.mqh"
#include "../Redis.mqh"
#include "Indi_Price.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iDrawer(string _symbol, int _tf, int _period, int _ap, int _shift) {
  return Indi_Drawer::iDrawer(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, _shift);
}
#endif

// Structs.
struct DrawerParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;

  // Struct constructors.
  void DrawerParams(const DrawerParams &r) {
    period = r.period;
    applied_price = r.applied_price;
    custom_indi_name = r.custom_indi_name;
  }
  void DrawerParams(unsigned int _period, ENUM_APPLIED_PRICE _ap) : period(_period), applied_price(_ap) {
    itype = INDI_DRAWER;
    max_modes = 0;
    custom_indi_name = "Examples\\Drawer";
    SetDataValueType(TYPE_DOUBLE);
  };
  void DrawerParams(DrawerParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
    if (idstype == IDATA_INDICATOR && indi_data == NULL) {
      PriceIndiParams price_params(_tf);
      SetIndicatorData(new Indi_Price(price_params), true);
    }
  };
  void DrawerParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : period(12), applied_price(PRICE_WEIGHTED) { tf = _tf; }
  // Serializers.
  SERIALIZER_EMPTY_STUB;
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(this, "period", period);
    s.PassEnum(this, "applied_price", applied_price);
    s.Enter(SerializerEnterObject);
    IndicatorParams::Serialize(s);
    s.Leave();
    return SerializerNodeObject;
  }
};

// Storing calculated average gain and loss for SMMA calculations.
struct DrawerGainLossData {
  double avg_gain;
  double avg_loss;
};

/**
 * Implements the Relative Strength Index indicator.
 */
class Indi_Drawer : public Indicator {
 public:
  DrawerParams params;
  DictStruct<long, DrawerGainLossData> aux_data;
  Redis redis;

  /**
   * Class constructor.
   */
  Indi_Drawer(const DrawerParams &_params) : params(_params), Indicator((IndicatorParams)_params), redis(true) {
    params = _params;
    Init();
  }
  Indi_Drawer(const DrawerParams &_params, ENUM_TIMEFRAMES _tf)
      : params(_params), Indicator(INDI_DRAWER, _tf), redis(true) {
    // @fixme
    params.tf = _tf;
    Init();
  }

  void Init() {
    /*
       string msg_text =
        "*3\r\n"
        "$7\r\n"
        "message\r\n"
        "$14\r\n"
        "INDICATOR_DRAW\r\n"
        "$67\r\n"
        "{\"flags\":2,\"last_success\":0,\"action_id\":6,\"type\":11,\"frequency\":34}\r\n";

       redis.Messages().Enqueue(msg);
       
       redis.Messages().Enqueue(msg_text);
       */
  }

  virtual bool ExecuteAction(ENUM_INDICATOR_ACTION _action, IndiParamEntry &_args[]) {
    int num_args = ArraySize(_args), i;

    IndicatorDataEntry entry(num_args - 1);
    // @fixit Not sure if we should enforce double.
    entry.AddFlags(INDI_ENTRY_FLAG_IS_DOUBLE);

    iparams.SetMaxModes(num_args - 1);

    if (_action == INDI_ACTION_SET_VALUE) {
      if (num_args - 1 > iparams.GetMaxModes()) {
        Logger().Error(
            StringFormat("Too many data for buffers for action %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
      }

      for (i = 1; i < num_args; ++i) {
        entry.values[i - 1].Set(_args[i].double_value);
      }

      idata.Add(entry, _args[0].integer_value);

      double v1 = Indicator::GetValue<double>(0, 0);
      double v2 = Indicator::GetValue<double>(0, 1);
      return true;
    }

    return false;
  }

  virtual void OnTick() {
    Indicator::OnTick();

    ActionEntry action(INDI_ACTION_SET_VALUE);
    ArrayResize(action.args, 3);
    action.args[0].type = TYPE_LONG;
    action.args[0].integer_value = GetBarTime();

    action.args[1].type = TYPE_DOUBLE;
    action.args[1].double_value = 1.2;

    action.args[2].type = TYPE_DOUBLE;
    action.args[2].double_value = 1.25;

    string json = SerializerConverter::FromObject(action).ToString<SerializerJson>(/*SERIALIZER_JSON_NO_WHITESPACES*/);

    RedisMessage msg;
    msg.Add("message");
    msg.Add("INDICATOR_DRAW");
    msg.Add(json);

    redis.Messages().Enqueue(msg);

    while (redis.HasData()) {
      // Parsing commands.
      RedisMessage message = redis.ReadMessage();

      Print("Got: ", message.Message);

      if (message.Command == "message" && message.Channel == "INDICATOR_DRAW") {
        ActionEntry action;
        SerializerConverter::FromString<SerializerJson>(message.Message).ToObject(action);
        ExecuteAction((ENUM_INDICATOR_ACTION)action.action_id, action.args);

        Print("Deserialized action: ",
              SerializerConverter::FromObject(action).ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES));

        // Drawing on the buffer.
      }
    }
  }

  Redis *Redis() { return &redis; }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/irsi
   * - https://www.mql5.com/en/docs/indicators/irsi
   */
  static double iDrawer(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                        ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE, int _shift = 0, Indicator *_obj = NULL) {
    return 1.0;
  }

  /**
   * Calculates non-SMMA version of Drawer on another indicator (uses iDrawerOnArray).
   */
  static double iDrawerOnArrayOnIndicator(Indicator *_indi, string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
                                          unsigned int _period = 14, ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE,
                                          int _shift = 0, Indi_Drawer *_obj = NULL) {
    int i;
    double indi_values[];
    ArrayResize(indi_values, _period);

    double result;

    for (i = _shift; i < (int)_shift + (int)_period; i++) {
      indi_values[_shift + _period - (i - _shift) - 1] = _indi[i][_obj.GetParams().indi_mode];
    }

    result = iDrawerOnArray(indi_values, 0, _period - 1, 0);

    return result;
  }

  /**
   * Calculates SMMA-based (same as iDrawer method) Drawer on another indicator.
   *
   * @see https://school.stockcharts.com/doku.php?id=technical_indicators:relative_strength_index_rsi
   *
   * Reson behind iDrawer with SSMA and not just iDrawerOnArray() (from above website):
   *
   * "Taking the prior value plus the current value is a smoothing technique
   * similar to that used in calculating an exponential moving average. This
   * also means that Drawer values become more accurate as the calculation period
   * extends. SharpCharts uses at least 250 data points prior to the starting
   * date of any chart (assuming that much data exists) when calculating its
   * Drawer values. To exactly replicate our Drawer numbers, a formula will need at
   * least 250 data points."
   */
  static double iDrawerOnIndicator(Indicator *_indi, Indi_Drawer *_obj, string _symbol = NULL,
                                   ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _period = 14,
                                   ENUM_APPLIED_PRICE _applied_price = PRICE_CLOSE, int _shift = 0) {
    long _bar_time_curr = _obj.GetBarTime(_shift);
    long _bar_time_prev = _obj.GetBarTime(_shift + 1);
    if (fmin(_bar_time_curr, _bar_time_prev) < 0) {
      // Return empty value on invalid bar time.
      return EMPTY_VALUE;
    }
    // Looks like MT uses specified period as start of the SMMA calculations.
    _obj.FeedHistoryEntries(_period);

    int i;
    double indi_values[];
    ArrayResize(indi_values, _period);

    double result;

    // SMMA-based version of Drawer.
    DrawerGainLossData last_data, new_data;
    unsigned int data_position;
    double diff;
    int _mode = _obj.GetParams().indi_mode;

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

    if (new_data.avg_loss == 0.0)
      // @fixme Why 0 loss?
      return 0;

    double rs = new_data.avg_gain / new_data.avg_loss;

    result = 100.0 - (100.0 / (1.0 + rs));

    return result;
  }

  /**
   * Calculates Drawer on the array of values.
   */
  static double iDrawerOnArray(double &array[], int total, int period, int shift) {
#ifdef __MQL4__
    return ::iDrawerOnArray(array, total, period, shift);
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
   * Also, remember to use params.SetCustomIndicatorName(name) method to choose
   * indicator name, e.g.,: params.SetCustomIndicatorName("Examples\\Drawer");
   *
   * Note that in MQL5 Applied Price must be passed as the last parameter
   * (before mode and shift).
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_Drawer::iDrawer(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift, GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.custom_indi_name, /* [ */ GetPeriod(),
                         GetAppliedPrice() /* ] */, 0, _shift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_Drawer::iDrawerOnIndicator(params.indi_data, GetPointer(this), GetSymbol(), GetTf(), GetPeriod(),
                                                 GetAppliedPrice(), _shift);
        break;
    }
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry(params.max_modes);
    if (_bar_time < 0) {
      // Return empty value on invalid bar time.
      _entry.values[0] = EMPTY_VALUE;
      return _entry;
    }
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      if (ArraySize(_entry.values) > 0) {
        _entry.values[0] = GetValue(_shift);
      } else {
        // @fixit. We don't have value, but what if need latest valid value?
        return 0;
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue((double)NULL) && !_entry.HasValue(EMPTY_VALUE));
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    IndicatorDataEntry entry = GetEntry(_shift);
    if (_mode < ArraySize(entry.values)) {
      entry.values[_mode].Get(_param.double_value);
      return _param;
    }

    _param.double_value = 0;
    return _param;
  }

  /* Getters */

  /**
   * Get indicator params.
   */
  DrawerParams GetParams() { return params; }

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return params.period; }

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
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }
};
