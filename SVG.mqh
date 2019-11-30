//+------------------------------------------------------------------+
//|                                                      plotSVG.mqh |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SVG {
   datetime               x,y,t;
   datetime               tdiff;
   int               filehandle;

public:

   SVG(string filename)
     {
      string svg="<svg viewBox='0 0 500 100' class='chart'><polyline fill='none' stroke='#0074d9' stroke-width='2' points='";
      filehandle=FileOpen(filename,FILE_WRITE,',');
      FileWrite(filehandle,svg);
     }
   ~SVG() {
      string svgend="' /></svg>";

      FileWrite(filehandle,svgend);
      FileClose(filehandle);
     }

   void plot() {

      if(filehandle != INVALID_HANDLE) {

         int i=Bars;
         t=0;
         while (i-->0) {
            x=TimeHour(Time[i])*TimeMinute(Time[i]);
            tdiff=(Time[0]-Time[i]);
            y=(Time[Bars-1]-Time[i])/-100;
            FileWrite(filehandle,t++,High[i]);

           }

        }
      else Print("File open failed, error ",GetLastError());

     }
  

};
