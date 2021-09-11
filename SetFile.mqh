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

class SetFile {
    struct SetFileData
    {
         string  key;
         string  val;
    };

    int handle, count;
    SetFileData array[];

    public:

        bool LoadFromFile(string path) {
               handle = FileOpen(path, FILE_READ|FILE_CSV|FILE_ANSI, '=');

              if (handle == INVALID_HANDLE) {
                     //PrintFormat("Failed to open %s file, Error code = %d", handle,GetLastError());
                      FileClose(handle);
                     return true;
              }

              if (FileSize(handle) == 0) {
                     //PrintFormat("Failed to open %s file, Error code = %d", handle,GetLastError());
                     FileClose(handle);
                     return false;
              }

               count = 0;
               while(FileIsEnding(handle)==false)
               {
                     ArrayResize(array,(count+1),100000);

                     array[count].key = FileReadString(handle);
                     array[count].val = FileReadString(handle);
                     count++;
               }

               FileClose(handle);

               return true;
        }

        string GetValueString (string key) {

               for (int i = 0; i <= ArraySize(array); i++)
               {
                    if (array[i].key == key)
                    {
                        return(array[i].val);
                        break;
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

               int i = 0;
               for (;i <= ArraySize(array); i++)
               {
                    if (array[i].key == key)
                    {
                        array[i].val = value;
                        return true;
                        break;
                    }
               }

               ArrayResize(array,(i+2),100000);

               array[(i + 1)].key = key;
               array[(i + 1)].val = value;

               return true;
        }

        bool SetValue (string key, double value) {

               int i = 0;
               for (;i <= ArraySize(array); i++)
               {
                    if (array[i].key == key)
                    {
                        array[i].val = DoubleToString(value);
                        return true;
                        break;
                    }
               }

               ArrayResize(array,(i+2),100000);

               array[(i + 1)].key = key;
               array[(i + 1)].val = DoubleToString(value);

               return true;
        }

        bool SetValue (string key, int value) {

               int i = 0;
               for (;i <= ArraySize(array); i++)
               {
                    if (array[i].key == key)
                    {
                        array[i].val = IntegerToString(value);
                        return true;
                        break;
                    }
               }

               ArrayResize(array,(i+2),100000);

               array[(i + 1)].key = key;
               array[(i + 1)].val = IntegerToString(value);

               return true;
        }

};
