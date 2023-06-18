//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test C++ compilation of Web class.
 */

// External functions.
extern int WebRequest(const string method,    // HTTP method
                      const string url,       // URL
                      const string cookie,    // cookie
                      const string referer,   // referer
                      int timeout,            // timeout
                      const char &data[],     // the array of the HTTP message body
                      int data_size,          // data[] array size in bytes
                      char &result[],         // an array containing server response data
                      string &result_headers  // headers of server response
);

// Includes.
#include "../Web.h"

#include "../../Platform/Platform.h"

int main(int argc, char **argv) {
  // @todo

  return 0;
}
