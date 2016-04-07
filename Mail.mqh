/*
 * Custom mail handling functions.
 */

class Mail {
public:

    /*
     * Send e-mail about executing order.
     */
    void SendEmailExecuteOrder(string sep = "<br>\n") {
      string mail_title = "Trading Info - " + ea_name;
      string body = "Trade Information" + sep;
      body += sep + StringFormat("Event: %s", "Trade Opened");
      body += sep + StringFormat("Currency Pair: %s", _Symbol);
      body += sep + StringFormat("Time: %s", TimeToStr(time_current, TIME_DATE|TIME_MINUTES|TIME_SECONDS));
      body += sep + StringFormat("Order Type: %s", _OrderType_str(OrderType()));
      body += sep + StringFormat("Price: %s", DoubleToStr(OrderOpenPrice(), Digits));
      body += sep + StringFormat("Lot size: %s", DoubleToStr(OrderLots(), VolumeDigits));
      body += sep + StringFormat("Current Balance: %s", ValueToCurrency(AccountBalance()));
      body += sep + StringFormat("Current Equity: %s", ValueToCurrency(AccountEquity()));
      SendMail(mail_title, body);
    }

}
