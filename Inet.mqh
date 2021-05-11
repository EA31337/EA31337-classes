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

#ifndef __no_dll__
#import "wininet.dll"
// Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100
// Does not add the returned entity to the cache.
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000
// Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.
#define INTERNET_FLAG_RELOAD            0x80000000
int InternetOpenA(string agent, int access_type, string proxy_name, string proxy_bypass, int flags);
int InternetOpenUrlA(int internet, string url, string headers, int headers_length, int flags, int context);
int InternetReadFile(int handler, string buffer, int buffer_size, int& bytes_read[]);
int InternetCloseHandle(int handler);
#import "urlmon.dll"
int URLDownloadToFileW(int caller, string url, string filename, int reserved, int callback);
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
      return (false);
      #endif
      int handler = InternetOpenUrlA(-1, url, "0", 0, -2080374528, 0);
      if (handler == 0) {
        return (false);
      }
      int out[] = {1};
      string buffer = "xxxxxxxxxx";
      int result = InternetReadFile(handler, buffer, 10, out);
      if (handler != 0) InternetCloseHandle(handler);
      output = buffer;
      return (true);
    }

};
