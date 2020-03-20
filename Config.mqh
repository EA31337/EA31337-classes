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
      return JSON::ValueToString((bool)param.integer_value);
    case TYPE_INT:
      return JSON::ValueToString((int)param.integer_value);
      break;
    case TYPE_DOUBLE:
    case TYPE_FLOAT:
      return JSON::ValueToString(param.double_value);
      break;
    case TYPE_CHAR:
    case TYPE_STRING:
      return JSON::ValueToString(param.string_value, true);
      break;
    case TYPE_DATETIME:
    #ifdef __MQL5__
      return JSON::ValueToString(TimeToString(param.integer_value), true);
    #else
      return JSON::ValueToString(TimeToStr(param.integer_value), true);
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
  void SetProperty(string key, JsonParam* value, JsonNode* node = NULL) {
    //Print("Setting config entry property \"" + key + "\" = \"" + value.AsString() + "\" for object");
  }

  bool operator== (const ConfigEntry& _s) {
    return type == _s.type && double_value == _s.double_value && integer_value == _s.integer_value && string_value == _s.string_value;
  }
  
  JsonNodeType Serialize(JsonSerializer& s) {
    s.PassEnum(this, "type", type);
    
    string aux_string;
    
    switch (type) {
      case TYPE_BOOL:
      case TYPE_UCHAR:
      case TYPE_CHAR:
      case TYPE_USHORT:
      case TYPE_SHORT:
      case TYPE_UINT:
      case TYPE_INT:
      case TYPE_ULONG:
      case TYPE_LONG:
        s.Pass(this, "value", integer_value);
        break;
        
      case TYPE_DOUBLE:
        s.Pass(this, "value", double_value);
        break;
        
      case TYPE_STRING:
        s.Pass(this, "value", string_value);
        break;
    
      case TYPE_DATETIME:
        if (s.IsWriting()) {
          aux_string = TimeToString(integer_value);
          s.Pass(this, "value", aux_string);
        }
        else {
          s.Pass(this, "value", aux_string);
          integer_value = StringToTime(aux_string);
        }
        break;
    }
    
    return JsonNodeObject;
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
  static void SetProperty(DictStruct<K, V>& obj, string key, JsonParam* value, JsonNode* node = NULL) {
    //Print("Setting struct property \"" + key + "\" = \"" + value.AsString() + "\" for object");
  }

  /**
   * Loads config from the file.
   */
  bool LoadFromFile(string path, CONFIG_FORMAT format) {
    int handle = FileOpen(path, FILE_READ | FILE_ANSI, 0);
    ResetLastError();

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

    string data = "";
    
    while (!FileIsEnding(handle)) {
      data += FileReadString(handle) + "\n";
    }
    
    FileClose(handle);
    
    if (format == CONFIG_FORMAT_JSON || format == CONFIG_FORMAT_JSON_NO_WHITESPACES) {
        if (!JSON::Parse(data, this)) {
          Print("Cannot parse JSON!");
          return false;
        }
    } else if (format == CONFIG_FORMAT_INI) {
      // @todo
    }   

    return true;
  }
  
  /**
   * Save config into the file.
   */
  bool SaveToFile(string path, CONFIG_FORMAT format) {
    ResetLastError();

    int handle = FileOpen(path, FILE_WRITE | FILE_ANSI);
    
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
    
    string text = JSON::Stringify(this);

    FileWriteString(handle, text);

    FileClose(handle);

    return GetLastError() == ERR_NO_ERROR;
  }

  /**
   * Returns config in plain format.
   */
  string ToINI() { return "Ini file"; } // @todo
};
#endif  // CONFIG_MQH
