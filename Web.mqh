//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

// Properties.
#property strict

// Prevents processing this includes file for the second time.
#ifndef WEB_MQH
#define WEB_MQH

struct WebRequestParams {
  string method;
  string url;
  string headers;
  string cookie;
  string referer;
  int timeout;
  WebRequestParams(string _m, string _u, string _h = NULL, int _t = 500)
    : method(_m), url(_u), headers(_h), timeout(_t) {};
  WebRequestParams(string _m, string _u, string _c, string _r = NULL, int _t = 500)
    : method(_m), url(_u), cookie(_c), referer(_r), timeout(_t) {};
  WebRequestParams(string _u, string _h = NULL, int _t = 500)
    : method("GET"), url(_u), headers(_h), timeout(_t) {};
};

struct WebRequestResult {
  char data[];
  char result[];
  int error;
  int http_code; // HTTP server response code or -1 for an error.
  string headers;
};

/**
 * Implements Web class.
 */
class Web {

  private:

  public:

    /**
     * Class constructor.
     */
    Web() {
    }

    /**
     * Web request.
     *
     * Note: Make sure to add URL to the list of allowed URLs in the Terminal.
     */
    WebRequestResult Request(const WebRequestParams &_rp) {
      ResetLastError();
      WebRequestResult _res;
      if (StringLen(_rp.headers) > 0) {
        _res.http_code = WebRequest(
          _rp.method, _rp.url, _rp.headers, _rp.timeout,
          _res.data, _res.result, _res.headers);
      }
      else {
        int _size = 0; // @fixme: data[] array size in bytes.
        _res.http_code = WebRequest(
          _rp.method, _rp.url, _rp.cookie, _rp.referer, _rp.timeout,
          _res.data, _size, _res.result, _res.headers);
      }
      _res.error = GetLastError();
      return _res;
    }

};
#endif
