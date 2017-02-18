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

// Includes.
#include <EA31337-classes/Object.mqh>

/**
 * Class to provide functions to deal with the timer.
 */
class Timer : public Object {

  protected:

    // Variables.
    string name;
    int index;
    uint data[];
    uint start, end;

  public:

    /**
     * Class constructor.
     */
    void Timer(string _name = "") : index(-1), name(_name) { };

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
      ArrayResize(data, ++index + 1, 10000);
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
     * Get the sum of all values.
     */
    ulong GetSum() {
      uint _size = ArraySize(data);
      ulong _sum = 0;
      for (uint i = 0; i < _size; i++) {
        _sum += data[i];
      }
      return _sum;
    }

    /**
     * Get the median of all values.
     */
    uint GetMedian() {
      if (index >= 0) {
        ArraySort(data);
      }
      return index >= 0 ? data[index / 2] : 0;
    }

    /**
     * Get the minimum time value.
     */
    uint GetMin() {
      return index >= 0 ? ArrayMinimum(data) : 0;
    }

    /**
     * Get the maximal time value.
     */
    uint GetMax() {
      int _index = index >= 0 ? ArrayMaximum(data) : -1;
      return _index >= 0 ? data[_index] : 0;
    }

    /* inherited methods */

    /**
     * Print timer times.
     */
    virtual string ToString() {
      return StringFormat("%s(%d)=%d-%dms,med=%dms,sum=%dms",
        name,
        ArraySize(data),
        GetMin(),
        GetMax(),
        GetMedian(),
        GetSum()
      );
    }

    /**
     * Returns weight of the object.
     */
    virtual double Weight() {
      return (double) GetSum();
    }

};