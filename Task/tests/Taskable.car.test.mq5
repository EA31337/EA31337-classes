//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * Test functionality of Task class.
 */

// Forward declaration.
struct DataParamEntry;

// Includes.
#include "../../Data.struct.h"
#include "../../Test.mqh"
#include "../Task.h"

// Implements test classes.
class Car : public Taskable<DataParamEntry> {
 protected:
  enum ENUM_CAR_ACTION {
    CAR_ACTION_NONE = 0,
    CAR_ACTION_CONTINUE,
    CAR_ACTION_SPEED_DEC_BY,
    CAR_ACTION_SPEED_INC_BY,
    CAR_ACTION_SPEED_SET_BY,
    CAR_ACTION_STOP,
  };
  enum ENUM_CAR_COND {
    CAR_COND_NONE = 0,
    CAR_COND_NEEDS_SERVICE,
    CAR_COND_IS_MOVING_BACKWARD,
    CAR_COND_IS_MOVING_FORWARD,
    CAR_COND_IS_SPEED_MAX,
    CAR_COND_IS_STOPPED,
  };
  enum ENUM_CAR_PROP {
    CAR_PROP_NONE = 0,
    CAR_PROP_MILEAGE_CURR,
    CAR_PROP_MILEAGE_MAX,
    CAR_PROP_SPEED,
  };
  int mileage_curr, mileage_max, speed_curr, speed_max;

 public:
  Car(int _speed_max = 100, int _mileage_max = 10000) : mileage_curr(0), speed_max(_speed_max) {}

  /* Tasks */

  /**
   * Checks a condition.
   */
  virtual bool Check(const TaskConditionEntry &_entry) {
    bool _result = false;
    switch (_entry.GetId()) {
      case CAR_COND_NEEDS_SERVICE:
        _result = mileage_curr > mileage_max;
        break;
      case CAR_COND_IS_MOVING_BACKWARD:
        _result = speed_curr < 0;
        break;
      case CAR_COND_IS_MOVING_FORWARD:
        _result = speed_curr > 0;
        break;
      case CAR_COND_IS_SPEED_MAX:
        _result = speed_curr >= speed_max;
        break;
      case CAR_COND_IS_STOPPED:
        _result = speed_curr == 0;
        break;
      default:
        break;
    }
    return _result;
  }

  /**
   * Gets a copy of structure.
   */
  virtual DataParamEntry Get(const TaskGetterEntry &_entry) {
    DataParamEntry _result;
    switch (_entry.GetId()) {
      case CAR_PROP_MILEAGE_CURR:
        _result = mileage_curr;
        break;
      case CAR_PROP_MILEAGE_MAX:
        _result = mileage_max;
        break;
      case CAR_PROP_SPEED:
        _result = speed_curr;
        break;
      default:
        break;
    }
    return _result;
  }
  template <typename E>
  DataParamEntry Get(E _id) {
    TaskGetterEntry _entry(_id);
    return Get(_entry);
  };

  /**
   * Runs an action.
   */
  virtual bool Run(const TaskActionEntry &_entry) {
    bool _result = false;
    switch (_entry.GetId()) {
      case CAR_ACTION_CONTINUE:
        mileage_curr += speed_curr;
        break;
      case CAR_ACTION_SPEED_DEC_BY:
        // speed_curr -= _entry.GetArg(); // @fixme
        break;
      case CAR_ACTION_SPEED_INC_BY:
        // speed_curr += _entry.GetArg(); // @fixme
        break;
      case CAR_ACTION_SPEED_SET_BY:
        // speed_curr = _entry.GetArg(); // @fixme
        break;
      case CAR_ACTION_STOP:
        speed_curr = 0;
        break;
      default:
        break;
    }
    return _result;
  }

  /**
   * Sets an entry value.
   */
  virtual bool Set(const TaskSetterEntry &_entry, const DataParamEntry &_entry_value) {
    bool _result = true;
    switch (_entry.GetId()) {
      case CAR_PROP_MILEAGE_CURR:
        // mileage_curr = _entry_value.ToValue<int>(); // @fixme
        break;
      case CAR_PROP_MILEAGE_MAX:
        // mileage_max = _entry_value.ToValue<int>(); // @fixme
        break;
      case CAR_PROP_SPEED:
        // speed_curr = _entry_value.ToValue<int>(); // @fixme
        break;
      default:
        _result = false;
        break;
    }
    return _result;
  }
  template <typename E>
  DataParamEntry Set(E _id) {
    TaskSetterEntry _entry(_id);
    return Set(_entry);
  };
};

// Test if car can drive.
bool TestCarCanDrive() {
  bool _result = true;
  Car *_car = new Car();
  _result &= _car.Get(STRUCT_ENUM(Car, CAR_PROP_SPEED)).ToValue<int>() == 0;
  delete _car;
  return _result;
}

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  // @todo
  _result &= TestCarCanDrive();
  _result &= GetLastError() == 0;
  return (_result ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {}
