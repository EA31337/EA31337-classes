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

/**
 * @file
 * Includes Indicator's structs.
 */

struct IndicatorDataEntry {
  unsigned char flags;  // Indicator entry flags.
  long timestamp;       // Timestamp of the entry's bar.
  union IndicatorDataEntryValue {
    double tdbl, tdbl2[2], tdbl3[3], tdbl4[4], tdbl5[5];
    int tint, tint2[2], tint3[3], tint4[4], tint5[5];
    // Operator overloading methods.
    double operator[](int _index) { return tdbl5[_index]; }
    // Other methods.
    double GetMinDbl(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1:
          return tdbl;
        case TDBL2:
          return fmin(tdbl2[0], tdbl2[1]);
        case TDBL3:
          return fmin(fmin(tdbl3[0], tdbl3[1]), tdbl3[2]);
        case TDBL4:
          return fmin(fmin(fmin(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]);
        case TDBL5:
          return fmin(fmin(fmin(fmin(tdbl5[0], tdbl5[1]), tdbl5[2]), tdbl5[3]), tdbl5[4]);
        case TINT1:
          return (double)tint;
        case TINT2:
          return (double)fmin(tint2[0], tint2[1]);
        case TINT3:
          return (double)fmin(fmin(tint3[0], tint3[1]), tint3[2]);
        case TINT4:
          return (double)fmin(fmin(fmin(tint4[0], tint4[1]), tint4[2]), tint4[3]);
        case TINT5:
          return (double)fmin(fmin(fmin(fmin(tint5[0], tint5[1]), tint5[2]), tint5[3]), tint5[4]);
      }
      return DBL_MIN;
    }
    int GetMinInt(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1:
          return (int)tdbl;
        case TDBL2:
          return (int)fmin(tdbl2[0], tdbl2[1]);
        case TDBL3:
          return (int)fmin(fmin(tdbl3[0], tdbl3[1]), tdbl3[2]);
        case TDBL4:
          return (int)fmin(fmin(fmin(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]);
        case TDBL5:
          return (int)fmin(fmin(fmin(fmin(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]), tdbl4[4]);
        case TINT1:
          return tint;
        case TINT2:
          return fmin(tint2[0], tint2[1]);
        case TINT3:
          return fmin(fmin(tint3[0], tint3[1]), tint3[2]);
        case TINT4:
          return fmin(fmin(fmin(tint4[0], tint4[1]), tint4[2]), tint4[3]);
        case TINT5:
          return fmin(fmin(fmin(fmin(tint4[0], tint4[1]), tint4[2]), tint4[3]), tint4[4]);
      }
      return INT_MIN;
    }
    double GetMaxDbl(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1:
          return tdbl;
        case TDBL2:
          return fmax(tdbl2[0], tdbl2[1]);
        case TDBL3:
          return fmax(fmax(tdbl3[0], tdbl3[1]), tdbl3[2]);
        case TDBL4:
          return fmax(fmax(fmax(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]);
        case TDBL5:
          return fmax(fmax(fmax(fmax(tdbl5[0], tdbl5[1]), tdbl5[2]), tdbl5[3]), tdbl5[4]);
        case TINT1:
          return (double)tint;
        case TINT2:
          return (double)fmax(tint2[0], tint2[1]);
        case TINT3:
          return (double)fmax(fmax(tint3[0], tint3[1]), tint3[2]);
        case TINT4:
          return (double)fmax(fmax(fmax(tint4[0], tint4[1]), tint4[2]), tint4[3]);
        case TINT5:
          return (double)fmax(fmax(fmax(fmax(tint5[0], tint5[1]), tint5[2]), tint5[3]), tint5[4]);
      }
      return DBL_MIN;
    }
    int GetMaxInt(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1:
          return (int)tdbl;
        case TDBL2:
          return (int)fmax(tdbl2[0], tdbl2[1]);
        case TDBL3:
          return (int)fmax(fmax(tdbl3[0], tdbl3[1]), tdbl3[2]);
        case TDBL4:
          return (int)fmax(fmax(fmax(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]);
        case TDBL5:
          return (int)fmax(fmax(fmax(fmax(tdbl5[0], tdbl5[1]), tdbl5[2]), tdbl5[3]), tdbl5[4]);
        case TINT1:
          return tint;
        case TINT2:
          return fmax(tint2[0], tint2[1]);
        case TINT3:
          return fmax(fmax(tint3[0], tint3[1]), tint3[2]);
        case TINT4:
          return fmax(fmax(fmax(tint4[0], tint4[1]), tint4[2]), tint4[3]);
        case TINT5:
          return fmax(fmax(fmax(fmax(tint5[0], tint5[1]), tint5[2]), tint5[3]), tint5[4]);
      }
      return INT_MIN;
    }
    double GetValueDbl(ENUM_IDATA_VALUE_TYPE _idvtype, int _index = 0) {
      switch (_idvtype) {
        case TDBL1:
          return tdbl;
        case TDBL2:
          return tdbl2[_index];
        case TDBL3:
          return tdbl3[_index];
        case TDBL4:
          return tdbl4[_index];
        case TDBL5:
          return tdbl5[_index];
        case TINT1:
          return (double)tint;
        case TINT2:
          return (double)tint2[_index];
        case TINT3:
          return (double)tint3[_index];
        case TINT4:
          return (double)tint4[_index];
        case TINT5:
          return (double)tint5[_index];
      }
      return WRONG_VALUE;
    }
    int GetValueInt(ENUM_IDATA_VALUE_TYPE _idvtype, int _index = 0) {
      switch (_idvtype) {
        case TDBL1:
          return (int)tdbl;
        case TDBL2:
          return (int)tdbl2[_index];
        case TDBL3:
          return (int)tdbl3[_index];
        case TDBL4:
          return (int)tdbl4[_index];
        case TDBL5:
          return (int)tdbl5[_index];
        case TINT1:
          return tint;
        case TINT2:
          return tint2[_index];
        case TINT3:
          return tint3[_index];
        case TINT4:
          return tint4[_index];
        case TINT5:
          return tint5[_index];
      }
      return WRONG_VALUE;
    }
    template <typename VType>
    bool HasValue(ENUM_IDATA_VALUE_TYPE _idvtype, VType _value) {
      switch (_idvtype) {
        case TDBL1:
          return tdbl == _value;
        case TDBL2:
          return tdbl2[0] == _value || tdbl2[1] == _value;
        case TDBL3:
          return tdbl3[0] == _value || tdbl3[1] == _value || tdbl3[2] == _value;
        case TDBL4:
          return tdbl4[0] == _value || tdbl4[1] == _value || tdbl4[2] == _value || tdbl4[3] == _value;
        case TDBL5:
          return tdbl5[0] == _value || tdbl5[1] == _value || tdbl5[2] == _value || tdbl5[3] == _value ||
                 tdbl5[4] == _value;
        case TINT1:
          return tint == _value;
        case TINT2:
          return tint2[0] == _value || tint2[1] == _value;
        case TINT3:
          return tint3[0] == _value || tint3[1] == _value || tint3[2] == _value;
        case TINT4:
          return tint4[0] == _value || tint4[1] == _value || tint4[2] == _value || tint4[3] == _value;
        case TINT5:
          return tint5[0] == _value || tint5[1] == _value || tint5[2] == _value || tint5[3] == _value ||
                 tint5[4] == _value;
      }
      return false;
    }
    void SetValue(ENUM_IDATA_VALUE_TYPE _idvtype, double _value, int _index = 0) {
      switch (_idvtype) {
        case TDBL1:
          tdbl = _value;
          break;
        case TDBL2:
          tdbl2[_index] = _value;
          break;
        case TDBL3:
          tdbl3[_index] = _value;
          break;
        case TDBL4:
          tdbl4[_index] = _value;
          break;
        case TDBL5:
          tdbl5[_index] = _value;
          break;
        case TINT1:
          tint = (int)_value;
          break;
        case TINT2:
          tint2[_index] = (int)_value;
          break;
        case TINT3:
          tint3[_index] = (int)_value;
          break;
        case TINT4:
          tint4[_index] = (int)_value;
          break;
        case TINT5:
          tint5[_index] = (int)_value;
          break;
      }
    }
    void SetValue(ENUM_IDATA_VALUE_TYPE _idvtype, int _value, int _index = 0) {
      switch (_idvtype) {
        case TDBL1:
          tdbl = (double)_value;
          break;
        case TDBL2:
          tdbl2[_index] = (double)_value;
          break;
        case TDBL3:
          tdbl3[_index] = (double)_value;
          break;
        case TDBL4:
          tdbl4[_index] = (double)_value;
          break;
        case TDBL5:
          tdbl5[_index] = (double)_value;
          break;
        case TINT1:
          tint = _value;
          break;
        case TINT2:
          tint2[_index] = _value;
          break;
        case TINT3:
          tint3[_index] = _value;
          break;
        case TINT4:
          tint4[_index] = _value;
          break;
        case TINT5:
          tint5[_index] = _value;
          break;
      }
    }
    string ToCSV(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1:
          return StringFormat("%g", tdbl);
        case TDBL2:
          return StringFormat("%g,%g", tdbl2[0], tdbl2[1]);
        case TDBL3:
          return StringFormat("%g,%g,%g", tdbl3[0], tdbl3[1], tdbl3[2]);
        case TDBL4:
          return StringFormat("%g,%g,%g,%g", tdbl4[0], tdbl4[1], tdbl4[2], tdbl4[3]);
        case TDBL5:
          return StringFormat("%g,%g,%g,%g,%g", tdbl5[0], tdbl5[1], tdbl5[2], tdbl5[3], tdbl5[4]);
        case TINT1:
          return StringFormat("%d", tint);
        case TINT2:
          return StringFormat("%d,%d", tint2[0], tint2[1]);
        case TINT3:
          return StringFormat("%d,%d,%g", tint3[0], tint3[1], tint3[2]);
        case TINT4:
          return StringFormat("%d,%d,%d,%d", tint4[0], tint4[1], tint4[2], tint4[3]);
        case TINT5:
          return StringFormat("%d,%d,%d,%d,%g", tint5[0], tint5[1], tint5[2], tint5[3], tint5[4]);
      }
      return "";
    }
    string ToString(ENUM_IDATA_VALUE_TYPE _idvtype) { return ToCSV(_idvtype); }
  } value;
  // Special methods.
  void IndicatorDataEntry() : flags(INDI_ENTRY_FLAG_NONE), timestamp(0) {}
  // Operator overloading methods.
  double operator[](int _index) { return value[_index]; }
  // Other methods.
  bool IsValid() { return bool(flags & INDI_ENTRY_FLAG_IS_VALID); }
  int GetDayOfYear() { return DateTime::TimeDayOfYear(timestamp); }
  int GetMonth() { return DateTime::TimeMonth(timestamp); }
  int GetYear() { return DateTime::TimeYear(timestamp); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(INDICATOR_ENTRY_FLAGS _flag, bool _value) {
    if (_value)
      AddFlags(_flag);
    else
      RemoveFlags(_flag);
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
};

struct IndicatorParams : ChartParams {
  string name;                     // Name of the indicator.
  int shift;                       // Shift (relative to the current bar, 0 - default).
  unsigned int max_modes;          // Max supported indicator modes (values per entry).
  unsigned int max_buffers;        // Max buffers to store.
  ENUM_INDICATOR_TYPE itype;       // Type of indicator.
  ENUM_IDATA_SOURCE_TYPE idstype;  // Indicator data source type.
  ENUM_IDATA_VALUE_TYPE idvtype;   // Indicator data value type.
  ENUM_DATATYPE dtype;             // General type of stored values (DTYPE_DOUBLE, DTYPE_INT).
  Indicator* indi_data;            // Indicator to be used as data source.
  bool indi_data_ownership;        // Whether this indicator should delete given indicator at the end.
  color indi_color;                // Indicator color.
  int indi_mode;                   // Index of indicator data to be used as data source.
  bool is_draw;                    // Draw active.
  int draw_window;                 // Drawing window.
  string custom_indi_name;         // Name of the indicator passed to iCustom() method.
  /* Special methods */
  // Constructor.
  IndicatorParams(ENUM_INDICATOR_TYPE _itype = INDI_NONE, ENUM_IDATA_VALUE_TYPE _idvtype = TDBL1,
                  ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, string _name = "")
      : name(_name),
        shift(0),
        max_modes(1),
        max_buffers(10),
        idstype(_idstype),
        itype(_itype),
        is_draw(false),
        indi_color(clrNONE),
        indi_mode(0),
        indi_data_ownership(true),
        draw_window(0) {
    SetDataValueType(_idvtype);
    SetDataSourceType(_idstype);
  };
  IndicatorParams(string _name, ENUM_IDATA_VALUE_TYPE _idvtype = TDBL1, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN)
      : name(_name),
        shift(0),
        max_modes(1),
        max_buffers(10),
        idstype(_idstype),
        is_draw(false),
        indi_color(clrNONE),
        indi_mode(0),
        indi_data_ownership(true),
        draw_window(0) {
    SetDataValueType(_idvtype);
    SetDataSourceType(_idstype);
  };
  /* Getters */
  string GetCustomIndicatorName() { return custom_indi_name; }
  color GetIndicatorColor() { return indi_color; }
  int GetIndicatorMode() { return indi_mode; }
  int GetMaxModes() { return (int)max_modes; }
  int GetShift() { return shift; }
  ENUM_IDATA_SOURCE_TYPE GetIDataSourceType() { return idstype; }
  ENUM_IDATA_VALUE_TYPE GetIDataValueType() { return idvtype; }
  /* Setters */
  void SetCustomIndicatorName(string _name) { custom_indi_name = _name; }
  void SetDataSourceType(ENUM_IDATA_SOURCE_TYPE _idstype) { idstype = _idstype; }
  void SetDataValueType(ENUM_IDATA_VALUE_TYPE _idata_type) {
    idvtype = _idata_type;
    dtype = idvtype >= TINT1 && idvtype <= TINT5 ? TYPE_INT : TYPE_DOUBLE;
  }
  void SetDataValueType(ENUM_DATATYPE _datatype) {
    dtype = _datatype;
    switch (max_modes) {
      case 1:
        idvtype = _datatype == TYPE_DOUBLE ? TDBL1 : TINT1;
        break;
      case 2:
        idvtype = _datatype == TYPE_DOUBLE ? TDBL2 : TINT2;
        break;
      case 3:
        idvtype = _datatype == TYPE_DOUBLE ? TDBL3 : TINT3;
        break;
      case 4:
        idvtype = _datatype == TYPE_DOUBLE ? TDBL4 : TINT4;
        break;
      case 5:
        idvtype = _datatype == TYPE_DOUBLE ? TDBL5 : TINT5;
        break;
    }
  }
  void SetDraw(bool _draw = true, int _window = 0) {
    is_draw = _draw;
    draw_window = _window;
  }
  void SetDraw(color _clr, int _window = 0) {
    is_draw = true;
    indi_color = _clr;
    draw_window = _window;
  }
  void SetIndicatorColor(color _clr) { indi_color = _clr; }
  void SetIndicatorData(Indicator* _indi, bool take_ownership = true) {
    if (indi_data != NULL && indi_data_ownership) {
      delete indi_data;
    };
    indi_data = _indi;
    idstype = IDATA_INDICATOR;
    indi_data_ownership = take_ownership;
  }
  void SetIndicatorMode(int mode) { indi_mode = mode; }
  void SetIndicatorType(ENUM_INDICATOR_TYPE _itype) { itype = _itype; }
  void SetMaxModes(int _max_modes) { max_modes = _max_modes; }
  void SetName(string _name) { name = _name; };
  void SetShift(int _shift) { shift = _shift; }
  void SetSize(int _size) { max_buffers = _size; };
};

struct IndicatorState {
  int handle;       // Indicator handle (MQL5 only).
  bool is_changed;  // Set when params has been recently changed.
  bool is_ready;    // Set when indicator is ready (has valid values).
  void IndicatorState() : handle(INVALID_HANDLE), is_changed(true), is_ready(false) {}
  int GetHandle() { return handle; }
  bool IsChanged() { return is_changed; }
  bool IsReady() { return is_ready; }
};
