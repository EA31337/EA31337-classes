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
#include "Chart.mqh"
#include "Indicator.mqh"
#include "Log.mqh"

#define TO_STRING_LIMIT_DEFAULT 3
#define INDICATOR_BUFFERS_COUNT_MIN 1
#define BUFFER_MAX_SIZE_DEFAULT 50

/**
 * Class to store indicator value.
 */
class IndicatorValue {
 public:
  datetime bt;     // bar time
  MqlParam value;  // Contains value based on the data type (real, integer or string type).

  // double linked list attrs
  IndicatorValue* prev;
  IndicatorValue* next;

  void IndicatorValue() : bt(NULL), prev(NULL), next(NULL) {}

  // double linked list methods
  void Prev(IndicatorValue* p) {
    if (CheckPointer(p) == POINTER_INVALID) return;
    prev = p;
    p.next = GetPointer(this);
  }
  void Next(IndicatorValue* p) {
    if (CheckPointer(p) == POINTER_INVALID) return;
    next = p;
    p.prev = GetPointer(this);
  }
};

/**
 * Class to manage data buffer.
 */
class IndicatorBuffer {
 protected:
  int size;
  int max_size;
  IndicatorValue* _head;
  IndicatorValue* _tail;

 public:
  IndicatorBuffer(int _max_size = BUFFER_MAX_SIZE_DEFAULT) : size(0), max_size(_max_size), _head(NULL), _tail(NULL) {}
  ~IndicatorBuffer() {
    IndicatorValue* it = NULL;
    while (CheckPointer(_head) == POINTER_DYNAMIC) {
      it = _head;
      _head = _head.prev;
      delete it;
    }
  }

  double GetDouble(datetime _bar_time) {
    if (CheckPointer(_head) == POINTER_INVALID) return 0;

    IndicatorValue* _target = _head;
    while (CheckPointer(_target) == POINTER_DYNAMIC && (_bar_time < _target.bt || _target.value.type != TYPE_DOUBLE)) {
      _target = _target.prev;
    }

    if (CheckPointer(_target) == POINTER_INVALID) return 0;

    if (_target.bt == _bar_time && _target.value.type == TYPE_DOUBLE)
      return _target.value.double_value;
    else
      return 0;
  }

  int GetInt(datetime _bar_time) {
    if (CheckPointer(_head) == POINTER_INVALID) return 0;

    IndicatorValue* _target = _head;
    while (CheckPointer(_target) == POINTER_DYNAMIC && (_bar_time < _target.bt || _target.value.type != TYPE_INT)) {
      _target = _target.prev;
    }

    if (CheckPointer(_target) == POINTER_INVALID) return 0;

    if (_target.bt == _bar_time && _target.value.type == TYPE_INT)
      return (int)_target.value.integer_value;
    else
      return 0;
  }

  bool Add(double _value, datetime _bar_time, bool _force = false) {
    IndicatorValue* new_value = new IndicatorValue();
    new_value.bt = _bar_time;
    new_value.value.type = TYPE_DOUBLE;
    new_value.value.double_value = _value;
    return AddIndicatorValue(new_value, _force);
  }

  bool Add(int _value, datetime _bar_time, bool _force = false) {
    IndicatorValue* new_value = new IndicatorValue();
    new_value.bt = _bar_time;
    new_value.value.type = TYPE_INT;
    new_value.value.integer_value = _value;
    return AddIndicatorValue(new_value, _force);
  }

  bool AddIndicatorValue(IndicatorValue* _new_value, bool _force = false) {
    if (CheckPointer(_new_value) == POINTER_INVALID) return false;

    // first node for empty linked list
    if (CheckPointer(_head) == POINTER_INVALID) {
      _head = _new_value;
      _tail = _new_value;
      size = 1;
      return true;
    }

    // find insert position
    IndicatorValue* insert_pos = _head;
    while (CheckPointer(insert_pos) == POINTER_DYNAMIC && _new_value.bt <= insert_pos.bt) {
      insert_pos = insert_pos.prev;
    }

    // find existed value node(match both bt and value.type), force replace or not
    if (CheckPointer(insert_pos) == POINTER_DYNAMIC && _new_value.bt == insert_pos.bt &&
        _new_value.value.type == insert_pos.value.type) {
      if (_force) {
        insert_pos.value.integer_value = _new_value.value.integer_value;
        insert_pos.value.double_value = _new_value.value.double_value;
        insert_pos.value.string_value = _new_value.value.string_value;
        return true;
      } else
        return false;
    }

    // find insert pos at end of linked list
    if (CheckPointer(insert_pos) == POINTER_INVALID) {
      _tail.Prev(_new_value);
      _tail = _new_value;
    }
    // find insert pos at begin of linked list
    else if (insert_pos == _head) {
      _head.Next(_new_value);
      _head = _new_value;
    }
    // find insert pos at normal place
    else {
      insert_pos.Next(_new_value);
    }
    size++;

    // truncate data out of max_size
    if (size > max_size) {
      for (int i = 0; i < (max_size - size); i++) {
        _tail = _tail.next;
        delete _tail.prev;
        size--;
      }
    }

    return true;
  }

  string ToString(uint _limit = TO_STRING_LIMIT_DEFAULT) {
    string out = NULL;
    IndicatorValue* it = _head;
    uint i = 0;
    while (CheckPointer(it) == POINTER_DYNAMIC && i < _limit) {
      if (out != NULL)
        // add comma
        out = StringFormat("%s, ", out);
      else
        out = "";

      switch (it.value.type) {
        case TYPE_INT:
          out = StringFormat("%s[%d]%d", out, i, it.value.integer_value);
          break;
        case TYPE_DOUBLE: {
          string strfmt = StringFormat("%%s[%%d]%%.%df", _Digits);
          out = StringFormat(strfmt, out, i, it.value.double_value);
          break;
        }
      }
      i++;
      it = it.prev;
    }
    if (out == "" || out == NULL) out = "[Empty]";
    return out;
  }
};

/**
 * Implements class to store indicator data.
 */
class IndicatorData : public Chart {
 protected:
  // Struct variables.
  IndicatorBuffer buffers[];

  string iname;

  // Logging.
  Ref<Log> indi_logger;

 public:
  /**
   * Class constructor.
   */
  void IndicatorData(string _name = NULL, uint _max_buffer = INDICATOR_BUFFERS_COUNT_MIN) : iname(_name) {
    _max_buffer = fmax(_max_buffer, INDICATOR_BUFFERS_COUNT_MIN);
    ArrayResize(buffers, _max_buffer);
  }

  /**
   * Class deconstructor.
   */
  void ~IndicatorData() {}

  /**
   * Store a new indicator value.
   */
  bool IsValidMode(uint _mode) { return _mode < (uint)ArraySize(buffers); }

  bool Add(double _value, uint _mode = 0, uint _shift = CURR, bool _force = false) {
    if (!IsValidMode(_mode)) return false;
    return buffers[_mode].Add(_value, GetBarTime(_shift), _force);
  }

  bool Add(int _value, uint _mode = 0, uint _shift = CURR, bool _force = false) {
    if (!IsValidMode(_mode)) return false;
    return buffers[_mode].Add(_value, GetBarTime(_shift), _force);
  }

  double GetDouble(uint _mode = 0, uint _shift = CURR) {
    if (!IsValidMode(_mode)) return 0;
    return buffers[_mode].GetDouble(GetBarTime(_shift));
  }

  int GetInt(uint _mode = 0, uint _shift = CURR) {
    if (!IsValidMode(_mode)) return 0;
    return buffers[_mode].GetInt(GetBarTime(_shift));
  }

  /**
   * Get name of the indicator.
   */
  string GetName() { return iname != NULL ? iname : "Custom"; }

  /**
   * Print stored data.
   */
  string ToString(int mode = -1, uint _limit = TO_STRING_LIMIT_DEFAULT) {
    string _out = StringFormat("%s DATA:\n", GetName());
    if (mode == -1) {  // print all series
      for (int m = 0; m < ArraySize(buffers); m++) {
        _out = StringFormat("%s mode=%d %s\n", _out, m, buffers[m].ToString(_limit));
      }
    } else if (mode < ArraySize(buffers)) {
      _out = StringFormat("%s mode(%d) %s\n", _out, mode, buffers[mode].ToString(_limit));
    } else {
      _out = StringFormat("%s [Err] mode(%d) is invalid", mode);
    }
    return _out;
  }

  /**
   * Print stored data.
   */
  void PrintData(int mode = -1, uint _limit = TO_STRING_LIMIT_DEFAULT) { Print(ToString(mode, _limit)); }

  /**
   * Update indicator.
   */
  bool Update() { return true; }
};
