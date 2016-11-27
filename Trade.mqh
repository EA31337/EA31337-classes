//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

#ifdef __MQL5__
#define DOUBLE_VALUE 0
#define FLOAT_VALUE 1
#define LONG_VALUE INT_VALUE

#define CHART_BAR 0
#define CHART_CANDLE 1

#define MODE_ASCEND 0
#define MODE_DESCEND 1

#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33

#endif

/*
 * Trade class
 */
class Trade {

private:
    int totalOrders;
    Order* orders[];

public:

    /**
     * Closes opened order.
     *
     * @see http://docs.mql4.com/trading/orderclose
     */
    static bool OrderClose(
            int        ticket,      // ticket
            double     lots,        // volume
            double     price,       // close price
            int        slippage,    // slippage
            color      arrow_color  // color
            ) {
#ifdef __MQL4__
        return ::OrderClose(ticket, lots, price, slippage, arrow_color);
#else
        // @todo: Create implementation.
        return FALSE;
#endif
    }

    /**
     * Closes an opened order by another opposite opened order.
     */
    /* todo */ static void OrderCloseBy(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /**
     * Returns close price of the currently selected order.
     */
    /* todo */ static void OrderClosePrice(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /*
     * Returns close time of the currently selected order.
     *
     *  @see http://docs.mql4.com/trading/orderclosetime
     */
    static datetime OrderCloseTime() {
        // @todo: Create implementation.
        return datetime (0);
    }

    /**
     * Returns calculated commission of the currently selected order.
     *
     * @see http://docs.mql4.com/trading/ordercommission
     */
    static double OrderCommission() {
#ifdef __MQL4__
        return ::OrderCommission();
#else
        // @todo: Create implementation.
        return 0.0;
#endif
    }

    /**
     * Returns calculated commission of the currently selected order.
     */
    /* todo */ static void OrderCommission(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /**
     * Deletes previously opened pending order.
     */
    /* todo */ static void OrderDelete(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /**
     * Returns expiration date of the selected pending order.
     */
    /* todo */ static void OrderExpiration(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /**
     * Returns amount of lots of the selected order.
     *
     * @see http://docs.mql4.com/trading/orderlots
     */
    static double OrderLots() {
#ifdef __MQL4__
        return ::OrderLots();
#else
        // @todo: Check if this is what we want.
        return OrderGetDouble(ORDER_VOLUME_CURRENT); // Order current volume.
#endif
    }

    /**
     * Returns an identifying (magic) number of the currently selected order.
     *
     * @see http://docs.mql4.com/trading/ordermagicnumber
     */
    static int OrderMagicNumber() {
#ifdef __MQL4__
        return ::OrderMagicNumber();
#else
        // @todo: Create implementation.
        return 0;
#endif
    }

    /**
     * Modification of characteristics of the previously opened or pending orders.

     * @see http://docs.mql4.com/trading/ordermodify
     */
    static bool OrderModify(
            int        ticket,      // ticket
            double     price,       // price
            double     stoploss,    // stop loss
            double     takeprofit,  // take profit
            datetime   expiration,  // expiration
            color      arrow_color  // color
            ) {
#ifdef __MQL4__
        return ::OrderModify(ticket, price, stoploss, takeprofit, expiration, arrow_color);
#else
        // @todo: Create implementation.
        return false;
#endif
    }


    /**
     * Returns open price of the currently selected order.
     *
     * @see http://docs.mql4.com/trading/orderopenprice
     */
    static double OrderOpenPrice() {
#ifdef __MQL4__
        return ::OrderOpenPrice();
#else
        return OrderGetDouble(ORDER_PRICE_OPEN);
#endif
    }

    /**
     * Returns open time of the currently selected order.
     *
     * @see http://docs.mql4.com/trading/orderopentime
     */
    static datetime OrderOpenTime() {
#ifdef __MQL4__
        return ::OrderOpenTime();
#else
        // @todo: Create implementation.
        return (datetime)0;
#endif
    }

    /**
     * Prints information about the selected order in the log.
     *
     * @see http://docs.mql4.com/trading/orderprint
     */
    static void OrderPrint() {
#ifdef __MQL4__
        ::OrderPrint();
#else
        // @todo: Not implemented yet.
#endif
    }


    /**
     * Returns profit of the currently selected order.
     */
    /* todo */ static void OrderProfit(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /**
     * The function selects an order for further processing.
     *
     *  @see http://docs.mql4.com/trading/orderselect
     */
    static bool OrderSelect(
            int     index,            // index or order ticket
            int     select,           // flag
            int     pool=MODE_TRADES  // mode
            ) {
#ifdef __MQL4__
        return ::OrderSelect(index, select, pool);
#else
        // @todo: Create implementation.
#endif
    }


    /**
     * The main function used to open market or place a pending order.
     *
     *  @see http://docs.mql4.com/trading/ordersend
     */
    static int OrderSend(
            string   symbol,              // symbol
            int      cmd,                 // operation
            double   volume,              // volume
            double   price,               // price
            double   slippage,            // slippage
            double   stoploss,            // stop loss
            double   takeprofit,          // take profit
            string   comment=NULL,        // comment
            int      magic=0,             // magic number
            datetime expiration=0,        // pending order expiration
            color    arrow_color=clrNONE  // color
            )
    {
#ifdef __MQL4__
        return ::OrderSend(symbol,
            cmd,
            volume,
            price,
            slippage,
            stoploss,
            takeprofit,
            comment,
            magic,
            expiration,
            arrow_color);
#else
        // Structure: https://www.mql5.com/en/docs/constants/structures/mqltraderequest
        MqlTradeRequest request;

        // Structure: https://www.mql5.com/en/docs/constants/structures/mqltraderesult
        MqlTradeResult result;

        request.action = TRADE_ACTION_DEAL;
        request.symbol = symbol;
        request.volume = volume;
        request.price = price;
        request.sl = stoploss;
        request.tp = takeprofit;
        request.comment = comment;
        request.magic = magic;
        request.expiration = expiration;
        // MQL4 has OP_BUY, OP_SELL. MQL5 has ORDER_TYPE_BUY, ORDER_TYPE_SELL, etc.
        request.type = (ENUM_ORDER_TYPE)cmd;

        bool status = OrderSend(request, result);

        // @todo: Finish the implementation.
        return 0;
#endif
    }


    /**
     * Returns the number of closed orders in the account history loaded into the terminal.
     */
    /* todo */ static void OrdersHistoryTotal(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /**
     * Returns stop loss value of the currently selected order.
     *
     * @see http://docs.mql4.com/trading/orderstoploss
     */
    static double OrderStopLoss() {
#ifdef __MQL4__
        return ::OrderStopLoss();
#else
        // @todo: Create implementation.
        return 0.0;
#endif
    }

    /**
     * Returns the number of market and pending orders.
     */
    /* todo */ static void OrdersTotal(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /**
     * Returns swap value of the currently selected order.
     */
    /* todo */ static void OrderSwap(int todo) {
        #ifdef __MQL4__
        // @todo
        #else
        // @todo
        #endif
    }

    /**
     * Returns symbol name of the currently selected order.
     *
     * @see http://docs.mql4.com/trading/ordersymbol
     */
    static string OrderSymbol() {
#ifdef __MQL4__
        return ::OrderSymbol();
#else
        // @todo: Create implementation.
        return "";
#endif
    }

    /**
     * Returns take profit value of the currently selected order.
     *
     * @see http://docs.mql4.com/trading/ordertakeprofit
     */
    static double OrderTakeProfit() {
#ifdef __MQL4__
        return ::OrderTakeProfit();
#else
        // @todo: Create implementation.
        return 0.0;
#endif
    }

    /**
     * Returns ticket number of the currently selected order.
     *
     * @see https://docs.mql4.com/trading/orderticket
     * @see https://www.mql5.com/en/docs/trading/ordergetticket
     */
    static int OrderTicket() {
#ifdef __MQL4__
        return ::OrderTicket();
#else
        // return OrderGetTicket(i);
        // @todo: Create implementation.
        return 0;
#endif
    }

    /**
     * Returns order operation type of the currently selected order.
     *
     * @see http://docs.mql4.com/trading/ordertype
     */
    static int OrderType() {
#ifdef __MQL4__
        return ::OrderType();
#else
        // @todo: Create implementation.
        return 0;
#endif
    }

    /**
     * Returns text string with the specified numerical value converted into a specified precision format.
     *
     * @see http://docs.mql4.com/convert/doubletostr
     */
    string  DoubleToStrMQL4 (
            double  value,     // value
            int     digits     // precision
            ) {
        return DoubleToString (value, digits);

        // Overriding DoubleToStr function.
#define DoubleToStr DoubleToStrMQL4
    }

    /**
     * Returns the string copy with changed character in the specified position.
     *
     * @see https://www.mql5.com/en/articles/81
     */
    string StringSetChar (string text, int pos, int value) {
        string copy = text;

        StringSetCharacter (copy, pos, (ushort)value);

        return copy;
    }

    /**
     * Returns Open price value for the bar of specified symbol with timeframe and shift.
     *
     * @see http://docs.mql4.com/series/iopen
     */
    double iOpen (
            string           symbol,          // symbol
            int              tf,              // timeframe
            int              index            // shift
            ) {
        if (index < 0)
            return -1;

        double Arr[];

        ENUM_TIMEFRAMES timeframe = TFMigrate (tf);

        if (CopyOpen (symbol, timeframe, index, 1, Arr) > 0)
            return Arr[0];
        else
            return -1;
    }

    /**
     * Returns Close price value for the bar of specified symbol with timeframe and shift.
     *
     * @see http://docs.mql4.com/series/iclose
     */
    double iClose (
            string           symbol,          // symbol
            int              tf,              // timeframe
            int              index            // shift
            ) {
        if(index < 0)
            return -1;

        double Arr[];

        ENUM_TIMEFRAMES timeframe = TFMigrate (tf);

        if (CopyClose (symbol, timeframe, index, 1, Arr) > 0)
            return Arr[0];
        else
            return -1;
    }

    /**
     * Refreshing of data in pre-defined variables and series arrays.
     *
     * @see http://docs.mql4.com/series/refreshrates
     */
    bool RefreshRates () {
        return true;
    }

    /**
     * The latest known seller's price (ask price) for the current symbol. The RefreshRates() function must be used to update.
     *
     * @see http://docs.mql4.com/predefined/ask
     */
    double AskMT4 () {
        MqlTick last_tick;

        SymbolInfoTick(_Symbol,last_tick);

        return last_tick.ask;

        // Overriding Ask variable to become a function call.
#define Ask AskMT4()
    }

    /**
     * The latest known buyer's price (offer price, bid price) of the current symbol. The RefreshRates() function must be used to update.
     *
     * @see http://docs.mql4.com/predefined/bid
     */
    double BidMT4 () {
        MqlTick last_tick;

        SymbolInfoTick(_Symbol,last_tick);

        return last_tick.bid;

        // Overriding Bid variable to become a function call.
#define Bid BidMT4()

    }

    /**
     * Calculates the Money Flow Index indicator and returns its value.
     *
     * @see http://docs.mql4.com/indicators/imfi
     */
    double iMFIMQL4 (string symbol,
            int tf,
            int period,
            int shift) {
        ENUM_TIMEFRAMES timeframe = TFMigrate (tf);

        int handle = (int) iMFI (symbol, timeframe, period, VOLUME_TICK);

        if (handle < 0)
        {
            Print ("The iMFI object is not created: Error", GetLastError ());
            return -1;
        }
        else {
            return CopyBufferMQL4 (handle, 0, shift);
        }

        // Overriding iMFI function.
#define iMFI iMFIMQL4
    }

    /**
     * Calculates the  Larry Williams' Percent Range and returns its value.
     *
     * @see http://docs.mql4.com/indicators/iwpr
     */
    double iWPRMQL4 (string symbol,
            int tf,
            int period,
            int shift) {
        ENUM_TIMEFRAMES timeframe = TFMigrate (tf);

        int handle = iWPR (symbol, timeframe, period);

        if (handle < 0) {
            Print ("The iWPR object is not created: Error", GetLastError ());
            return -1;
        }
        else
            return CopyBufferMQL4 (handle, 0, shift);

        // Overriding iMPR function.
#define iWPR iWPRMQL4
    }

    /**
     * Calculates the Stochastic Oscillator and returns its value.
     *
     * @see http://docs.mql4.com/indicators/istochastic
     */
    double iStochastic(string symbol,
            int tf,
            int Kperiod,
            int Dperiod,
            int slowing,
            int method,
            int field,
            int mode,
            int shift) {
        ENUM_TIMEFRAMES timeframe   = TFMigrate (tf);
        ENUM_MA_METHOD  ma_method   = MethodMigrate (method);
        ENUM_STO_PRICE  price_field = StoFieldMigrate (field);

        int handle = iStochastic (symbol, timeframe, Kperiod, Dperiod, slowing, ma_method, price_field);

        if (handle < 0) {
            Print ("The iStochastic object is not created: Error", GetLastError ());
            return -1;
        } else {
            return CopyBufferMQL4 (handle, mode, shift);
        }
    }


    /**
     * Calculates the Standard Deviation indicator and returns its value.
     *
     * @see http://docs.mql4.com/indicators/istddev
     */
    double iStdDev (string symbol,
            int tf,
            int ma_period,
            int ma_shift,
            int method,
            int price,
            int shift) {
        ENUM_TIMEFRAMES    timeframe     = TFMigrate (tf);
        ENUM_MA_METHOD     ma_method     = MethodMigrate (method);
        ENUM_APPLIED_PRICE applied_price = PriceMigrate (price);

        int handle = iStdDev (symbol, timeframe, ma_period, ma_shift, ma_method, applied_price);

        if (handle < 0) {
            Print ("The iStdDev object is not created: Error", GetLastError ());
            return -1;
        }
        else {
            return CopyBufferMQL4 (handle, 0, shift);
        }
    }

    /**
     * Search for a bar by its time. The function returns the index of the bar which covers the specified time.
     *
     * @see http://docs.mql4.com/series/ibarshift
     */
    int iBarShift (string symbol,
            int tf,
            datetime time,
            bool exact = false) {
        if (time < 0) {
            return -1;
        }

        ENUM_TIMEFRAMES timeframe = TFMigrate (tf);

        datetime Arr[], time1;

        CopyTime (symbol, timeframe, 0, 1, Arr);

        time1 = Arr[0];

        if (CopyTime (symbol, timeframe, time, time1, Arr) > 0) {
            if (ArraySize (Arr) > 2)
                return ArraySize (Arr) - 1;

            if (time < time1)
                return 1;
            else
                return 0;
        }
        else {
            return -1;
        }
    }

    /**
     * Get realized P&L (Profit and Loss).
     */
    static double GetRealizedPL() const {
        double profit = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            if (this.orders[i].getOrderType() == ORDER_FINAL) {
                // @todo
                // profit += this.orders[i].getOrderProfit();
            }
        }
        return profit;
    }

    /**
     * Get unrealized P&L (Profit and Loss).
     *
     * A reflection of what profit or loss
     * that could be realized if the position were closed at that time.
     */
    static double GetUnrealizedPL() const {
        double profit = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            if (this.orders[i].getOrderType() != ORDER_FINAL) {
                profit += this.orders[i].getOrderProfit();
            }
        }
        return profit;
    }

    double GetTotalEquity() const {
        double profit = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            profit += this.orders[i].GetOrderProfit();
        }
        return profit;
    }

    double GetTotalCommission() const {
        double commission = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            commission += this.orders[i].GetOrderCommission();
        }
        return commission;
    }

    double GetTotalSwap() const {
        double swap = 0;
        for (int i = 0; i <= numberOrders; ++i) {
            swap += this.orders[i].GetOrderSwap();
        }
        return swap;
    }

};
