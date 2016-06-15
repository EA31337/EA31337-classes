class Registry {
    struct data
    {
         string  key;
         string  val;
    };
        
    int handle;
    string filename;
    data array[], copyArray[];
         
    public:
    
        void Registry (string path = "") {
        
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
        
        bool Save (string path = "") {
        
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
                        return(1);
                  } else {
                        FileClose(handle);
                        return(0);
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
                              return(1);
                              break;
                          }                                
                     }
               }
               
               return(0);
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
                              return(1);
                              break;
                          }        
                     }
               }               
               
               ArrayResize(array, (size+1), 100000);

               array[i].key = key;
               array[i].val = value;

               return(1);
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
                              return(1);
                              break;
                          }        
                     }
               }               

               ArrayResize(array, (size+1), 100000);

               array[i].key = key;
               array[i].val = IntegerToString(value);

               return(1);
        }
        
};