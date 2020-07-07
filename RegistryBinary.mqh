class RegistryBinary {
    struct data
    {
         int  key;
         int  val;
    };

    int handle, size;
    string filename;
    data array[], copyArray[];

    public:

        void RegistryBinary (string path = "", bool binary = 0) {
               if (binary == 0)
               {
                     if (path != "") {

                          handle = FileOpen(path, FILE_READ|FILE_CSV|FILE_ANSI, "=");

                          if (handle != INVALID_HANDLE)
                          {
                                    int count = 0;
                                    while(FileIsEnding(handle)==false)
                                    {
                                          ArrayResize(array,(count+1),100000);

                                          array[count].key = FileReadInteger(handle);
                                          array[count].val = FileReadInteger(handle);
                                          count++;
                                    }
                          }

                          FileClose(handle);

                          filename = path;
                     }
               }
               else
               {
                           // @todo Add support for binary files, numeric instead of string key and val
                          handle = FileOpen(path, FILE_BIN|FILE_READ);

                          if (handle != INVALID_HANDLE)
                          {
                                 FileReadArray(handle, array, 0, WHOLE_ARRAY);
                          }

                          FileClose(handle);

                          filename = path;
               }

        }

        bool Save (string path = "", bool binary = 0) {

                  if (path == "")
                  {
                        path = filename;
                  }

                  if (binary == 0)
                  {
                        handle = FileOpen(path, FILE_WRITE|FILE_CSV, "=");

                        if(handle != INVALID_HANDLE)
                        {
                              size = ArraySize(array);

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
                  else
                  {
                        // @todo Add support for binary files, numeric instead of string key and val

                        handle = FileOpen(path, FILE_BIN|FILE_WRITE);

                        if(handle != INVALID_HANDLE)
                        {
                              size = ArraySize(array);

                              if(size > 0)
                              {
                                    FileWriteArray(handle,array, 0, WHOLE_ARRAY);
                              }

                              FileClose(handle);
                              return true;
                        } else {
                              FileClose(handle);
                              return false;
                        }
                  }
        }

        string GetKeys (bool withValues = 0) {

               size = ArraySize(array);
               string keys = "Empty";

               if(size > 0)
               {
                     keys = "";
                     for (int i = 0; i < size; i++)
                     {
                               keys += IntegerToString(array[i].key);

                               if (withValues == 1) {
                                    keys += "=" + IntegerToString(array[i].val);
                               }

                               keys += ";";
                     }
               }

               return keys;
        }

        bool Delete (int key) {

               size = ArraySize(array);

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

        int GetValueInteger (int key) {

               size = ArraySize(array);

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

        /*
        double GetValueDouble (int key) {

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
        */

        bool SetValue (int key, int value) {

               size = ArraySize(array);
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

        /*
        bool SetValue (int key, double value) {

               size = ArraySize(array);
               int i = 0;

               if(size > 0)
               {
                     for (;i < size; i++)
                     {
                          if (array[i].key == key)
                          {
                              array[i].val = DoubleToString(value);
                              return(1);
                              break;
                          }
                     }
               }

               ArrayResize(array, (size+1), 100000);

               array[i].key = key;
               array[i].val = DoubleToString(value);

               return(1);
        }
        */

};
