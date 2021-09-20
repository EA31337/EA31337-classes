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

/**
 * Class to provide storing mechanism.
 */
class Registry {
  struct RegistryData
  {
    string  key;
    string  val;
  };

  int handle;
  string filename;
  RegistryData array[], copyArray[];

  public:

  Registry(string path = "") {

    if (path != "") {

      handle = FileOpen(path, FILE_READ|FILE_CSV|FILE_ANSI, "=");

      if (handle != INVALID_HANDLE)
      {
        int count = 0;
        while(FileIsEnding(handle)==false)
        {
          ArrayResize(array,(count+1),100000);

          array[count].key = FileReadString(handle);
          array[count].val = FileReadString(handle);
          count++;
        }
      }

      FileClose(handle);

      filename = path;
    }

  }

  bool Save(string path = "") {

    if (path == "")
    {
      path = filename;
    }

    handle = FileOpen(path, FILE_WRITE|FILE_CSV, "=");

    if(handle != INVALID_HANDLE)
    {
      int size = ArraySize(array);

      if(size > 0)
      {
        for (int i = 0; i < size; i++)
        {
          FileWrite(handle, array[i].key, array[i].val);
        }
      }

      FileClose(handle);
      return true;
    } else {
      FileClose(handle);
      return false;
    }
  }

  string GetKeys (bool withValues = 0) {

    int size = ArraySize(array);
    string keys = "Empty";

    if(size > 0)
    {
      keys = "";
      for (int i = 0; i < size; i++)
      {
        keys += array[i].key;

        if (withValues == 1) {
          keys += "=" + array[i].val;
        }

        keys += ";";
      }
    }

    return keys;
  }

  bool Delete (string key) {
    int size = ArraySize(array);

    if(size > 0)
    {
      int offset = 0;
      for (int i = 0; i < size; i++)
      {
        if (array[i].key == key)
        {
          Erase(array, i);
          return true;
          break;
        }
      }
    }

    return false;
  }

  template <typename T>
    void Erase(T& A[], int iPos){
      int iLast = ArraySize(A) - 1;
      A[iPos].key = A[iLast].key;
      A[iPos].val = A[iLast].val;
      ArrayResize(A, iLast);
    }

  string GetValueString (string key) {

    int size = ArraySize(array);

    if(size > 0)
    {
      for (int i = 0; i < size; i++)
      {
        if (array[i].key == key)
        {
          return(array[i].val);
          break;
        }
      }
    }

    return(NULL);
  }

  int GetValueInteger (string key) {

    string value = GetValueString(key);

    if(value != NULL) {
#ifdef MQL4
      return(StrToInteger(value));
#else
      return((int) StringToInteger(value));
#endif
    } else {
      return(NULL);
    }
  }

  double GetValueDouble (string key) {

    string value = GetValueString(key);

    if(value != NULL) {
#ifdef MQL4
      return(StrToDouble(value));
#else
      return(StringToDouble(value));
#endif
    } else {
      return(NULL);
    }
  }

  bool SetValue (string key, string value) {

    int size = ArraySize(array);
    int i = 0;

    if(size > 0)
    {
      for (;i < size; i++)
      {
        if (array[i].key == key)
        {
          array[i].val = value;
          return true;
          break;
        }
      }
    }

    ArrayResize(array, (size+1), 100000);

    array[i].key = key;
    array[i].val = value;

    return true;
  }

  bool SetValue (string key, double value) {

    int size = ArraySize(array);
    int i = 0;

    if(size > 0)
    {
      for (;i < size; i++)
      {
        if (array[i].key == key)
        {
          array[i].val = DoubleToString(value);
          return true;
          break;
        }
      }
    }

    ArrayResize(array, (size+1), 100000);

    array[i].key = key;
    array[i].val = DoubleToString(value);

    return true;
  }

  bool SetValue (string key, int value) {

    int size = ArraySize(array);
    int i = 0;

    if(size > 0)
    {
      for (;i < size; i++)
      {
        if (array[i].key == key)
        {
          array[i].val = IntegerToString(value);
          return true;
          break;
        }
      }
    }

    ArrayResize(array, (size+1), 100000);

    array[i].key = key;
    array[i].val = IntegerToString(value);

    return true;
  }

};
