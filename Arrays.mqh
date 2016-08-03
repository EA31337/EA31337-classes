//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
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

/*
 * Class to provide methods to deal with arrays.
 */
class Arrays {
public:

    /*
     * Return plain text of array values separated by the delimiter.
     *
     * @param
     *   double arr[] - array to look for the values
     *   string sep - delimiter to separate array values
     */
    static string GetArrayValues(double& arr[], string sep = ", ") {
        string result = "";
        for (int i = 0; i < ArraySize(arr); i++) {
            result = result + i + ":" + arr[i] + sep;
        }
        return StringSubstr(result, 0, StringLen(result) - StringLen(sep)); // Return text without last separator.
    }

    /*
     * Find lower value within the 1-dim array of floats.
     */
    static double LowestArrValue(double& arr[]) {
      return (arr[ArrayMinimum(arr)]);
    }

    /*
     * Find higher value within the 1-dim array of floats.
     */
    static double HighestArrValue(double& arr[]) {
      return (arr[ArrayMaximum(arr)]);
    }

    /*
     * Find lower value within the 2-dim array of floats by the key.
     */
    static double LowestArrValue2(double& arr[][], int key1) {
      double lowest = 999;
      for (int i = 0; i < ArrayRange(arr, 1); i++) {
        if (arr[key1][i] < lowest) {
          lowest = arr[key1][i];
        }
      }
      return lowest;
    }

    /*
     * Find higher value within the 2-dim array of floats by the key.
     */
    static double HighestArrValue2(double& arr[][], int key1) {
      double highest = 0;
      for (int i = 0; i < ArrayRange(arr, 1); i++) {
        if (arr[key1][i] > highest) {
          highest = arr[key1][i];
        }
      }
      return highest;
    }

    /*
     * Find highest value in 2-dim array of integers by the key.
     */
    static int HighestValueByKey(int& arr[][], int key) {
      double highest = 0;
      for (int i = 0; i < ArrayRange(arr, 1); i++) {
        if (arr[key][i] > highest) {
          highest = arr[key][i];
        }
      }
      return highest;
    }

    /*
     * Find lowest value in 2-dim array of integers by the key.
     */
    static int LowestValueByKey(int& arr[][], int key) {
      double lowest = 999;
      for (int i = 0; i < ArrayRange(arr, 1); i++) {
        if (arr[key][i] < lowest) {
          lowest = arr[key][i];
        }
      }
      return lowest;
    }

    /*
    static int GetLowestArrDoubleValue(double& arr[][], int key) {
      double lowest = -1;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
        for (int j = 0; j < ArrayRange(arr, 1); j++) {
          if (arr[i][j] < lowest) {
            lowest = arr[i][j];
          }
        }
      }
      return lowest;
    }*/

    /*
     * Find key in array of integers with highest value.
     */
    static int GetArrKey1ByHighestKey2Value(int& arr[][], int key2) {
      int key1 = EMPTY;
      int highest = 0;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
          if (arr[i][key2] > highest) {
            highest = arr[i][key2];
            key1 = i;
          }
      }
      return key1;
    }

    /*
     * Find key in array of integers with lowest value.
     */
    static int GetArrKey1ByLowestKey2Value(int& arr[][], int key2) {
      int key1 = EMPTY;
      int lowest = 999;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
          if (arr[i][key2] < lowest) {
            lowest = arr[i][key2];
            key1 = i;
          }
      }
      return key1;
    }

    /*
     * Find key in array of doubles with highest value.
     */
    static int GetArrKey1ByHighestKey2ValueD(double& arr[][], int key2) {
      int key1 = EMPTY;
      int highest = 0;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
          if (arr[i][key2] > highest) {
            highest = arr[i][key2];
            key1 = i;
          }
      }
      return key1;
    }

    /*
     * Find key in array of doubles with lowest value.
     */
    static int GetArrKey1ByLowestKey2ValueD(double& arr[][], int key2) {
      int key1 = EMPTY;
      int lowest = 999;
      for (int i = 0; i < ArrayRange(arr, 0); i++) {
          if (arr[i][key2] < lowest) {
            lowest = arr[i][key2];
            key1 = i;
          }
      }
      return key1;
    }

    /*
     * Set array value for double items with specific keys.
     */
    static void ArrSetValueD(double& arr[][], int key, double value) {
      for (int i = 0; i < ArrayRange(info, 0); i++) {
        arr[i][key] = value;
      }
    }

    /*
     * Set array value for integer items with specific keys.
     */
    static void ArrSetValueI(int& arr[][], int key, int value) {
      for (int i = 0; i < ArrayRange(info, 0); i++) {
        arr[i][key] = value;
      }
    }

    /*
     * Calculate sum of 2 dimentional array based on given key.
     */
    static double GetArrSumKey1(double& arr[][], int key1, int offset = 0) {
      double sum = 0;
      offset = MathMin(offset, ArrayRange(arr, 1) - 1);
      for (int i = offset; i < ArrayRange(arr, 1); i++) {
        sum += arr[key1][i];
      }
      return sum;
    }
};
