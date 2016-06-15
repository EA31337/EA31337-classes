class SetFile {
    struct data
    {
         string  key;
         string  val;
    };

    int handle, count;
    data array[];

    public:

        bool LoadFromFile(string path) {
               handle = FileOpen(path, FILE_READ|FILE_CSV|FILE_ANSI, '=');

              if (handle == INVALID_HANDLE) {
                     //PrintFormat("Failed to open %s file, Error code = %d", handle,GetLastError());
                      FileClose(handle);
                     return(0);
              }

              if (FileSize(handle) == 0) {
                     //PrintFormat("Failed to open %s file, Error code = %d", handle,GetLastError());
                     FileClose(handle);
                     return(0);
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

               return(1);
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
                        return(1);
                        break;
                    }
               }

               ArrayResize(array,(i+2),100000);

               array[(i + 1)].key = key;
               array[(i + 1)].val = value;

               return(1);
        }

        bool SetValue (string key, double value) {

               int i = 0;
               for (;i <= ArraySize(array); i++)
               {
                    if (array[i].key == key)
                    {
                        array[i].val = DoubleToString(value);
                        return(1);
                        break;
                    }
               }

               ArrayResize(array,(i+2),100000);

               array[(i + 1)].key = key;
               array[(i + 1)].val = DoubleToString(value);

               return(1);
        }

        bool SetValue (string key, int value) {

               int i = 0;
               for (;i <= ArraySize(array); i++)
               {
                    if (array[i].key == key)
                    {
                        array[i].val = IntegerToString(value);
                        return(1);
                        break;
                    }
               }

               ArrayResize(array,(i+2),100000);

               array[(i + 1)].key = key;
               array[(i + 1)].val = IntegerToString(value);

               return(1);
        }

};
