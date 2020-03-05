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

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Prevents processing this includes file for the second time.
#ifndef BUFFER_FXT_MQH
#define BUFFER_FXT_MQH

// Includes.
#include "DictStruct.mqh"

// Structs.
struct BufferFXTEntry {
  datetime          otm;                // Bar datetime.
  double            open;               // OHLCV values.
  double            high;
  double            low;
  double            close;
  long              volume;
  int               ctm;                // The current time within a bar.
  int               flag;               // Flag to launch an expert (0 - bar will be modified, but the expert will not be launched).

 public:
  bool operator==(const BufferFXTEntry& _s) {
    // @fixme
    return false;
  }
  string ToJSON() {
    // @fixme
    return "{}";
  }
};

// FXT file header.
struct BufferFXTHeader {
  int version;            // Header version: 405
  char copyright[64];     // Copyright/description.
  char description[128];  // Account server name.
                          // 196
  char symbol[12];        // Symbol pair.
  int period;             // Period of data aggregation in minutes (timeframe).
  int model;              // Model type: 0 - every tick, 1 - control points, 2 - bar open.
  int bars;               // Bars - number of modeled bars in history.
  int fromdate;           // Modelling start date - date of the first tick.
  int todate;             // Modelling end date - date of the last tick.
  int totalTicks;         // Total ticks. Add 4 bytes to align to the next double?
  double modelquality;    // Modeling quality (max. 99.9).
                          // 240
  // Market symbol properties.
  char currency[12];  // Base currency (12 bytes). Same as: StringLeft(symbol, 3)
  int spread;         // Spread in points. Same as: MarketInfo(MODE_SPREAD)
  int digits;         // Digits (default: 5). Same as: MarketInfo(MODE_DIGITS)
  int padding1;       // Padding space - add 4 bytes to align to the next double.
  double point;       // Point size (e.g. 0.00001). Same as: MarketInfo(MODE_POINT)
  int lot_min;        // Minimal lot size in centi lots (hundredths). Same as: MarketInfo(MODE_MINLOT)*100
  int lot_max;        // Maximal lot size in centi lots (hundredths). Same as: MarketInfo(MODE_MAXLOT)*100
  int lot_step;       // Lot step in centi lots (hundredths). Same as: MarketInfo(MODE_LOTSTEP)*100
  int stops_level;    // Stops level value (orders stop distance in points). Same as: MarketInfo(MODE_STOPLEVEL)
  int gtc_pendings;   // GTC (Good till cancel) - instruction to close pending orders at end of day (default: False).
  int padding2;       // Padding space - add 4 bytes to align to the next double.
                      // 296
  // Profit calculation parameters.
  double contract_size;  // Contract size (e.g. 100000). Same as: MarketInfo(MODE_LOTSIZE)
  double tick_value;     // Tick value in quote currency (empty). Same as: MarketInfo(MODE_TICKVALUE)
  double tick_size;      // Size of one tick (empty). Same as: MarketInfo(MODE_TICKSIZE)
  int profit_mode;  // Profit calculation mode { PROFIT_CALC_FOREX=0, PROFIT_CALC_CFD=1, PROFIT_CALC_FUTURES=2 }. Same
                    // as: MarketInfo(MODE_PROFITCALCMODE)
                    // 324
  // Swap calculation.
  int swap_enable;         // Enable swaps (default: True).
  int swap_type;           // Type of swap { SWAP_BY_POINTS=0, SWAP_BY_BASECURRENCY=1, SWAP_BY_INTEREST=2,
                           // SWAP_BY_MARGINCURRENCY=3 }. Same as: MarketInfo(MODE_SWAPTYPE)
  int padding3;            // Padding space - add 4 bytes to align to the next double.
  double swap_long;        // Swap of the buy order - long overnight swap value. Same as: MarketInfo(MODE_SWAPLONG)
  double swap_short;       // Swap of the sell order - short overnight swap value. Same as: MarketInfo(MODE_SWAPSHORT)
  int swap_rollover3days;  // Day of week to charge 3 days swap rollover. Default: WEDNESDAY (3). Same as:
                           // MarketInfo(SYMBOL_SWAP_ROLLOVER3DAYS)
                           // 356
  // Margin calculation.
  int leverage;          // Account leverage (default: 100). Same as: AccountLeverage()
  int free_margin_mode;  // Free margin calculation mode { MARGIN_DONT_USE=0, MARGIN_USE_ALL=1, MARGIN_USE_PROFIT=2,
                         // MARGIN_USE_LOSS=3 }. Same as: AccountFreeMarginMode()
  int margin_mode;       // Margin calculation mode { MARGIN_CALC_FOREX=0, MARGIN_CALC_CFD=1, MARGIN_CALC_FUTURES=2,
                         // MARGIN_CALC_CFDINDEX=3 }. Same as: MarketInfo(MODE_MARGINCALCMODE)
  int margin_stopout;    // Margin Stop Out level (default: 30). Same as: AccountStopoutLevel()

  int margin_stopout_mode;  // Check mode for Stop Out level { MARGIN_TYPE_PERCENT=0, MARGIN_TYPE_CURRENCY=1 }. Same as:
                            // AccountStopoutMode()
  double margin_initial;    // Initial margin requirement (in units). Same as: MarketInfo(MODE_MARGININIT)
  double margin_maintenance;  // Maintenance margin requirement (in units). Same as: MarketInfo(MODE_MARGINMAINTENANCE)
  double margin_hedged;   // Hedged margin requirement for positions (in units). Same as: MarketInfo(MODE_MARGINHEDGED)
  double margin_divider;  // Margin divider used for leverage calculation.
  char margin_currency[12];  // Margin currency. Same as: AccountCurrency().
  int padding4;              // Padding space - add 4 bytes to align to the next double.
                             // 424
  // Commission calculation.
  double comm_base;  // Basic commission rate.
  int comm_type;     // Basic commission type          { COMM_TYPE_MONEY=0, COMM_TYPE_PIPS=1, COMM_TYPE_PERCENT=2 }.
  int comm_lots;     // Commission per lot or per deal { COMMISSION_PER_LOT=0, COMMISSION_PER_DEAL=1 }
                     // 440
  // For internal use.
  int from_bar;          // Index of the first bar at which modeling started (0 for the first bar).
  int to_bar;            // Index of the last bar at which modeling started (0 for the last bar).
  int start_period_m1;   // Bar index where modeling started using M1 bars (0 for the first bar).
  int start_period_m5;   // Bar index where modeling started using M5 bars (0 for the first bar).
  int start_period_m15;  // Bar index where modeling started using M15 bars (0 for the first bar).
  int start_period_m30;  // Bar index where modeling started using M30 bars (0 for the first bar).
  int start_period_h1;   // Bar index where modeling started using H1 bars (0 for the first bar).
  int start_period_h4;   // Bar index where modeling started using H4 bars (0 for the first bar).
  int set_from;          // Begin date from tester settings (must be zero).
  int set_to;            // End date from tester settings (must be zero).
                         // 480
  //----
  int freeze_level;       // Order freeze level in points. Same as: MarketInfo(MODE_FREEZELEVEL)
  int generating_errors;  // Number of errors during model generation which needs to be fixed before testing.
                          // 488
  //----
  int reserved[60];  // Reserved - space for future use.
};

// Defines.
#define FXT_VERSION 405
// Profit calculation mode.
#define PROFIT_CALC_FOREX 0  // Default.
#define PROFIT_CALC_CFD 1
#define PROFIT_CALC_FUTURES 2
// Type of swap.
#define SWAP_BY_POINTS 0  // Default.
#define SWAP_BY_BASECURRENCY 1
#define SWAP_BY_INTEREST 2
#define SWAP_BY_MARGINCURRENCY 3
// Free margin calculation mode.
#define MARGIN_DONT_USE 0
#define MARGIN_USE_ALL 1  // Default.
#define MARGIN_USE_PROFIT 2
#define MARGIN_USE_LOSS 3
// Margin calculation mode.
#define MARGIN_CALC_FOREX 0  // Default.
#define MARGIN_CALC_CFD 1
#define MARGIN_CALC_FUTURES 2
#define MARGIN_CALC_CFDINDEX 3
// Basic commission type.
#define COMM_TYPE_MONEY 0
#define COMM_TYPE_PIPS 1
#define COMM_TYPE_PERCENT 2
// Commission per lot or per deal.
#define COMMISSION_PER_LOT 0
#define COMMISSION_PER_DEAL 1

string ToJSON(BufferFXTEntry& _value, const bool, const unsigned int) { return _value.ToJSON(); };

/**
 * Implements class to store tick data.
 */
class BufferFXT : public DictStruct<long, BufferFXTEntry> {
 public:
  BufferFXT() {}

  /**
   * Adds new entry.
   */
  void Add(BufferFXTEntry& _value, long _dt = 0) {
    _dt = _dt > 0 ? _dt : TimeCurrent();
    Set(_dt, _value);
  }

  /**
   * Adds new entry.
   */
  void Add(MqlTick& _value) {
    // @todo: Parse MqlTick.
    //Set(_dt, _value);
  }

  /**
   * Save data into file.
   */
  void SaveToFile() {
    // @todo: Save BufferFXTHeader, then foreach BufferFXTEntry.
    // @see: https://docs.mql4.com/files/filewritestruct
  }
};

#endif  // BUFFER_FXT_MQH
