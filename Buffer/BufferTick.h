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

// Prevents processing this includes file for the second time.
#ifndef BUFFER_TICK_H
#define BUFFER_TICK_H

// Includes.
#include "../BufferStruct.mqh"
#include "../Chart.enum.h"
#include "../Storage/IValueStorage.h"
#include "../Tick/Tick.struct.h"

// TV = Type of price stored by BufferTick. RV = Type of property to be retrieved from BufferTick.
template <typename TV, typename RV>
class BufferTickValueStorage : ValueStorage<TV> {
  // Poiner to buffer to take tick from.
  BufferTick<TV> *buffer_tick;

  // INDI_VS_TYPE_PRICE_ASK, INDI_VS_TYPE_PRICE_BID, INDI_VS_TYPE_SPREAD, INDI_VS_TYPE_TICK_VOLUME or
  // INDI_VS_TYPE_VOLUME.
  ENUM_INDI_VS_TYPE vs_type;

 public:
  /**
   * Constructor.
   */
  BufferTickValueStorage(BufferTick<TV> *_buffer_tick, ENUM_INDI_VS_TYPE _vs_type)
      : buffer_tick(_buffer_tick), vs_type(_vs_type) {}

  /**
   * Fetches value from a given datetime. Takes into consideration as-series flag.
   */
  TV Fetch(datetime _dt) override {
    switch (vs_type) {
      case INDI_VS_TYPE_PRICE_ASK:
        return (TV)buffer_tick PTR_DEREF GetByKey(_dt).ask;
      case INDI_VS_TYPE_PRICE_BID:
        return (TV)buffer_tick PTR_DEREF GetByKey(_dt).bid;
      case INDI_VS_TYPE_SPREAD:
        // return (TV)buffer_tick PTR_DEREF GetByKey(_dt).spread;
      case INDI_VS_TYPE_TICK_VOLUME:
        // return (TV)buffer_tick PTR_DEREF GetByKey(_dt).tick_volume;
      case INDI_VS_TYPE_VOLUME:
        // return (TV)buffer_tick PTR_DEREF GetByKey(_dt).volume;
        break;
    }
    Print("Not yet supported value storage to fetch: ", EnumToString(vs_type), ".");
    return (RV)0;
  }

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  int Size() override { return (int)buffer_tick.Size(); }
};

/**
 * Class to store struct data.
 */
template <typename TV>
class BufferTick : public BufferStruct<TickAB<TV>> {
 protected:
  // Ask prices ValueStorage proxy.
  BufferTickValueStorage<TV, TV> *_vs_ask;

  // Bid prices ValueStorage proxy.
  BufferTickValueStorage<TV, TV> *_vs_bid;

  // Spread ValueStorage proxy.
  BufferTickValueStorage<TV, TV> *_vs_spread;

  // Volume ValueStorage proxy.
  BufferTickValueStorage<TV, int> *_vs_volume;

  // Tick Volume ValueStorage proxy.
  BufferTickValueStorage<TV, int> *_vs_tick_volume;

 protected:
  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() {
    _vs_ask = NULL;
    _vs_bid = NULL;
    _vs_spread = NULL;
    _vs_volume = NULL;
    _vs_tick_volume = NULL;
    SetOverflowListener(BufferTickOverflowListener, 10);
  }

 public:
  /* Constructors */

  /**
   * Constructor.
   */
  BufferTick() { Init(); }
  BufferTick(BufferTick &_right) {
    THIS_REF = _right;
    Init();
  }

  /**
   * Destructor.
   */
  ~BufferTick() {
    if (_vs_ask != NULL) {
      delete _vs_ask;
    }
    if (_vs_bid != NULL) {
      delete _vs_bid;
    }
    if (_vs_spread != NULL) {
      delete _vs_spread;
    }
    if (_vs_volume != NULL) {
      delete _vs_volume;
    }
    if (_vs_tick_volume != NULL) {
      delete _vs_tick_volume;
    }
  }

  /**
   * Returns Ask prices ValueStorage proxy.
   */
  BufferTickValueStorage<TV, TV> *GetAskValueStorage() {
    if (_vs_ask == NULL) {
      _vs_ask = new BufferTickValueStorage<TV, TV>(THIS_PTR, INDI_VS_TYPE_PRICE_ASK);
    }
    return _vs_ask;
  }

  /**
   * Returns Bid prices ValueStorage proxy.
   */
  BufferTickValueStorage<TV, TV> *GetBidValueStorage() {
    if (_vs_bid == NULL) {
      _vs_bid = new BufferTickValueStorage<TV, TV>(THIS_PTR, INDI_VS_TYPE_PRICE_BID);
    }
    return _vs_bid;
  }

  /**
   * Returns Spread ValueStorage proxy.
   */
  BufferTickValueStorage<TV, TV> *GetSpreadValueStorage() {
    if (_vs_spread == NULL) {
      _vs_spread = new BufferTickValueStorage<TV, TV>(THIS_PTR, INDI_VS_TYPE_SPREAD);
    }
    return _vs_spread;
  }

  /**
   * Returns Volume ValueStorage proxy.
   */
  BufferTickValueStorage<TV, int> *GetVolumeValueStorage() {
    if (_vs_volume == NULL) {
      _vs_volume = new BufferTickValueStorage<TV, int>(THIS_PTR, INDI_VS_TYPE_VOLUME);
    }
    return _vs_volume;
  }

  /**
   * Returns Tick Volume ValueStorage proxy.
   */
  BufferTickValueStorage<TV, int> *GetTickVolumeValueStorage() {
    if (_vs_tick_volume == NULL) {
      _vs_tick_volume = new BufferTickValueStorage<TV, int>(THIS_PTR, INDI_VS_TYPE_TICK_VOLUME);
    }
    return _vs_tick_volume;
  }

  /* Grouping methods */

  /**
   * Group ticks by seconds.
   */
  DictStruct<unsigned int, DictStruct<unsigned int, TickAB<TV>>> GroupBySecs(unsigned int _spc) {
    // DictStruct<unsigned int, DictStruct<TickAB<TV>>> _result;
    // @todo: for each iter
    // for (DictStructIterator<unsigned int, DictStruct<TickAB<TV>>> iter(Begin()); iter.IsValid(); ++iter) {
    // Load timestamp from key, TickAB from value
    // foreach some timestamp mod % _spc - calculate shift
    // _result.Push(_shift, TickAB<TV>)
    // Convert to OHLC in upper method
    return NULL;
  }

  /* Callback methods */

  /**
   * Function should return true if resize can be made, or false to overwrite current slot.
   */
  static bool BufferTickOverflowListener(ENUM_DICT_OVERFLOW_REASON _reason, int _size, int _num_conflicts) {
    static int cache_limit = 86400;
    switch (_reason) {
      case DICT_OVERFLOW_REASON_FULL:
        // We allow resize if dictionary size is less than 86400 slots.
        return _size < cache_limit;
      case DICT_OVERFLOW_REASON_TOO_MANY_CONFLICTS:
      default:
        // When there is too many conflicts, we just reject doing resize, so first conflicting slot will be reused.
        break;
    }
    return false;
  }
};

#endif  // BUFFER_TICK_H
