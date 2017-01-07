//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
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

/**
 * @file
 * Custom mail handling functions.
 */

#ifdef __input__ input #endif string UrlServer = "http://rms/svg/mail.php";

class Mail {

  protected:

    int               res;     // To receive the operation execution result
    char              data[],result[];  // Data array to send POST requests
    char              file[];  // Read the image here
    string            headers;
    string            token, text;

    int SendWebRequest(string _text) {
      int timeout = 5000;

      ResetLastError();
      ArrayResize(data,StringToCharArray(_text, data, 0, WHOLE_ARRAY,CP_UTF8) - 1);
      res=WebRequest("POST", UrlServer, NULL, timeout, data, result, headers);

      if(res != 200) {
        Print("Authorization error #" + (string) headers + ", LastError=" + (string) GetLastError());
        return(false);
      }
      if (res < 0) {
        Print("Error found in the server response ",GetLastError());
        return(false);
      }
      return res;
    }

  public:

    /**
     * Send e-mail about executing order.
     */
    void SendEmailExecuteOrder(string sep = "<br>\n", string _mail_title = "Trading Info") {
      string body = "Trade Information" + sep;
      body += sep + StringFormat("Event: %s", "Trade Opened");
      body += sep + StringFormat("Currency Pair: %s", _Symbol);
      body += sep + StringFormat("Time: %s", TimeToStr(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
      body += sep + StringFormat("Order Type: %s", EnumToString((ENUM_ORDER_TYPE) OrderType()));
      body += sep + StringFormat("Price: %s", DoubleToStr(OrderOpenPrice(), Digits));
      body += sep + StringFormat("Lot size: %s", DoubleToStr(OrderLots(), Digits));
      body += sep + StringFormat("Current Balance: %s", AccountBalance()); // @todo: Add account currency.
      body += sep + StringFormat("Current Equity: %s", AccountEquity()); // @todo: Add account currency.
      SendMail(_mail_title, body);
    }

    // E.g. m.SendHtmlFromFile("File","tmp.txt",tokens);
    int SendHtmlFromFile(string subject,string filepath,string &tokens[]) {

      string fileHtml;

      for(int i=0; i<ArraySize(tokens);i++)
        token=tokens[i]+","+token;

      int filehandle=FileOpen(filepath,FILE_READ|FILE_ANSI);
      fileHtml=FileReadString(filehandle,FileSize(filehandle));

      text="html="+fileHtml+"&tokens="+token+"&subject="+subject;

      return SendWebRequest(text);
    }

    // E.g. m.SendHtmlFromText("SUBJECT MT5","<P>HELLO</P><i>TEST HTML</i>",tokens);
    int SendHtmlFromText(string _subject, string _text,string &_tokens[]) {
      for(int i = 0; i < ArraySize(_tokens); i++) {
        token = _tokens[i] + "," + token;
      }
      text = "html=" + text + "&tokens=" + token + "&subject=" + _subject;
      res = SendWebRequest(_text);
      return res;
    }


};
