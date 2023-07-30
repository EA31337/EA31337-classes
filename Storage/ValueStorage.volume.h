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
 * Volume getter version of ValueStorage.
 */

// Includes.
#include "ObjectsCache.h"
#include "ValueStorage.history.h"

/**
 * Storage to retrieve volume.
 */
class VolumeValueStorage : public HistoryValueStorage<long> {
 public:
  /**
   * Constructor.
   */
  VolumeValueStorage(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : HistoryValueStorage(_symbol, _tf) {}

  /**
   * Copy constructor.
   */
  VolumeValueStorage(const VolumeValueStorage &_r) : HistoryValueStorage(_r.symbol, _r.tf) {}

  /**
   * Returns pointer to VolumeValueStorage of a given symbol and time-frame.
   */
  static VolumeValueStorage *GetInstance(string _symbol, ENUM_TIMEFRAMES _tf) {
    VolumeValueStorage *_storage;
    string _key = _symbol + "/" + IntegerToString((int)_tf);
    if (!ObjectsCache<VolumeValueStorage>::TryGet(_key, _storage)) {
      _storage = ObjectsCache<VolumeValueStorage>::Set(_key, new VolumeValueStorage(_symbol, _tf));
    }
    return _storage;
  }

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual long Fetch(int _shift) {
    ResetLastError();
    long _volume = iVolume(symbol, tf, RealShift(_shift));
    if (_LastError != ERR_NO_ERROR) {
      Print("Cannot fetch iVolume! Error: ", _LastError);
      DebugBreak();
    }
    return _volume;
  }
};
