//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Implements class for storing, importing and exporting configuration.
 */

// Prevents processing this includes file for the second time.
#ifndef CONFIG_MQH
#define CONFIG_MQH

// Includes.
#include "Object.mqh"
#include "DictStruct.mqh"
#include "File.mqh"

enum CONFIG_FORMAT {
  CONFIG_FORMAT_JSON,
  CONFIG_FORMAT_JSON_NO_WHITESPACES,
  CONFIG_FORMAT_INI
};

string ToJSON(const MqlParam& param, bool, int) {
  switch (param.type) {
    case TYPE_BOOL:
      //boolean 
      return JSON::Stringify((bool)param.integer_value);
    case TYPE_INT:
      return JSON::Stringify((int)param.integer_value);
      break;
    case TYPE_DOUBLE:
    case TYPE_FLOAT:
      return JSON::Stringify(param.double_value);
      break;
    case TYPE_CHAR:
    case TYPE_STRING:
      return JSON::Stringify(param.string_value, true);
      break;
    case TYPE_DATETIME:
    #ifdef __MQL5__
      return JSON::Stringify(TimeToString(param.integer_value), true);
    #else
      return JSON::Stringify(TimeToStr(param.integer_value), true);
    #endif
      break;
  }
  return "\"Unsupported MqlParam.ToJSON type: \"" + IntegerToString(param.type) + "\"";
}

template<typename X>
MqlParam MakeParam(X& value) {
  return MqlParam(value);
}

// Structs.
struct ConfigEntry : public MqlParam {
 public:
  bool operator== (const ConfigEntry& _s) {
    return type == _s.type && double_value == _s.double_value && integer_value == _s.integer_value && string_value == _s.string_value;
  }
};

class Config : public DictStruct<string, ConfigEntry> {
 private:
 protected:
  File *file;

 public:
  /**
   * Class constructor.
   */
  Config(bool _use_file = false) {
    if (_use_file) {
      file = new File();
    }
  }
  
  bool Set(string key, bool value) {
    ConfigEntry param = {TYPE_BOOL, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, int value) {
    ConfigEntry param = {TYPE_INT, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, long value) {
    ConfigEntry param = {TYPE_LONG, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, double value) {
    ConfigEntry param = {TYPE_DOUBLE, 0, 0, ""};
    param.double_value = value;
    return Set(key, param);
  }

  bool Set(string key, string value) {
    ConfigEntry param = {TYPE_STRING, 0, 0, ""};
    param.string_value = value;
    return Set(key, param);
  }

  bool Set(string key, datetime value) {
    ConfigEntry param = {TYPE_DATETIME, 0, 0, ""};
    param.integer_value = value;
    return Set(key, param);
  }

  bool Set(string key, ConfigEntry &value) {
    return ((DictStruct<string, ConfigEntry> *) GetPointer(this)).Set(key, value);
  }

  /* File methods */

  template<typename K, typename V>
  static void SetProperty(DictStruct<K, V>& obj, string key, JSONParam* value, JSONNode* node = NULL) {
    Print("Setting struct property \"" + key + "\" = \"" + value.AsString() + "\" for object");
  }


  static void SetProperty(ConfigEntry& obj, string key, JSONParam* value, JSONNode* node = NULL) {
    Print("Setting config property \"" + key + "\" = \"" + value.AsString() + "\" for object");
  }

  template<typename K, typename V>
  void InsertNode(JSONNode* node, DictStruct<K, V>& target) {
    if (node.GetType() == JSONNODE_TYPE_OBJECT) {
      V obj;
      
      for (unsigned int i = 0; i < node.NumChildren(); ++i) {
        JSONNode* child = node.GetChild(i);
        JSONPARAM_TYPE paramType = child.GetValue().GetType();
        
        if (paramType == JSONPARAM_TYPE_STRING) {
          string key = child.GetKey().AsString();
          string value = child.GetValue().AsString();
          SetProperty(obj, key, child.GetValue(), child);
        }
      }
    }
  }

  /**
   * Loads config from the file.
   */
  bool LoadFromFile(string path, CONFIG_FORMAT format) {
    int handle = FileOpen(path, FILE_READ | FILE_TXT, 0, CP_UTF8);
    
    if (handle == INVALID_HANDLE) {
      string terminalDataPath = TerminalInfoString(TERMINAL_DATA_PATH);
      #ifdef __MQL5__
        string terminalSubfolder = "MQL5";
      #else
        string terminalSubfolder = "MQL4";
      #endif
      Print("Cannot open file \"", path , "\" for reading. Error code: ", GetLastError(), ". Consider using path relative to \"" + terminalDataPath + "\\" + terminalSubfolder + "\\Files\\\" as absolute paths may not work.");
      return false;
    }
    
    string data = FileReadString(handle);
    
    FileClose(handle);
    
    JSONNode* node = NULL;

    if (format == CONFIG_FORMAT_JSON || CONFIG_FORMAT_JSON_NO_WHITESPACES) {
        node = JSON::Parse(data);
        
        if (!node) {
          Print("Cannot parse JSON!");
          return false;
        }
        
        InsertNode(node, this);
        
        delete node;
    }
    else
    if (format == CONFIG_FORMAT_INI) {
    }   

    return true;
  }

  /**
   * Save config into the file.
   */
  bool SaveToFile(string path, CONFIG_FORMAT format) {
    int handle = FileOpen(path, FILE_WRITE | FILE_TXT, 0, CP_UTF8);
    
    if (handle == INVALID_HANDLE) {
      string terminalDataPath = TerminalInfoString(TERMINAL_DATA_PATH);
      #ifdef __MQL5__
        string terminalSubfolder = "MQL5";
      #else
        string terminalSubfolder = "MQL4";
      #endif
      Print("Cannot open file \"", path , "\" for writing. Error code: ", GetLastError(), ". Consider using path relative to \"" + terminalDataPath + "\\" + terminalSubfolder + "\\Files\\\" as absolute paths may not work.");
      return false;
    }

    string text;
    
    switch (format) {
      case CONFIG_FORMAT_JSON: text = ToJSON(false); break;
      case CONFIG_FORMAT_JSON_NO_WHITESPACES: text = ToJSON(true); break;
      case CONFIG_FORMAT_INI: text = ToINI(); break;
    }   
    
    FileWriteString(handle, text);
    
    FileClose(handle);
   
    return true;
  }

  /**
   * Returns config in plain format.
   */
  string ToINI() { return "Ini file"; }
};
#endif  // CONFIG_MQH
