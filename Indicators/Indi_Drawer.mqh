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

// Forward declaration.
struct IndicatorParams;

// Includes.
#include "../Action.mqh"
#include "../DictStruct.mqh"
#include "../Indicator.mqh"
#include "../Redis.mqh"
#include "Indi_Drawer.struct.h"
#include "Price/Indi_Price.mqh"

/**
 * Implements the Relative Strength Index indicator.
 */
class Indi_Drawer : public Indicator<IndiDrawerParams> {
  Redis redis;

 public:
  /**
   * Class constructor.
   */
  Indi_Drawer(const IndiDrawerParams &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<IndiDrawerParams>(_p, _indi_src), redis(true) {
    Init();
  }
  Indi_Drawer(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_DRAWER, _tf, _shift), redis(true) {
    Init();
  }

  void Init() {
    // Drawer is always ready.

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

  virtual bool ExecuteAction(ENUM_INDICATOR_ACTION _action, DataParamEntry &_args[]) {
    int num_args = ArraySize(_args), i;

    IndicatorDataEntry entry(num_args - 1);
    // @fixit Not sure if we should enforce double.
    // entry.AddFlags(INDI_ENTRY_FLAG_IS_DOUBLE);

    if (_action == INDI_ACTION_SET_VALUE) {
      iparams.SetMaxModes(num_args - 1);

      if (num_args - 1 > iparams.GetMaxModes()) {
        GetLogger().Error(
            StringFormat("Too many data for buffers for action %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
      }

      for (i = 1; i < num_args; ++i) {
        entry.values[i - 1].Set(_args[i].double_value);
      }

      // Assuming that passed values are correct.
      entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID);
      idata.Add(entry, _args[0].integer_value);
      return true;
    }

    return false;
  }

  virtual void OnTick() {
    Indicator<IndiDrawerParams>::OnTick();

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
#ifdef __debug__
      Print("Got: ", message.Message);
#endif
      if (message.Command == "message" && message.Channel == "INDICATOR_DRAW") {
        ActionEntry action_entry;
        SerializerConverter::FromString<SerializerJson>(message.Message).ToObject(action_entry);
        ExecuteAction((ENUM_INDICATOR_ACTION)action_entry.action_id, action_entry.args);
#ifdef __debug__
        Print("Deserialized action: ",
              SerializerConverter::FromObject(action_entry).ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES));
#endif
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
  static double iDrawer(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                        IndicatorBase *_obj = NULL) {
    return 1.0;
  }

  /**
   * Performs drawing on data from other indicator.
   */
  static double iDrawerOnIndicator(IndicatorBase *_indi, Indi_Drawer *_obj, string _symbol = NULL,
                                   ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) {
    // This method is not yet implemented.
    return 1.0;
  }

  /**
   * Performs drawing from data in array.
   */
  static double iDrawerOnArray(double &array[], int total, int period, int shift) { return 0; }

  /* Getters */

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_Drawer::iDrawer(GetSymbol(), GetTf(), _ishift, THIS_PTR);
        break;
      case IDATA_INDICATOR:
        _value = Indi_Drawer::iDrawerOnIndicator(GetDataSource(), THIS_PTR, GetSymbol(), GetTf(), _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};
