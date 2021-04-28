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

#include "Account.mqh"
#include "Convert.mqh"
#include "Order.struct.h"
#include "Terminal.mqh"
#include "Trade.mqh"

/**
 * Class to provide a summary report.
 */
class SummaryReport {

  protected:

    // Variables.
    double init_deposit;
    double summary_profit;
    double gross_profit;
    double gross_loss;
    double max_profit;
    double min_profit;
    double con_profit1;
    double con_profit2;
    double con_loss1;
    double con_loss2;
    double max_loss;
    double max_dd;
    double max_dd_pct;
    double rel_dd_pct;
    double rel_dd;
    double expected_payoff;
    double profit_factor;
    double abs_dd;
    int    summary_trades;
    int    profit_trades;
    int    loss_trades;
    int    short_trades;
    int    long_trades;
    int    win_short_trades;
    int    win_long_trades;
    int    con_profit_trades1;
    int    con_profit_trades2;
    int    con_loss_trades1;
    int    con_loss_trades2;
    int    avg_con_wins;
    int    avg_con_losses;

    double init_balance;

  public:

    /**
     * Default constructor.
     */
    SummaryReport() {
      InitVars(Account::AccountBalance());
    }

    /**
     * Constructor to initialize starting balance.
     */
    SummaryReport(double deposit) {
      InitVars(deposit);
    }

    /**
     * Constructor to initialize starting balance.
     */
    void InitVars(double deposit = 0) {
      init_deposit = deposit;
      max_loss = deposit;
      summary_profit = 0.0;
      gross_profit = 0.0;
      gross_loss = 0.0;
      max_profit = 0.0;
      min_profit = 0.0;
      con_profit1 = 0.0;
      con_profit2 = 0.0;
      con_loss1 = 0.0;
      con_loss2 = 0.0;
      max_dd = 0.0;
      max_dd_pct = 0.0;
      rel_dd_pct = 0.0;
      rel_dd = 0.0;
      expected_payoff = 0.0;
      profit_factor = 0.0;
      abs_dd = 0.0;
      summary_trades = 0;
      profit_trades = 0;
      loss_trades = 0;
      short_trades = 0;
      long_trades = 0;
      win_short_trades = 0;
      win_long_trades = 0;
      con_profit_trades1 = 0;
      con_profit_trades2 = 0;
      con_loss_trades1 = 0;
      con_loss_trades2 = 0;
      avg_con_wins = 0;
      avg_con_losses = 0;
    }

    /**
     * Get initial deposit.
     */
    double GetInitDeposit() {
      static double deposit = 0;
      if (deposit > 0) {
        return deposit;
      }
      else if (!Terminal::IsRealtime() && init_deposit > 0) {
        deposit = init_deposit;
      } else {
        deposit = Account::CalcInitDeposit();
      }
      return (deposit);
    }

    /**
     * Calculates summary details.
     */
    void CalculateSummary() {
      int    sequence = 0, profitseqs = 0, loss_seqs = 0;
      double sequential = 0.0, prev_profit = EMPTY_VALUE, dd_pct, drawdown;
      double max_peak = init_deposit, min_peak = init_deposit, balance = init_deposit;
      int    trades_total = TradeHistoryStatic::HistoryOrdersTotal();
      double profit;

      // Initialize summaries.
      InitVars(init_deposit);

      for (int i = 0; i < trades_total; i++) {
        if (!Order::TryOrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
          continue;
        }
        int type = Order::OrderType();
        // Initial balance not considered.
        if (i == 0 && type == ACC_OP_BALANCE) continue;
        // Calculate profit.
        profit = OrderStatic::Profit() + OrderStatic::Commission() + Order::OrderSwap();
        balance += profit;
        // Drawdown check.
        if (max_peak < balance) {
          drawdown = max_peak-min_peak;
          if (max_peak != 0.0) {
            dd_pct = drawdown / max_peak * 100.0;
            if (rel_dd_pct < dd_pct) {
              rel_dd_pct = dd_pct;
              rel_dd = drawdown;
            }
          }
          if (max_dd < drawdown) {
            max_dd = drawdown;
            max_dd_pct = max_peak != 0.0 ? max_dd / max_peak * 100.0 : 100.0;
          }
          max_peak = balance;
          min_peak = balance;
        }
        if (min_peak > balance) min_peak = balance;
        if (max_loss > balance) max_loss = balance;
        // Market orders only.
        if (type != ORDER_TYPE_BUY && type != ORDER_TYPE_SELL) continue;
        // Calculate profit in points.
        // profit = (OrderClosePrice() - OrderOpenPrice()) / MarketInfo(OrderSymbol(), MODE_POINT);
        summary_profit += profit;
        summary_trades++;
        if (type == ORDER_TYPE_BUY) {
          long_trades++;
        }
        else if (type == ORDER_TYPE_SELL) {
          short_trades++;
        }
        if (profit < 0) {
          // Loss trades.
          loss_trades++;
          gross_loss += profit;
          if (min_profit > profit) min_profit = profit;
          // Fortune changed.
          if (prev_profit != EMPTY_VALUE && prev_profit >= 0) {
            if (con_profit_trades1 < sequence ||
                (con_profit_trades1 == sequence && con_profit2 < sequential)) {
              con_profit_trades1 = sequence;
              con_profit1 = sequential;
            }
            if (con_profit2 < sequential ||
                (con_profit2 == sequential && con_profit_trades1 < sequence)) {
              con_profit2 = sequential;
              con_profit_trades2 = sequence;
            }
            profitseqs++;
            avg_con_wins += sequence;
            sequence = 0;
            sequential = 0.0;
          }
        } else {
          // Profit trades (profit >= 0).
          profit_trades++;
          if (type == ORDER_TYPE_BUY) win_long_trades++;
          if (type == ORDER_TYPE_SELL) win_short_trades++;
          gross_profit += profit;
          if (max_profit < profit) max_profit = profit;
          // Fortune changed.
          if (prev_profit != EMPTY_VALUE && prev_profit < 0) {
            if (con_loss_trades1 < sequence ||
                (con_loss_trades1 == sequence && con_loss2 > sequential)) {
              con_loss_trades1 = sequence;
              con_loss1 = sequential;
            }
            if (con_loss2 > sequential ||
                (con_loss2 == sequential && con_loss_trades1 < sequence)) {
              con_loss2 = sequential;
              con_loss_trades2 = sequence;
            }
            loss_seqs++;
            avg_con_losses += sequence;
            sequence = 0;
            sequential = 0.0;
          }
        }
        sequence++;
        sequential += profit;
        prev_profit = profit;
      }
      // Final drawdown check.
      drawdown = max_peak - min_peak;
      if (max_peak != 0.0) {
        dd_pct = drawdown / max_peak * 100.0;
        if (rel_dd_pct < dd_pct) {
          rel_dd_pct = dd_pct;
          rel_dd = drawdown;
        }
      }
      if (max_dd < drawdown) {
        max_dd = drawdown;
        max_dd_pct = max_peak != 0 ? max_dd / max_peak * 100.0 : 100.0;
      }
      // Consider last trade.
      if (prev_profit != EMPTY_VALUE) {
        profit = prev_profit;
        if (profit < 0) {
          if (con_loss_trades1 < sequence ||
              (con_loss_trades1 == sequence && con_loss2 > sequential)) {
            con_loss_trades1 = sequence;
            con_loss1 = sequential;
          }
          if (con_loss2 > sequential ||
              (con_loss2 == sequential && con_loss_trades1 < sequence)) {
            con_loss2 = sequential;
            con_loss_trades2 = sequence;
          }
          loss_seqs++;
          avg_con_losses += sequence;
        }
        else {
          if (con_profit_trades1 < sequence ||
              (con_profit_trades1 == sequence && con_profit2 < sequential)) {
            con_profit_trades1 = sequence;
            con_profit1 = sequential;
          }
          if (con_profit2 < sequential ||
              (con_profit2 == sequential && con_profit_trades1 < sequence)) {
            con_profit2 = sequential;
            con_profit_trades2 = sequence;
          }
          profitseqs++;
          avg_con_wins += sequence;
        }
      }
      // Collecting done.
      double dnum, profitkoef = 0.0, losskoef = 0.0, avg_profit = 0.0, avgloss = 0.0;
      // Average consecutive wins and losses.
      dnum = avg_con_wins;
      avg_con_wins = profitseqs > 0 ?  (int) (dnum / profitseqs + 0.5) : 0;
      dnum = avg_con_losses;
      avg_con_losses = loss_seqs > 0 ? (int) (dnum / loss_seqs + 0.5) : 0;
      // Absolute values.
      if (gross_loss < 0.0) gross_loss *=- 1.0;
      if (min_profit < 0.0) min_profit *=- 1.0;
      if (con_loss1 < 0.0)  con_loss1 *=- 1.0;
      if (con_loss2 < 0.0)  con_loss2 *=- 1.0;
      profit_factor = gross_loss > 0.0 ? gross_profit / gross_loss : 0.0;
      // Expected payoff.
      avg_profit = profit_trades > 0 ? gross_profit / profit_trades : 0;
      avgloss = loss_trades > 0 ? gross_loss / loss_trades : 0;
      if (summary_trades > 0) {
        profitkoef = 1.0 * profit_trades / summary_trades;
        losskoef = 1.0 * loss_trades / summary_trades;
        expected_payoff = profitkoef * avg_profit - losskoef * avgloss;
      }
      // Absolute drawdown.
      abs_dd = init_deposit - max_loss;
    }

    /**
     * Return summary report.
     */
    string GetReport(string sep = "\n", string _currency = "") {
      string output = "";
      _currency = _currency != "" ? _currency : AccountInfoString(ACCOUNT_CURRENCY);
      output += StringFormat("Currency pair symbol:                       %s", _Symbol) + sep;
      output += StringFormat("Initial deposit:                            %.2f %s", GetInitDeposit(), _currency) + sep;
      output += StringFormat("Total net profit:                           %.2f %s", summary_profit, _currency) + sep;
      output += StringFormat("Gross profit:                               %.2f %s", gross_profit, _currency) + sep;
      output += StringFormat("Gross loss:                                 %.2f %s", gross_loss, _currency)  + sep;
      output += StringFormat("Absolute drawdown:                          %.2f %s", abs_dd, _currency) + sep;
      output += StringFormat("Maximal drawdown:                           %.1f %s (%.1f%%)", max_dd, _currency, max_dd_pct) + sep;
      output += StringFormat("Relative drawdown:                          (%.1f%%) %.1f %s", rel_dd_pct, rel_dd, _currency) + sep;
      output += StringFormat("Profit factor:                              %.2f", profit_factor) + sep;
      output += StringFormat("Expected payoff:                            %.2f", expected_payoff) + sep;
      output += StringFormat("Trades total                                %d", summary_trades) + sep;
      output += StringFormat("Short positions (won %%):                    %d (%.1f%%)", short_trades, short_trades ? 100.0 * win_short_trades / short_trades : 0) + sep;
      output += StringFormat("Long positions (won %%):                     %d (%.1f%%)", long_trades, long_trades ? 100.0 * win_long_trades / long_trades : 0) + sep;
      output += StringFormat("Profit trades (%% of total):                 %d (%.1f%%)", profit_trades, profit_trades ? 100.0 * profit_trades / summary_trades : 0) + sep;
      output += StringFormat("Loss trades (%% of total):                   %d (%.1f%%)", loss_trades, loss_trades ? 100.0 * loss_trades / summary_trades : 0) + sep;
      output += StringFormat("Largest profit trade:                       %.2f", max_profit) + sep;
      output += StringFormat("Largest loss trade:                         %.2f", -min_profit) + sep;
      output += StringFormat("Average profit trade:                       %.2f", profit_trades ? gross_profit / profit_trades : 0) + sep;
      output += StringFormat("Average loss trade:                         %.2f", loss_trades ? -gross_loss / loss_trades : 0) + sep;
      output += StringFormat("Average consecutive wins:                   %.2f", avg_con_wins) + sep;
      output += StringFormat("Average consecutive losses:                 %.2f", avg_con_losses) + sep;
      output += StringFormat("Maximum consecutive wins (profit in money): %d (%.2f)", con_profit_trades1, con_profit1) + sep;
      output += StringFormat("Maximum consecutive losses (loss in money): %d (%.2f)", con_loss_trades1, -con_loss1) + sep;
      output += StringFormat("Maximal consecutive profit (count of wins): %.2f (%d)", con_profit2, con_profit_trades2) + sep;
      output += StringFormat("Maximal consecutive loss (count of losses): %.2f (%d)", con_loss2, con_loss_trades2) + sep;
      return output;
    }
};
