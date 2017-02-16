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

// Properties.
#property strict

/**
 * Class to provide functions to deal with the timer.
 */
class Timer {

  protected:

    // Variables.
    string name;
    uint index;
    uint data[];
    uint start, end;

  public:

    /**
     * Class constructor.
     */
    void Timer(string _name = "") : index(-1), name(_name) { };
    void ~Timer() {
      Timer *_timer = GetPointer(this);
      delete _timer;
    }

    /**
     * Start the timer.
     */
    void TimerStart() {
      start = GetTickCount();
    }

    /**
     * Stop the timer.
     */
    void TimerStop() {
      end = GetTickCount();
      ArrayResize(data, ++index + 1, 100);
      data[index] = fabs(end - start);
    }

    /* Getters */

    /**
     * Stop the timer.
     */
    uint GetTime(uint _index) {
      return data[index];
    }

    /**
     * Returns timer name.
     */
    string GetName() {
      return name;
    }

    /**
     * Stop the timer.
     */
    string ToString(string _dlm = ",") {
      string _out = "";
      for (int i = 0; i < ArraySize(data); i++) {
        _out += IntegerToString(GetTime(i)) + _dlm;
      }
      return StringSubstr(_out, 0, StringLen(_out) - StringLen(_dlm));
    }

};
