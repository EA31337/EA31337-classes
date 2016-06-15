//+------------------------------------------------------------------+
//|                 EA31337 - Multi-strategy advanced trading robot. |
//|                            Copyright 2016, 31337 Investments Ltd |
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

#ifndef __no_dll__
#import "wininet.dll"
   int InternetOpenA(string agent, int access_type, string proxy_name, string proxy_bypass, int dw_flags);
   int InternetOpenUrlA(int internet, string url, string headers, int headers_length, int flags, int context);
   int InternetReadFile(int handler, string buffer, int bytes_in, int& bytes_out[]);
   int InternetCloseHandle(int handler);
#import
#endif

/**
 * Class to provide methods that using the Internet Protocol (IP).
 */
class Inet {

public:

    /**
     * Read content from given URL.
     */
    bool ReadFromURL(string url, string &output) {
      #ifdef __no_dll__
      return (FALSE);
      #endif
      int handler = InternetOpenUrlA(-1, url, "0", 0, -2080374528, 0);
      if (handler == 0) {
        return (FALSE);
      }
      int out[] = {1};
      string buffer = "xxxxxxxxxx";
      int result = InternetReadFile(handler, buffer, 10, out);
      if (handler != 0) InternetCloseHandle(handler);
      output = buffer;
      return (TRUE);
    }

};
