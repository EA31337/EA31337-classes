/*
 * Custom mail handling functions.
 */

input string UrlServer="http://rms/svg/mail.php";

class Mail {

   int               res;     // To receive the operation execution result
   char              data[],result[];  // Data array to send POST requests
   char              file[];  // Read the image here
   string            headers;
   string            token,text;

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

    // E.g. m.SendHtmlFromFile("File","tmp.txt",tokens);
   int  SendHtmlFromFile(string subject,string filepath,string &tokens[])
     {

      string fileHtml;

      for(int i=0; i<ArraySize(tokens);i++)
         token=tokens[i]+","+token;

      int filehandle=FileOpen(filepath,FILE_READ|FILE_ANSI);
      fileHtml=FileReadString(filehandle,FileSize(filehandle));

      text="html="+fileHtml+"&tokens="+token+"&subject="+subject;

      return SendWebRequest(text);
     }

   // E.g. m.SendHtmlFromText("SUBJECT MT5","<P>HELLO</P><i>TEST HTML</i>",tokens);
   int  SendHtmlFromText(string subject,string text,string &tokens[])
     {


      for(int i=0; i< ArraySize(tokens);i++)
         token = tokens[i]+","+token;

      text="html="+text+"&tokens="+token+"&subject="+subject;

      res=SendWebRequest(text);

      return res;
     }

private:

   int SendWebRequest(string text)
     {
      int timeout=5000;

      ResetLastError();
      ArrayResize(data,StringToCharArray(text,data,0,WHOLE_ARRAY,CP_UTF8)-1);
      res=WebRequest("POST",UrlServer,NULL,timeout,data,result,headers);

      if(res!=200)
        {
         Print("Authorization error #"+(string)headers+", LastError="+(string)GetLastError());
         return(false);
        }

      if(res<0)
        {
         Print("Error found in the server response ",GetLastError());
         return(false);
        }
      return res;
     }

}
