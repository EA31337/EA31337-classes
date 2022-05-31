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
#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/**
 * Tick & bar counter for IndicatorCandle/IndicatorTf.
 */
struct TickBarCounter {
  // Time of the last bar.
  datetime last_bar_time;

  // Index of the current bar.
  int bar_index;

  // Whether new bar happened in the current tick.
  bool is_new_bar;

  // Index of the current tick.
  int tick_index;

  /**
   * Increases current bar index (used in OnTick()). If there was no bar, the current bar will become 0.
   */
  void IncreaseBarIndex() { SetBarIndex(bar_index == -1 ? 0 : bar_index + 1); }

  /**
   * Increases current tick index (used in OnTick()). If there was no tick, the current tick will become 0.
   */
  void IncreaseTickIndex() { SetTickIndex(tick_index == -1 ? 0 : tick_index + 1); }

  /* Getters */

  /**
   * Returns current bar index (incremented every OnTick() if IsNewBar() is true).
   */
  int GetBarIndex() { return bar_index; }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  int GetTickIndex() { return tick_index; }

  /**
   * Check if there is a new bar to parse.
   */
  bool IsNewBarInternal(datetime _bar_time) {
    bool _result = false;
    if (last_bar_time != _bar_time) {
      SetLastBarTime(_bar_time);
      _result = true;
    }
    return _result;
  }

  /* Setters */

  /**
   * Sets current bar index.
   */
  void SetBarIndex(int _bar_index) { bar_index = _bar_index; }

  /**
   * Sets last bar time.
   */
  void SetLastBarTime(datetime _dt) { last_bar_time = _dt; }

  /**
   * Sets current tick index.
   */
  void SetTickIndex(int _tick_index) { tick_index = _tick_index; }

  /**
   * Updates tick & bar indices.
   */
  void OnTick(datetime _bar_time) {
    IncreaseTickIndex();

    if (is_new_bar) {
      // IsNewBar() will no longer signal new bar.
      is_new_bar = false;
    }

    if (IsNewBarInternal(_bar_time)) {
      IncreaseBarIndex();
      is_new_bar = true;
    } else {
      is_new_bar = false;
    }
  }
};
