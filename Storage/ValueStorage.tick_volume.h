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
 * Tick volume getter version of ValueStorage.
 */

// Includes.
#include "ObjectsCache.h"
#include "ValueStorage.history.h"

/**
 * Storage to retrieve tick volume.
 */
class TickVolumeValueStorage : public HistoryValueStorage<long> {
 public:
  /**
   * Constructor.
   */
  TickVolumeValueStorage(IndicatorBase *_indi_candle) : HistoryValueStorage(_indi_candle) {}

  /**
   * Copy constructor.
   */
  TickVolumeValueStorage(TickVolumeValueStorage &_r) : HistoryValueStorage(_r.indi_candle.Ptr()) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  long Fetch(int _shift) override { return indi_candle REF_DEREF GetVolume(RealShift(_shift)); }
};
