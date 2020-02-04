#define JSON_INDENTATION 2

#include "Dict.mqh"

class JSON
{
public:
  
  static string Stringify(bool value, uint indent = 0) {
    return value ? "true" : "false";
  }

  static string Stringify(int value, uint indent = 0) {
    return IntegerToString(value);
  }

  static string Stringify(string value, uint indent = 0) {
    return "\"" + value + "\"";
  }

  static string Stringify(float value, uint indent = 0) {
    return DoubleToString(value);
  }

  static string Stringify(double value, uint indent = 0) {
    return DoubleToString(value);
  }
};