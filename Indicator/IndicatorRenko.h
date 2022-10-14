//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * An abstract class to implement Renko indicators.
 */

// Ignore processing of this file if already included.
#ifndef INDICATOR_RENKO_H
#define INDICATOR_RENKO_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Chart.struct.tf.h"
#include "IndicatorCandle.h"
#include "IndicatorRenko.provider.h"
#include "IndicatorRenko.struct.h"

/**
 * Renko candle type.
 */
enum ENUM_INDI_RENKO_CANDLE_TYPE {
  INDI_RENKO_CANDLE_TYPE_NONE,   // Empty candle.
  INDI_RENKO_CANDLE_TYPE_RAISE,  // Green candle.
  INDI_RENKO_CANDLE_TYPE_DROP,   // Red candle.
};

/**
 * Renko indicator parameters.
 */
struct RenkoParams : IndicatorTfParams {
  int pips_limit;

  RenkoParams(int _pips_limit = 10, int _shift = 0) : IndicatorTfParams("Renko") {
    pips_limit = _pips_limit;
    shift = _shift;
  };
  RenkoParams(RenkoParams &_params) : IndicatorTfParams("Renko") { THIS_REF = _params; };

  // Getters.
  unsigned int GetSecsPerCandle() {
    // Renko doesn't use timeframe-based candles.
    return 0;
  }
};

/**
 * Renko candles.
 *
 * Note that Renko acts as a Candle indicator and thus has the same number of
 * modes and same list of ValueStorage buffers as IndicatorCandle one.
 */
class IndicatorRenko : public IndicatorCandle<RenkoParams, double, ItemsHistoryRenkoCandleProvider<double>> {
 protected:
  // @todo Time-frame used to create candles.
  ENUM_TIMEFRAMES tf;

  long last_entry_ts;
  long last_completed_candle_ts;
  long last_incomplete_candle_ts;

  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() {
    last_entry_ts = 0;
    last_completed_candle_ts = 0;
    last_incomplete_candle_ts = 0;
  }

 public:
  /* Special methods */

  /**
   * Class constructor with timeframe enum.
   */
  IndicatorRenko(int _pips_limit = 10) {
    iparams.pips_limit = _pips_limit;
    Init();
  }

  /**
   * Class constructor with parameters.
   */
  IndicatorRenko(RenkoParams &_params)
      : IndicatorCandle<RenkoParams, double, ItemsHistoryRenkoCandleProvider<double>>(
            _params, IndicatorDataParams(FINAL_INDI_CANDLE_MODE_ENTRY)) {
    Init();
  }

  /**
   * Checks whether given candle is a raise (green) or drop (red).
   */
  ENUM_INDI_RENKO_CANDLE_TYPE GetCandleType(CandleOCTOHLC<double> &_candle) {
    if (_candle.close > _candle.open) {
      return INDI_RENKO_CANDLE_TYPE_RAISE;
    }

    if (_candle.close < _candle.open) {
      return INDI_RENKO_CANDLE_TYPE_DROP;
    }

    Print("Error: Candle's close price cannot equal open price!");
    DebugBreak();
    return INDI_RENKO_CANDLE_TYPE_NONE;
  }

  /**
   * Checks for pips limit.
   */
  bool RenkoConditionMet(ENUM_INDI_RENKO_CANDLE_TYPE _last_candle_type, CandleOCTOHLC<double> &_candle, double _price) {
    double _price_diff_limit = GetSymbolProps().GetPipValue() * iparams.pips_limit;
    double _price_diff = _price - _candle.open;

    if (_last_candle_type == INDI_RENKO_CANDLE_TYPE_NONE) {
      // No candle and then raise/drop requires just normal difference of pips.
      if (MathAbs(_price_diff) > _price_diff_limit) {
        return true;
      }
    } else {
      if (_last_candle_type == INDI_RENKO_CANDLE_TYPE_RAISE) {
        if (_price_diff > _price_diff_limit) {
          // Raising after raise.
          return true;
        } else if (_price_diff < -_price_diff_limit * 2) {
          // Drop after raise requires 2 x pips drop.
          return true;
        }
      } else if (_last_candle_type == INDI_RENKO_CANDLE_TYPE_DROP) {
        if (_price_diff > _price_diff_limit * 2) {
          // Raising after drop requires 2 x pips raise.
          return true;
        } else if (_price_diff < -_price_diff_limit) {
          // Drop after drop.
          return true;
        }
      }
    }

    return false;
  }

  /**
   * Called when data source emits new entry (historic or future one).
   */
  void OnDataSourceEntry(IndicatorDataEntry &entry) override{
      /*
      @todo Move logic into ItemsHistoryRenkoCandleProvider class.
      
      if (entry.timestamp < last_entry_ts) {
        Print("Error: IndicatorRenko doesn't support sending entries in non-ascending order!");
        DebugBreak();
      }

      // We'll be updating candle from bid price.
      double _price = entry[1];

      CandleOCTOHLC<double> _candle;
      CandleOCTOHLC<double> _last_completed_candle;
      ENUM_INDI_RENKO_CANDLE_TYPE _last_completed_candle_type;

      if (last_completed_candle_ts != 0) {
        _last_completed_candle = icdata.GetByKey(last_completed_candle_ts);
        _last_completed_candle_type = GetCandleType(_last_completed_candle);
      } else {
        _last_completed_candle_type = INDI_RENKO_CANDLE_TYPE_NONE;
      }

      if (last_incomplete_candle_ts != 0) {
        // There is previous candle. Retrieving and updating it.
        _candle = icdata.GetByKey(last_incomplete_candle_ts);
        _candle.Update(entry.timestamp, _price);

        // Checking for close price difference.
        if (RenkoConditionMet(_last_completed_candle_type, _candle, _price)) {
          // Closing current candle.
          _candle.is_complete = true;
        }

        // Updating candle.
        icdata.Add(_candle, last_incomplete_candle_ts);

        Print("Updated Candle: ", _candle.ToString());

        if (_candle.is_complete) {
          last_completed_candle_ts = last_incomplete_candle_ts;
          last_incomplete_candle_ts = 0;
        }
      } else {
        // There is no incomplete candle, creating one.
        if (last_completed_candle_ts != 0) {
          // Price of the last candle will be used to initialize open price for new, incomplete candle.
          double _last_close_price = _last_completed_candle.close;
          _candle = CandleOCTOHLC<double>(_last_close_price, _last_close_price, _last_close_price, _last_close_price,
                                          entry.timestamp, entry.timestamp);
          // Current price will be added to newly created incomplete candle.
          _candle.Update(entry.timestamp, _price);
        } else {
          // There was no completed candle. Creating new, incomplete candle from current price.
          _candle = CandleOCTOHLC<double>(_price, _price, _price, _price, entry.timestamp, entry.timestamp);
        }

        _candle.is_complete = false;

        // Creating new candle.
        icdata.Add(_candle, entry.timestamp);

        Print("Added candle: ", _candle.ToString(), " now there is ", icdata.Size(), " candles in the buffer.");

        last_incomplete_candle_ts = entry.timestamp;
      }

      static int iteration = 0;

      ++iteration;

      Print("Iteration: ", iteration);

      if (iteration > 1793) {
        // Print(icdata.ToJSON());
      }

      Print("Last Incomplete Time:   ", TimeToString(last_incomplete_candle_ts, TIME_DATE | TIME_MINUTES |
      TIME_SECONDS), " (", last_incomplete_candle_ts, ")"); Print("Last Incomplete Candle: ",
      icdata.GetByKey(last_incomplete_candle_ts).ToString()); Print("Last Completed Time:    ",
      TimeToString(last_completed_candle_ts, TIME_DATE | TIME_MINUTES | TIME_SECONDS), " (", last_completed_candle_ts,
      ")"); Print("Last Completed Candle:  ", icdata.GetByKey(last_completed_candle_ts).ToString());

      // Updating tick & bar indices. Bar time is time of the last completed candle.
      // Print(last_completed_candle_ts);
      counter.OnTick(last_completed_candle_ts);

      Print("---------");

      last_entry_ts = entry.timestamp;
      */
  };

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() override { return tf; }

  /**
   * Returns time of the bar for a given shift.
   *
   * Note: For Renko it returns last completed bar.
   */
  datetime GetBarTime(int _shift = 0) override {
    if (_shift != 0) {
      Print("Error: IndicatorRenko doesn't yet support shift other than 0!");
      DebugBreak();
      return 0;
    }

    return (datetime)last_completed_candle_ts;
  }
};

#endif
