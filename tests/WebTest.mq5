//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Web class.
 */

// Includes.
#include "../Web.mqh"
#include "../Test.mqh"
#include "../Terminal.mqh"

// Properties.
#property strict

/**
 * Implements OnInit().
 */
int OnInit() {
  // Test 1.
  Web *web1 = new Web();
  WebRequestParams req1("http://example.com");
  WebRequestResult _res1;
  _res1 = web1.Request(req1);
  if (_res1.http_code > 0) {
    PrintFormat("Web1: HTTP Response Code: %d", _res1.http_code);
    PrintFormat("Web1: Headers: %s", _res1.headers);
  } else {
    PrintFormat("%s(): Error: Code: %d, Message: %s", __FUNCTION__, _res1.error, Terminal::GetErrorText(_res1.error));
    return (INIT_FAILED);
  }
  delete web1;

  // Test 2.
  Web *web2 = new Web();
  WebRequestParams req2("https://example.com");
  WebRequestResult _res2;
  _res2 = web2.Request(req2);
  if (_res2.http_code > 0) {
    PrintFormat("Web1: HTTP Response Code: %d", _res2.http_code);
    PrintFormat("Web1: Headers: %s", _res2.headers);
  } else {
    PrintFormat("%s(): Error: Code: %d, Message: %s", __FUNCTION__, _res2.error, Terminal::GetErrorText(_res2.error));
    return (INIT_FAILED);
  }

  return (INIT_SUCCEEDED);
}
