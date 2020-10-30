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
 * Includes Strategy's structs.
 */

// Forward class declaration.
class Indicator;
class Strategy;
class Trade;

struct StgParams {
  // Strategy config parameters.
  bool is_enabled;           // State of the strategy (whether enabled or not).
  bool is_suspended;         // State of the strategy (whether suspended or not)
  bool is_boosted;           // State of the boost feature (to increase lot size).
  long id;                   // Identification number of the strategy.
  unsigned long magic_no;    // Magic number of the strategy.
  float weight;              // Weight of the strategy.
  int shift;                 // Shift (relative to the current bar, 0 - default)
  int signal_open_method;    // Signal open method.
  float signal_open_level;   // Signal open level.
  int signal_open_filter;    // Signal open filter method.
  int signal_open_boost;     // Signal open boost method (for lot size increase).
  int signal_close_method;   // Signal close method.
  float signal_close_level;  // Signal close level.
  int price_limit_method;    // Price limit method.
  float price_limit_level;   // Price limit level.
  int tick_filter_method;    // Tick filter.
  float lot_size;            // Lot size to trade.
  float lot_size_factor;     // Lot size multiplier factor.
  float max_risk;            // Maximum risk to take (1.0 = normal, 2.0 = 2x).
  float max_spread;          // Maximum spread to trade (in pips).
  int tp_max;                // Hard limit on maximum take profit (in pips).
  int sl_max;                // Hard limit on maximum stop loss (in pips).
  datetime refresh_time;     // Order refresh frequency (in sec).
  Ref<Log> logger;           // Reference to Log object.
  Trade *trade;              // Pointer to Trade class.
  Indicator *data;           // Pointer to Indicator class.
  Strategy *sl, *tp;         // Pointers to Strategy class (stop-loss and profit-take).
  // Constructor.
  StgParams(Trade *_trade = NULL, Indicator *_data = NULL, Strategy *_sl = NULL, Strategy *_tp = NULL)
      : trade(_trade),
        data(_data),
        sl(_sl),
        tp(_tp),
        is_enabled(true),
        is_suspended(false),
        is_boosted(true),
        magic_no(rand()),
        weight(0),
        signal_open_method(0),
        signal_open_level(0),
        signal_open_filter(0),
        signal_open_boost(0),
        signal_close_method(0),
        signal_close_level(0),
        price_limit_method(0),
        price_limit_level(0),
        tick_filter_method(0),
        lot_size(0),
        lot_size_factor(1.0),
        max_risk(1.0),
        max_spread(0.0),
        tp_max(0),
        sl_max(0),
        refresh_time(0),
        logger(new Log) {
    InitLotSize();
  }
  StgParams(int _som, int _sof, float _sol, int _sob, int _scm, float _scl, int _plm, float _pll, int _tfm, float _ms,
            int _s = 0)
      : signal_open_method(_som),
        signal_open_filter(_sof),
        signal_open_level(_sol),
        signal_open_boost(_sob),
        signal_close_method(_scm),
        signal_close_level(_scl),
        price_limit_method(_plm),
        price_limit_level(_pll),
        tick_filter_method(_tfm),
        shift(_s),
        is_enabled(true),
        is_suspended(false),
        is_boosted(true),
        magic_no(rand()),
        weight(0),
        lot_size(0),
        lot_size_factor(1.0),
        max_risk(1.0),
        max_spread(0.0),
        tp_max(0),
        sl_max(0),
        refresh_time(0),
        logger(new Log) {
    InitLotSize();
  }
  StgParams(StgParams &_stg_params) { this = _stg_params; }
  // Deconstructor.
  ~StgParams() {}
  // Struct methods.
  void InitLotSize() {
    if (Object::IsValid(trade)) {
      lot_size = (float)GetChart().GetVolumeMin();
    }
  }
  // Getters.
  Chart *GetChart() { return Object::IsValid(trade) ? trade.Chart() : NULL; }
  Indicator *GetIndicator() { return data; }
  Log *GetLog() { return logger.Ptr(); }
  bool IsBoosted() { return is_boosted; }
  bool IsEnabled() { return is_enabled; }
  bool IsSuspended() { return is_suspended; }
  float GetLotSize() { return lot_size; }
  float GetLotSizeFactor() { return lot_size_factor; }
  float GetLotSizeWithFactor() { return lot_size * lot_size_factor; }
  float GetMaxRisk() { return max_risk; }
  float GetMaxSpread() { return max_spread; }
  int GetShift() { return shift; }
  // Setters.
  void SetId(long _id) { id = _id; }
  void SetIndicator(Indicator *_indi) { data = _indi; }
  void SetLotSize(float _lot_size) { lot_size = _lot_size; }
  void SetLotSizeFactor(float _lot_size_factor) { lot_size_factor = _lot_size_factor; }
  void SetMagicNo(unsigned long _mn) { magic_no = _mn; }
  void SetStops(Strategy *_sl = NULL, Strategy *_tp = NULL) {
    sl = _sl;
    tp = _tp;
  }
  void SetTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) { trade = new Trade(_tf, _symbol); }
  void SetShift(int _shift) { shift = _shift; }
  void SetSignals(int _open_method, float _open_level, int _open_filter, int _open_boost, int _close_method,
                  float _close_level) {
    signal_open_method = _open_method;
    signal_open_level = _open_level;
    signal_open_filter = _open_filter;
    signal_open_boost = _open_boost;
    signal_close_method = _close_method;
    signal_close_level = _close_level;
  }
  void SetPriceLimits(int _method, float _level) {
    price_limit_method = _method;
    price_limit_level = _level;
  }
  void SetTickFilter(int _method) { tick_filter_method = _method; }
  void SetMaxSpread(float _spread) { max_spread = _spread; }
  void SetMaxRisk(float _risk) { max_risk = _risk; }
  void Enabled(bool _is_enabled) { is_enabled = _is_enabled; };
  void Suspended(bool _is_suspended) { is_suspended = _is_suspended; };
  void Boost(bool _is_boosted) { is_boosted = _is_boosted; };
  void DeleteObjects() {
    Object::Delete(data);
    Object::Delete(sl);
    Object::Delete(tp);
    Object::Delete(trade);
  }
  // Printers.
  string ToString() {
    return StringFormat("Enabled:%s;Suspended:%s;Boosted:%s;Id:%d,MagicNo:%d;Weight:%.2f;" + "SOM:%d,SOL:%.2f;" +
                            "SCM:%d,SCL:%.2f;" + "PLM:%d,PLL:%.2f;" + "LS:%.2f(Factor:%.2f);MS:%.2f;",
                        // @todo: "Data:%s;SL/TP-Strategy:%s/%s",
                        is_enabled ? "Yes" : "No", is_suspended ? "Yes" : "No", is_boosted ? "Yes" : "No", id, magic_no,
                        weight, signal_open_method, signal_open_level, signal_close_method, signal_close_level,
                        price_limit_method, price_limit_level, lot_size, lot_size_factor, max_spread
                        // @todo: data, sl, tp
    );
  }
};

// Defines struct for individual strategy's param values.
struct Stg_Params {
  string symbol;
  ENUM_TIMEFRAMES tf;
  Stg_Params() : symbol(_Symbol), tf((ENUM_TIMEFRAMES)_Period) {}
};

// Defines struct to store results for signal processing.
struct StgProcessResult {
  unsigned int last_error;          // Last error code.
  unsigned short pos_closed;        // Number of positions closed.
  unsigned short pos_opened;        // Number of positions opened.
  unsigned short pos_updated;       // Number of positions updated.
  unsigned short stops_invalid_sl;  // Number of invalid stop-loss values.
  unsigned short stops_invalid_tp;  // Number of invalid take-profit values.
  StgProcessResult() { Reset(); }
  void ProcessLastError() { last_error = fmax(last_error, Terminal::GetLastError()); }
  void Reset() {
    pos_closed = pos_opened = pos_updated = stops_invalid_sl = stops_invalid_tp = 0;
    last_error = ERR_NO_ERROR;
  }
  string ToString() {
    return StringFormat("%d,%d,%d,%d,%d,%d", pos_closed, pos_opened, pos_updated, stops_invalid_sl, stops_invalid_tp,
                        last_error);
  }
};

// Strategy statistics.
struct StgStats {
  uint orders_open;  // Number of current opened orders.
  uint errors;       // Count reported errors.
};

// Strategy statistics per period.
struct StgStatsPeriod {
  // Statistics variables.
  uint orders_total;     // Number of total opened orders.
  uint orders_won;       // Number of total won orders.
  uint orders_lost;      // Number of total lost orders.
  double avg_spread;     // Average spread.
  double net_profit;     // Total net profit.
  double gross_profit;   // Total gross profit.
  double gross_loss;     // Total gross loss.
  double profit_factor;  // Profit factor.
  // Getters.
  string ToCSV() {
    return StringFormat("%d,%d,%d,%g,%g,%g,%g,%g", orders_total, orders_won, orders_lost, avg_spread, net_profit,
                        gross_profit, gross_loss, profit_factor);
  }
};

// Defines struct to store strategy data.
struct StgEntry {
  StgStatsPeriod stats_period[FINAL_ENUM_STRATEGY_STATS_PERIOD];
  string ToCSV() {
    return StringFormat("%s,%s,%s,%s", stats_period[EA_STATS_DAILY].ToCSV(), stats_period[EA_STATS_WEEKLY].ToCSV(),
                        stats_period[EA_STATS_MONTHLY].ToCSV(), stats_period[EA_STATS_TOTAL].ToCSV());
  }
  // Struct setters.
  void SetStats(StgStatsPeriod &_stats, ENUM_STRATEGY_STATS_PERIOD _period) { stats_period[_period] = _stats; }
};
