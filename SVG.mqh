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

#property copyright ""
#property link      ""

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
