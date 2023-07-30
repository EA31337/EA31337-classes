//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
#include "../Tick.struct.h"

template <typename TV>
class BufferTickValueStorage : ValueStorage<TV> {
  // Poiner to buffer to take tick from.
  BufferTick<TV> *buffer_tick;

  // PRICE_ASK or PRICE_BID.
  int applied_price;

 public:
  /**
   * Constructor.
   */
  BufferTickValueStorage(BufferTick<TV> *_buffer_tick, int _applied_price)
      : buffer_tick(_buffer_tick), applied_price(_applied_price) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  TV Fetch(int _shift) override {
    Print("BufferTickValueStorage: Fetching " + (applied_price == PRICE_ASK ? "Ask" : "Bid") + " price from shift ",
          _shift);
    return 0;
  }

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  int Size() const override { return (int)buffer_tick.Size(); }
};

/**
 * Class to store struct data.
 */
template <typename TV>
class BufferTick : public BufferStruct<TickAB<TV>> {
 protected:
  // Ask prices ValueStorage proxy.
  BufferTickValueStorage<TV> *_vs_ask;

  // Bid prices ValueStorage proxy.
  BufferTickValueStorage<TV> *_vs_bid;

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
  }

  /**
   * Returns Ask prices ValueStorage proxy.
   */
  BufferTickValueStorage<TV> *GetAskValueStorage() {
    if (_vs_ask == NULL) {
      _vs_ask = new BufferTickValueStorage<TV>(THIS_PTR, PRICE_ASK);
    }
    return _vs_ask;
  }

  /**
   * Returns Bid prices ValueStorage proxy.
   */
  BufferTickValueStorage<TV> *GetBidValueStorage() {
    if (_vs_bid == NULL) {
      _vs_bid = new BufferTickValueStorage<TV>(THIS_PTR, PRICE_BID);
    }
    return _vs_bid;
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
