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

// Ignore processing of this file if already included.
#ifndef INDICATOR_TICK_MQH
#define INDICATOR_TICK_MQH

// Includes.
#include "../IndicatorBase.h"
//#include "Array.mqh"
//#include "BufferStruct.mqh"
//#include "Chart.mqh"
//#include "DateTime.mqh"
//#include "DrawIndicator.mqh"
//#include "Indicator.define.h"
//#include "Indicator.enum.h"
//#include "Indicator.struct.cache.h"
//#include "Indicator.struct.h"
//#include "Indicator.struct.serialize.h"
//#include "Indicator.struct.signal.h"
//#include "IndicatorBase.h"
//#include "Math.h"
//#include "Object.mqh"
//#include "Refs.mqh"
//#include "Serializer.mqh"
//#include "SerializerCsv.mqh"
//#include "SerializerJson.mqh"
//#include "Storage/ValueStorage.h"
//#include "Storage/ValueStorage.indicator.h"
//#include "Storage/ValueStorage.native.h"

/**
 * Class to deal with tick indicators.
 */
// template <typename TS>
class IndicatorTick : public IndicatorBase {
 protected:
  BufferStruct<IndicatorDataEntry> tickdata;

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorTick() {}

  /* Virtual method implementations */

  /**
   * Returns the indicator's data entry.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  IndicatorDataEntry GetEntry(int _timestamp = 0) {
    IndicatorDataEntry _entry = tickdata.GetByKey(_timestamp);
    if (!_entry.IsValid() && !_entry.CheckFlag(INDI_ENTRY_FLAG_INSUFFICIENT_DATA)) {
      _entry.timestamp = _timestamp;
      _entry.Resize(4);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, IsValidEntry(_entry));
      for (int _mode = 0; _mode < (int)iparams.GetMaxModes(); _mode++) {
        //_entry.values[_mode] = GetValue(_mode, _shift); / @todo
      }
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      } else {
        _entry.AddFlags(INDI_ENTRY_FLAG_INSUFFICIENT_DATA);
      }
    }
    return _entry;
  }
};

#endif
