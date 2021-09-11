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
 * Test functionality of Action class.
 */

// Defines.
#define ACTION_EA_ENABLED

// Forward declaration.
struct DataParamEntry;

// Includes.
#include "../Action.mqh"
#include "../DictObject.mqh"
#include "../EA.mqh"
#include "../Test.mqh"

// Global variables.
Chart *chart;
EA *ea;
DictObject<short, Action> actions;

// Define strategy classes.
class Stg1 : public Strategy {
 public:
  void Stg1(StgParams &_params, TradeParams &_tparams, ChartParams &_cparams, string _name = "Stg1")
      : Strategy(_params, _tparams, _cparams, _name) {}
  static Stg1 *Init(ENUM_TIMEFRAMES _tf = NULL, unsigned long _magic_no = 0, ENUM_LOG_LEVEL _log_level = V_INFO) {
    ChartParams _cparams(_tf);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg1(stg_params_defaults, _tparams, _cparams, __FUNCTION__);
    return _strat;
  }
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method, float _level, int _shift) { return true; }
  bool SignalOpenFilterMethod(ENUM_ORDER_TYPE _cmd, int _method = 0) { return true; }
  float SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) { return 1.0; }
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method, float _level, int _shift) { return true; }
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f) {
    return _level;
  }
};

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  // Initializes chart.
  chart = new Chart();
  // Initializes EA.
  EAParams ea_params(__FILE__);
  ea = new EA(ea_params);
  _result &= ea.StrategyAdd<Stg1>(127);
  // Check asserts.
  // Confirm EA is active.
  assertTrueOrReturnFalse(ea.CheckCondition(EA_COND_IS_ACTIVE), "Wrong condition: EA_COND_IS_ACTIVE!");
  // Confirm EA is enabled.
  assertTrueOrReturnFalse(ea.CheckCondition(EA_COND_IS_ENABLED), "Wrong condition: EA_COND_IS_ENABLED!");
#ifdef ACTION_EA_ENABLED
  // Disables EA and confirm it's disabled.
  Action *action1 = new Action(EA_ACTION_DISABLE, ea);
  action1.Execute();
  assertTrueOrReturnFalse(!ea.CheckCondition(EA_COND_IS_ENABLED), "Wrong condition: EA_COND_IS_ENABLED!");
  delete action1;
  // Re-enables EA and confirm it's enabled.
  Action *action2 = new Action(EA_ACTION_ENABLE, ea);
  action2.Execute();
  assertTrueOrReturnFalse(ea.CheckCondition(EA_COND_IS_ENABLED), "Wrong condition: EA_COND_IS_ENABLED!");
  delete action2;
#endif
  _result &= GetLastError() == ERR_NO_ERROR;

  return (_result ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  chart.OnTick();
  if (chart.IsNewBar()) {
    unsigned int _bar_index = chart.GetBarIndex();
    switch (_bar_index) {
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
    }
  }
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {
  delete chart;
  delete ea;
}
