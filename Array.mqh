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

// Prevents processing this includes file for the second time.
#ifndef ARRAY_MQH
#define ARRAY_MQH

// Defines.
#ifndef MODE_ASCEND
#define MODE_ASCEND 0
#endif
#ifndef MODE_DESCEND
#define MODE_DESCEND 1
#endif
// Other constants.
// @see https://docs.mql4.com/constants/namedconstants/otherconstants
#ifndef WHOLE_ARRAY
// Indicates that all array elements will be processed.
#define WHOLE_ARRAY 0
#endif

// Includes.
#include "String.mqh"

/*
 * Class to provide methods to deal with arrays.
 */
class Array {

  public:

#ifdef __MQL__
    /**
     * Finds the median value in the array of any numeric type.
     */
    template<typename T>
      static T Median(T &_arr[]) {
        int _size = ArraySize(_arr);
        if (_size > 0) {
          ArraySort(_arr);
          return _arr[_size / 2];
        }
        else {
          return 0;
        }
      }
#endif

#ifdef __MQL__
    /**
     * Finds the highest value in the array of any numeric type.
     */
    template<typename T>
      static T Sum(T &_arr[]) {
        int i;
        int _size = ArraySize(_arr);
        if (_size > 0) {
          T _sum = _arr[0];
          for (i = 1; i < _size; i++) {
            _sum += _arr[i];
          }
          return _sum;
        }
        else {
          return 0;
        }
      }
#endif

#ifdef __MQL__
    /**
     * Finds the highest value in the array of any numeric type.
     */
    template<typename T>
      static T Max(T &_arr[]) {
        int i;
        int _size = ArraySize(_arr);
        if (_size > 0) {
          T _max = _arr[0];
          for (i = 1; i < _size; i++) {
            _max = _max < _arr[i] ?  _arr[i] : _max;
          }
          return _max;
        }
        else {
          return 0;
        }
      }
#endif

#ifdef __MQL__
    template <typename T>
    static int ArrayCopy( T &dst_array[], const T &src_array[], const int dst_start = 0, const int src_start = 0, const int count = WHOLE_ARRAY);
#endif

#ifdef __MQL__
    /**
     * Return plain text of array values separated by the delimiter.
     *
     * @param
     *   int arr[] - array to look for the values
     *   string sep - delimiter to separate array values
     */
    static string GetArrayValues(int& arr[], string sep = ", ") {
      int i;
      string result = "";
      for (i = 0; i < ArraySize(arr); i++) {
        result += StringFormat("%d:%d%s", i, arr[i], sep);
      }
      // Return text without last separator.
      return StringSubstr(result, 0, StringLen(result) - StringLen(sep));
    }
#endif

#ifdef __MQL__
    /**
     * Return plain text of array values separated by the delimiter.
     *
     * @param
     *   double arr[] - array to look for the values
     *   string sep - delimiter to separate array values
     */
    static string GetArrayValues(double& arr[], string sep = ", ") {
      int i;
      string result = "";
      for (i = 0; i < ArraySize(arr); i++) {
        result += StringFormat("%d:%g%s", i, arr[i], sep);
      }
      // Return text without last separator.
      return StringSubstr(result, 0, StringLen(result) - StringLen(sep));
    }
#endif

#ifdef __MQL__
    /**
     * Find lower value within the 1-dim array of floats.
     */
    static double LowestArrValue(double& arr[]) {
      return (arr[ArrayMinimum(arr)]);
    }
#endif

#ifdef __MQL__
    /**
     * Find higher value within the 1-dim array of floats.
     */
    static double HighestArrValue(double& arr[]) {
      return (arr[ArrayMaximum(arr)]);
    }
#endif

#ifdef __MQL4__
  /**
   * Find lower value within the 2-dim array of floats by the key.
   */
  static double LowestArrValue2(double& arr[][], int key1) {
    int i;
    double lowest = 999;
    for (i = 0; i < ArrayRange(arr, 1); i++) {
      if (arr[key1][i] < lowest) {
        lowest = arr[key1][i];
      }
    }
    return lowest;
  }
#endif

#ifdef __MQL4__
  /**
   * Find higher value within the 2-dim array of floats by the key.
   */
  static double HighestArrValue2(double& arr[][], int key1) {
    double highest = -1;
    int i;
    for (i = 0; i < ArrayRange(arr, 1); i++) {
      if (arr[key1][i] > highest) {
        highest = arr[key1][i];
      }
    }
    return highest;
  }
#endif

#ifdef __MQL4__
  /**
   * Find highest value in 2-dim array of integers by the key.
   */
  static int HighestValueByKey(int& arr[][], int key) {
    int highest = -1;
    int i;
    for (i = 0; i < ArrayRange(arr, 1); i++) {
      if (arr[key][i] > highest) {
        highest = arr[key][i];
      }
    }
    return highest;
  }
#endif

#ifdef __MQL4__
  /**
   * Find lowest value in 2-dim array of integers by the key.
   */
  static int LowestValueByKey(int& arr[][], int key) {
    int i;
    int lowest = 999;
    for (i = 0; i < ArrayRange(arr, 1); i++) {
      if (arr[key][i] < lowest) {
        lowest = arr[key][i];
      }
    }
    return lowest;
  }
#endif

  /*
  #ifdef __MQL4__
  static int GetLowestArrDoubleValue(double& arr[][], int key) {
    int i, j;
    double lowest = -1;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
      for (j = 0; j < ArrayRange(arr, 1); j++) {
        if (arr[i][j] < lowest) {
          lowest = arr[i][j];
        }
      }
    }
    return lowest;
  }
  #else
  // @todo
  #endif
  */

#ifdef __MQL4__
  /**
   * Find key in array of integers with the highest value.
   */
  static int GetArrKey1ByHighestKey2Value(int& arr[][], int key2) {
    int i;
    int key1 = EMPTY;
    int highest = 0;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
        if (arr[i][key2] > highest) {
          highest = arr[i][key2];
          key1 = i;
        }
    }
    return key1;
  }
#endif

#ifdef __MQL4__
  /**
   * Find key in array of integers with the lowest value.
   */
  static int GetArrKey1ByLowestKey2Value(int& arr[][], int key2) {
    int i;
    int key1 = EMPTY;
    int lowest = 999;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
        if (arr[i][key2] < lowest) {
          lowest = arr[i][key2];
          key1 = i;
        }
    }
    return key1;
  }
#endif

#ifdef __MQL4__
  /**
   * Find key in array of doubles with the highest value.
   */
  static int GetArrKey1ByHighestKey2ValueD(double& arr[][], int key2) {
    int i;
    int key1 = EMPTY;
    double highest = -1;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
        if (arr[i][key2] > highest) {
          highest = arr[i][key2];
          key1 = i;
        }
    }
    return key1;
  }
#endif

#ifdef __MQL4__
  /**
   * Find key in array of doubles with the lowest value.
   */
  static int GetArrKey1ByLowestKey2ValueD(double& arr[][], int key2) {
    int i;
    int key1 = EMPTY;
    double lowest = 999;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
        if (arr[i][key2] < lowest) {
          lowest = arr[i][key2];
          key1 = i;
        }
    }
    return key1;
  }
#endif

#ifdef __MQL4__
  /**
   * Set array value for double items with specific keys.
   */
  static void ArrSetValueD(double& arr[][], int key, double value) {
    int i;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
      arr[i][key] = value;
    }
  }
#endif

#ifdef __MQL4__
  /**
   * Set array value for integer items with specific keys.
   */
  static void ArrSetValueI(int& arr[][], int key, int value) {
    int i;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
      arr[i][key] = value;
    }
  }
#endif

#ifdef __MQL4__
  /**
   * Calculate sum of 2 dimentional array based on given key.
   */
  static double GetArrSumKey1(double& arr[][], int key1, int offset = 0) {
    int i;
    double sum = 0;
    offset = MathMin(offset, ArrayRange(arr, 1) - 1);
    for (i = offset; i < ArrayRange(arr, 1); i++) {
      sum += arr[key1][i];
    }
    return sum;
  }
#endif

#ifdef __MQL__
  /**
   * Print a one-dimensional array.
   *
   * @param int arr
   *   The one dimensional array of integers.
   * @param string dlm
   *   Delimiter to separate the items.
   *
   * @return string
   *   String representation of array.
   */
  static string ArrToString(int& arr[], string dlm = ",") {
    int i;
    string res = "";
    for (i = 0; i < ArraySize(arr); i++) {
      res += (string)arr[i] + dlm;
    }
    res = StringSubstr(res, 0, StringLen(res) - StringLen(dlm));
    return res;
  }
#endif

#ifdef __MQL__
  /**
   * Print a one-dimensional array.
   *
   * @param double arr
   *   The one dimensional array of doubles.
   * @param string dlm
   *   Delimiter to separate the items.
   *
   * @return string
   *   String representation of array.
   */
  static string ArrToString(double& arr[], string dlm = ",", int digits = 2) {
    int i;
    string res = "";
    for (i = 0; i < ArraySize(arr); i++) {
      res += StringFormat("%g%s", NormalizeDouble(arr[i], digits), dlm);
    }
    res = StringSubstr(res, 0, StringLen(res) - StringLen(dlm));
    return res;
  }
#endif

#ifdef __MQL__
  /**
   * Print a one-dimensional array in hex format.
   *
   * @param double unsigned char[]
   *   The one dimensional array of characters.
   * @param int count
   *   If specified, limit the number of printed characters.
   *
   * @return string
   *   String representation of array in hexadecimal format.
   */
  static string ArrToHex(unsigned char &arr[], int count = -1) {
    int i;
    string res;
    for (i = 0; i < (count > 0 ? count : ArraySize(arr)); i++) {
      res += StringFormat("%.2X", arr[i]);
    }
    return res;
  }
#endif

#ifdef __MQL4__
  /**
   * Print a two-dimensional array.
   *
   * @param string arr
   *   The two dimensional array of doubles.
   * @param string dlm
   *   Delimiter to separate the items.
   * @param string digits
   *   Number of digits after point.
   *
   * @return string
   *   String representation of array.
   */
  static string ArrToString2D(double& arr[][], string dlm = ",", int digits = 2) {
    string res = "";
    int i, j;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
      res += "[";
      for (j = 0; j < ArrayRange(arr, 1); j++) {
        res += StringFormat("%g%s", NormalizeDouble(arr[i][j], digits), dlm);
      }
      res = StringSubstr(res, 0, StringLen(res) - StringLen(dlm));
      res += "]" + dlm;
    }
    res = StringSubstr(res, 0, StringLen(res) - StringLen(dlm));
    return res;
  }
#endif

#ifdef __MQL4__
  /**
   * Print a three-dimensional array.
   *
   * @param string arr
   *   The three dimensional array of doubles.
   * @param string dlm
   *   Delimiter to separate the items.
   * @param string digits
   *   Number of digits after point.
   *
   * @return string
   *   String representation of array.
   */
  static string ArrToString3D(double& arr[][][], string dlm = ",", int digits = 2) {
    string res = "";
    int i, j, k;
    for (i = 0; i < ArrayRange(arr, 0); i++) {
      res += "[";
      for (j = 0; j < ArrayRange(arr, 1); j++) {
        res += "[";
        for (k = 0; k < ArrayRange(arr, 2); k++) {
          res += StringFormat("%g%s", NormalizeDouble(arr[i][j][k], digits), dlm);
        }
        res = StringSubstr(res, 0, StringLen(res) - StringLen(dlm));
        res += "]" + dlm;
      }
      res = StringSubstr(res, 0, StringLen(res) - StringLen(dlm));
      res += "]" + dlm;
    }
    res = StringSubstr(res, 0, StringLen(res) - StringLen(dlm));
    return res;
  }
#endif

#ifdef __MQL__
  /**
   * Print a one-dimensional array.
   *
   * @param string arr
   *   The one dimensional array of strings.
   * @param string dlm
   *   Delimiter to separate the items.
   * @param string prefix
   *   Prefix to add if array is non-empty.
   * @param string suffix
   *   Suffix to add if array is non-empty.
   *
   * @return string
   *   String representation of array.
   */
  static string ArrToString(string& arr[], string dlm = ",", string prefix = "", string suffix = "") {
    int i;
    string output = "";
    if (ArraySize(arr) > 0) output += prefix;
    for (i = 0; i < ArraySize(arr); i++) {
      output += (string) arr[i] + dlm;
    }
    output = StringSubstr(output, 0, StringLen(output) - StringLen(dlm));
    if (ArraySize(arr) > 0) output += suffix;
    return output;
  }
#endif

#ifdef __MQL__
  /**
   * Prints an array of a simple type.
   *
   * @docs:
   * - https://www.mql5.com/en/docs/array/arrayprint
   */
  template<typename T>
  void ArrayPrint(
    T             &_arr[],              // Printed array.
    int          _digits = NULL,       // Number of decimal places.
    const string  _dlm = NULL,          // Separator of the structure field values.
    long         _start = 0,           // First printed element index.
    long         _count = WHOLE_ARRAY, // Number of printed elements.
    long         _flags = NULL
  ) {
#ifdef __MQL4__
    int i;
    string output = "";
    for (i = _start; i < _count == WHOLE_ARRAY ? ArraySize(_arr) : _count; i++) {
      output += (string) _arr[i] + _dlm;
    }
    Print(output);
#else
    ::ArrayPrint(_arr, _digits, _dlm, _start, _count, _flags);
#endif
  }
#endif

#ifdef __MQL__
  /**
   * Resize array from the left.
   *
   * @param string arr
   *   The one dimensional array of doubles.
   * @param int _new_size
   *   New size of array.
   *
   * @return bool
   *   Returns count of all elements contained in the array after resizing,
   *   otherwise returns -1 without resizing array.
   *
   * @see: http://www.forexfactory.com/showthread.php?p=2878455#post2878455
   */
  static int ArrayResizeLeft(double &arr[], int _new_size, int _reserve_size = 0) {
    ArraySetAsSeries(arr, true);
    int _res = ArrayResize(arr, _new_size, _reserve_size);
    ArraySetAsSeries(arr, false);
    return _res;
  }
#endif

#ifdef __MQL__
  /**
   * Sorts numeric arrays by first dimension.
   *
   * @param &array[] arr
   *   Numeric array for sorting.
   * @param int count
   *   Count of elements to sort. By default, it sorts the whole array (WHOLE_ARRAY).
   * @param int start
   *   Starting index to sort. By default, the sort starts at the first element.
   * @param int direction
   *   Sort direction. It can be any of the following values: MODE_ASCEND or MODE_DESCEND.
   *
   * @return bool
   *   The function returns true on success, otherwise false.
   *
   * @docs:
   *   - https://docs.mql4.com/array/arraysort
   *   - https://www.mql5.com/en/docs/array/arraysort
   *   - https://www.mql5.com/en/docs/array/array_reverse
   */
  // One dimensional array.
  template<typename T>
  static bool ArraySort(T &arr[], int count = WHOLE_ARRAY, int start = 0, int direction = MODE_ASCEND) {
#ifdef __MQL4__
  return ::ArraySort(arr, count, start, direction);
#else
  if (_direction == MODE_DESCEND) {
    return ::ArrayReverse(arr, start, count);
  }
  else {
    // @fixme: Add support for _count and _start.
    return ::ArraySort(arr);
  }
#endif
  }
  // Two dimensional array.
#ifdef __MQL4__
  template<typename T>
  static bool ArraySort2D(T &arr[][], int count = WHOLE_ARRAY, int start = 0, int direction = MODE_ASCEND) {
#ifdef __MQL4__
  return (bool) ::ArraySort(arr, count, start, direction);
#else
  if (_direction == MODE_DESCEND) {
    return ::ArrayReverse(arr, start, count);
  }
  else {
    // @fixme: Add support for _count amd _start.
    return ::ArraySort(arr);
  }
#endif
  }
#endif

#ifdef __MQL__
  /**
   * Resizes array and fills allocated slots with given value.
   *
   * @param &array[] array
   *   Single dimensonal array. For multi-dimensional array consider: template <typename X, typename Y> int ArrayResizeFill(X &array[][2], int new_size, int reserve_size = 0, Y fill_value = EMPTY) { ... }
   * @param int new_size
   *   New array size.
   * @param reserve_size
   *   Reserve size value (excess).
   * @param fill_value
   *   Value to be used as filler for allocated slots.
   * @return int
   *   Returns the same value as ArrayResize function (count of all elements contained in the array after resizing or -1 if error occured).
   */
  template <typename X, typename Y>
  static int ArrayResizeFill(X &array[], int new_size, int reserve_size = 0, Y fill_value = EMPTY_VALUE) {
    const int old_size = ArrayRange(array, 0);

    if (new_size <= old_size)
      return old_size;

    // We want to fill all allocated slots (the whole allocated memory).
    const int allocated_size = MathMax(new_size, reserve_size);

    int result = ArrayResize(array, new_size, reserve_size);

    ArrayFill(array, old_size, allocated_size - old_size, fill_value);

    return result;
  }
#endif

#ifdef __MQL__
  /**
   * Initializes a numeric array by a preset value.
   *
   * @param array[]
   *   Numeric array that should be initialized.
   * @param char value
   *   New value that should be set to all array elements.
   * @return int
   *   Number of initialized elements.
   *
   * @docs
   * - https://docs.mql4.com/array/arrayinitialize
   * - https://www.mql5.com/en/docs/array/arrayinitialize
   */
  template <typename X>
  static int ArrayInitialize(X &array[], char value) {
    return ::ArrayInitialize(array, value);
  }
#endif

#ifdef __MQL__
  /**
   * Searches for the lowest element in the first dimension of a multidimensional numeric array.
   *
   * @param void &array[]
   *   A numeric array, in which search is made.
   * @param int start
   *   Index to start checking with.
   * @param int count
   *   Number of elements for search. By default, searches in the entire array.
   * @return int
   *   The function returns an index of a found element.
   *
   * @docs
   * - https://docs.mql4.com/array/arraymaximum
   * - https://www.mql5.com/en/docs/array/arraymaximum
   */
  template <typename X>
  static int ArrayMinimum(const X &array[], int start = 0, int count = WHOLE_ARRAY) {
    return ::ArrayMinimum(array);
  }
#endif

#ifdef __MQL__
  /**
   * Searches for the largest element in the first dimension of a multidimensional numeric array.
   *
   * @param void &array[]
   *   A numeric array, in which search is made.
   * @param int start
   *   Index to start checking with.
   * @param int count
   *   Number of elements for search. By default, searches in the entire array.
   * @return int
   *   The function returns an index of a found element.
   *
   * @docs
   * - https://docs.mql4.com/array/arraymaximum
   * - https://www.mql5.com/en/docs/array/arraymaximum
   */
  template <typename X>
  static int ArrayMaximum(const X &array[], int start = 0, int count = WHOLE_ARRAY) {
    return ::ArrayMaximum(array);
  }
#endif

#ifdef __MQL__
  /**
   * Returns the number of elements of a selected array.
   *
   * @param void &array[]
   *   Array of any type.
   * @return int
   *   Value of int type.
   *
   * @docs
   * - https://docs.mql4.com/array/arraysize
   * - https://www.mql5.com/en/docs/array/arraysize
   */
  template <typename X>
  static int ArraySize(const X &array[]) {
    return ::ArraySize(array);
  }
#endif

};
#endif // ARRAY_MQH
