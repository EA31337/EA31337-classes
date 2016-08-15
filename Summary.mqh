#include "Check.mqh"
/*
 * Class to provide summary report.
 */
class Summary {
  public:

#define OP_BALANCE 6
#define OP_CREDIT  7

    double InitialDeposit;
    double SummaryProfit;
    double GrossProfit;
    double GrossLoss;
    double MaxProfit;
    double MinProfit;
    double ConProfit1;
    double ConProfit2;
    double ConLoss1;
    double ConLoss2;
    double MaxLoss;
    double MaxDrawdown;
    double MaxDrawdownPercent;
    double RelDrawdownPercent;
    double RelDrawdown;
    double ExpectedPayoff;
    double ProfitFactor;
    double AbsoluteDrawdown;
    int    SummaryTrades;
    int    ProfitTrades;
    int    LossTrades;
    int    ShortTrades;
    int    LongTrades;
    int    WinShortTrades;
    int    WinLongTrades;
    int    ConProfitTrades1;
    int    ConProfitTrades2;
    int    ConLossTrades1;
    int    ConLossTrades2;
    int    AvgConWinners;
    int    AvgConLosers;

    /**
     * Calculates initial deposit based on the current balance and previous orders.
     */
    double CalculateInitialDeposit() {
      static double initial_deposit = 0;
      if (initial_deposit > 0) {
        return initial_deposit;
      }
      else if (!Check::IsRealtime()) {
        initial_deposit = init_balance;
      } else {
        initial_deposit = AccountBalance();
        for (int i = HistoryTotal()-1; i>=0; i--) {
          if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) continue;
          int type = OrderType();
          //---- initial balance not considered
          if (i == 0 && type == OP_BALANCE) break;
          if (type == OP_BUY || type == OP_SELL) {
            //---- calculate profit
            double profit=OrderProfit() + OrderCommission() + OrderSwap();
            //---- and decrease balance
            initial_deposit -= profit;
          }
          if (type==OP_BALANCE || type==OP_CREDIT) {
            initial_deposit -= OrderProfit();
          }
        }
      }
      return (initial_deposit);
    }

    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    void CalculateSummary(double initial_deposit)
    {
      int    sequence=0, profitseqs=0, lossseqs=0;
      double sequential=0.0, prevprofit=EMPTY_VALUE, drawdownpercent, drawdown;
      double maxpeak=initial_deposit, minpeak=initial_deposit, balance=initial_deposit;
      int    trades_total = HistoryTotal();
      double profit;
      //---- initialize summaries
      InitializeSummaries(initial_deposit);
      //----
      for (int i = 0; i < trades_total; i++) {
        if (!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
        int type=OrderType();
        //---- initial balance not considered
        if (i == 0 && type == OP_BALANCE) continue;
        //---- calculate profit
        profit = OrderProfit() + OrderCommission() + OrderSwap();
        balance += profit;
        //---- drawdown check
        if(maxpeak<balance) {
          drawdown=maxpeak-minpeak;
          if(maxpeak!=0.0) {
            drawdownpercent=drawdown/maxpeak*100.0;
            if(RelDrawdownPercent<drawdownpercent) {
              RelDrawdownPercent=drawdownpercent;
              RelDrawdown=drawdown;
            }
          }
          if(MaxDrawdown < drawdown) {
            MaxDrawdown = drawdown;
            if (maxpeak != 0.0) MaxDrawdownPercent = MaxDrawdown / maxpeak * 100.0;
            else MaxDrawdownPercent=100.0;
          }
          maxpeak = balance;
          minpeak = balance;
        }
        if (minpeak > balance) minpeak = balance;
        if (MaxLoss > balance) MaxLoss = balance;
        //---- market orders only
        if (type != OP_BUY && type != OP_SELL) continue;
        //---- calculate profit in points
        // profit=(OrderClosePrice()-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT);
        SummaryProfit += profit;
        SummaryTrades++;
        if (type == OP_BUY) LongTrades++;
        else             ShortTrades++;
        if(profit<0) { //---- loss trades
          LossTrades++;
          GrossLoss+=profit;
          if(MinProfit>profit) MinProfit=profit;
          //---- fortune changed
          if(prevprofit!=EMPTY_VALUE && prevprofit>=0)
          {
            if(ConProfitTrades1<sequence ||
                (ConProfitTrades1==sequence && ConProfit2<sequential))
            {
              ConProfitTrades1=sequence;
              ConProfit1=sequential;
            }
            if(ConProfit2<sequential ||
                (ConProfit2==sequential && ConProfitTrades1<sequence))
            {
              ConProfit2=sequential;
              ConProfitTrades2=sequence;
            }
            profitseqs++;
            AvgConWinners+=sequence;
            sequence=0;
            sequential=0.0;
          }
        } else { //---- profit trades (profit>=0)
          ProfitTrades++;
          if(type==OP_BUY)  WinLongTrades++;
          if(type==OP_SELL) WinShortTrades++;
          GrossProfit+=profit;
          if(MaxProfit<profit) MaxProfit=profit;
          //---- fortune changed
          if(prevprofit!=EMPTY_VALUE && prevprofit<0)
          {
            if(ConLossTrades1<sequence ||
                (ConLossTrades1==sequence && ConLoss2>sequential))
            {
              ConLossTrades1=sequence;
              ConLoss1=sequential;
            }
            if(ConLoss2>sequential ||
                (ConLoss2==sequential && ConLossTrades1<sequence))
            {
              ConLoss2=sequential;
              ConLossTrades2=sequence;
            }
            lossseqs++;
            AvgConLosers+=sequence;
            sequence=0;
            sequential=0.0;
          }
        }
        sequence++;
        sequential+=profit;
        prevprofit=profit;
      }
      //---- final drawdown check
      drawdown = maxpeak - minpeak;
      if (maxpeak != 0.0) {
        drawdownpercent = drawdown / maxpeak * 100.0;
        if (RelDrawdownPercent < drawdownpercent) {
          RelDrawdownPercent = drawdownpercent;
          RelDrawdown = drawdown;
        }
      }
      if (MaxDrawdown < drawdown) {
        MaxDrawdown = drawdown;
        if (maxpeak != 0) MaxDrawdownPercent = MaxDrawdown / maxpeak * 100.0;
        else MaxDrawdownPercent = 100.0;
      }
      //---- consider last trade
      if(prevprofit!=EMPTY_VALUE)
      {
        profit=prevprofit;
        if(profit<0)
        {
          if(ConLossTrades1<sequence ||
              (ConLossTrades1==sequence && ConLoss2>sequential))
          {
            ConLossTrades1=sequence;
            ConLoss1=sequential;
          }
          if(ConLoss2>sequential ||
              (ConLoss2==sequential && ConLossTrades1<sequence))
          {
            ConLoss2=sequential;
            ConLossTrades2=sequence;
          }
          lossseqs++;
          AvgConLosers+=sequence;
        }
        else
        {
          if(ConProfitTrades1<sequence ||
              (ConProfitTrades1==sequence && ConProfit2<sequential))
          {
            ConProfitTrades1=sequence;
            ConProfit1=sequential;
          }
          if(ConProfit2<sequential ||
              (ConProfit2==sequential && ConProfitTrades1<sequence))
          {
            ConProfit2=sequential;
            ConProfitTrades2=sequence;
          }
          profitseqs++;
          AvgConWinners+=sequence;
        }
      }
      //---- collecting done
      double dnum, profitkoef=0.0, losskoef=0.0, avgprofit=0.0, avgloss=0.0;
      //---- average consecutive wins and losses
      dnum=AvgConWinners;
      if(profitseqs>0) AvgConWinners=dnum/profitseqs+0.5;
      dnum=AvgConLosers;
      if(lossseqs>0)   AvgConLosers=dnum/lossseqs+0.5;
      //---- absolute values
      if(GrossLoss<0.0) GrossLoss*=-1.0;
      if(MinProfit<0.0) MinProfit*=-1.0;
      if(ConLoss1<0.0)  ConLoss1*=-1.0;
      if(ConLoss2<0.0)  ConLoss2*=-1.0;
      //---- profit factor
      if (GrossLoss > 0.0) ProfitFactor = GrossProfit / GrossLoss;
      //---- expected payoff
      if (ProfitTrades > 0) avgprofit = GrossProfit / ProfitTrades;
      if (LossTrades > 0)   avgloss   = GrossLoss   / LossTrades;
      if (SummaryTrades > 0) {
        profitkoef = 1.0 * ProfitTrades / SummaryTrades;
        losskoef = 1.0 * LossTrades / SummaryTrades;
        ExpectedPayoff = profitkoef * avgprofit - losskoef * avgloss;
      }
      //---- absolute drawdown
      AbsoluteDrawdown = initial_deposit - MaxLoss;
    }
    //+------------------------------------------------------------------+
    //|                                                                  |
    //+------------------------------------------------------------------+
    void InitializeSummaries(double initial_deposit) {
      InitialDeposit=initial_deposit;
      MaxLoss=initial_deposit;
      SummaryProfit=0.0;
      GrossProfit=0.0;
      GrossLoss=0.0;
      MaxProfit=0.0;
      MinProfit=0.0;
      ConProfit1=0.0;
      ConProfit2=0.0;
      ConLoss1=0.0;
      ConLoss2=0.0;
      MaxDrawdown=0.0;
      MaxDrawdownPercent=0.0;
      RelDrawdownPercent=0.0;
      RelDrawdown=0.0;
      ExpectedPayoff=0.0;
      ProfitFactor=0.0;
      AbsoluteDrawdown=0.0;
      SummaryTrades=0;
      ProfitTrades=0;
      LossTrades=0;
      ShortTrades=0;
      LongTrades=0;
      WinShortTrades=0;
      WinLongTrades=0;
      ConProfitTrades1=0;
      ConProfitTrades2=0;
      ConLossTrades1=0;
      ConLossTrades2=0;
      AvgConWinners=0;
      AvgConLosers=0;
    }

    /**
     * Return summary report.
     */
    string GenerateReport(string sep = "\n") {
      string output = "";
      int i;
      output += StringFormat("Initial deposit:                            %.2f", ValueToCurrency(CalculateInitialDeposit())) + sep;
      output += StringFormat("Total net profit:                           %.2f", ValueToCurrency(SummaryProfit)) + sep;
      output += StringFormat("Gross profit:                               %.2f", ValueToCurrency(GrossProfit)) + sep;
      output += StringFormat("Gross loss:                                 %.2f", ValueToCurrency(GrossLoss))  + sep;
      output += StringFormat("Profit factor:                              %.2f", ProfitFactor) + sep;
      output += StringFormat("Expected payoff:                            %.2f", ExpectedPayoff) + sep;
      output += StringFormat("Absolute drawdown:                          %.2f", AbsoluteDrawdown) + sep;
      output += StringFormat("Maximal drawdown:                           %.1f (%.1f%%)", ValueToCurrency(MaxDrawdown), MaxDrawdownPercent) + sep;
      output += StringFormat("Relative drawdown:                          (%.1f%%) %.1f", RelDrawdownPercent, ValueToCurrency(RelDrawdown)) + sep;
      output += StringFormat("Trades total                                %d", SummaryTrades) + sep;
      if (ShortTrades > 0) {
        output += StringFormat("Short positions (won %%):                    %d (%.1f%%)", ShortTrades, 100.0*WinShortTrades/ShortTrades) + sep;
      }
      if (LongTrades > 0) {
        output += StringFormat("Long positions (won %%):                     %d (%.1f%%)", LongTrades, 100.0*WinLongTrades/LongTrades) + sep;
      }
      if (ProfitTrades > 0)
        output += StringFormat("Profit trades (%% of total):                 %d (%.1f%%)", ProfitTrades, 100.0*ProfitTrades/SummaryTrades) + sep;
      if (LossTrades>0)
        output += StringFormat("Loss trades (%% of total):                   %d (%.1f%%)", LossTrades, 100.0*LossTrades/SummaryTrades) + sep;
      output += StringFormat("Largest profit trade:                       %.2f", MaxProfit) + sep;
      output += StringFormat("Largest loss trade:                         %.2f", -MinProfit) + sep;
      if (ProfitTrades > 0)
        output += StringFormat("Average profit trade:                       %.2f", GrossProfit/ProfitTrades) + sep;
      if (LossTrades > 0)
        output += StringFormat("Average loss trade:                         %.2f", -GrossLoss/LossTrades) + sep;
      output += StringFormat("Average consecutive wins:                   %.2f", AvgConWinners) + sep;
      output += StringFormat("Average consecutive losses:                 %.2f", AvgConLosers) + sep;
      output += StringFormat("Maximum consecutive wins (profit in money): %d %.2f", ConProfitTrades1, ConProfit1, ")") + sep;
      output += StringFormat("Maximum consecutive losses (loss in money): %d %.2f", ConLossTrades1, -ConLoss1) + sep;
      output += StringFormat("Maximal consecutive profit (count of wins): %.2f %d", ConProfit2, ConProfitTrades2) + sep;
      output += StringFormat("Maximal consecutive loss (count of losses): %.2f %d", ConLoss2, ConLossTrades2) + sep;

      return output;
    }
}
