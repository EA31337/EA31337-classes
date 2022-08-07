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
 * @file
 * Includes Market's structs.
 */

// Forward declaration.
class Serializer;

// Includes.
#include "DateTime.struct.h"
#include "SerializerNode.enum.h"
#include "Std.h"

// Market info.
struct MarketData {
  int empty;
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer &_s) { return SerializerNodeObject; }
};

// Structure for trade time static methods.
struct MarketTimeForex : DateTimeEntry {
  // Market sessions for trading Forex.
  enum ENUM_MARKET_TIME_FOREX_HOURS {
    MARKET_TIME_FOREX_HOURS_NONE = 0 << 0,
    // By city.
    MARKET_TIME_FOREX_HOURS_CHICAGO = 1 << 0,
    MARKET_TIME_FOREX_HOURS_FRANKFURT = 1 << 1,
    MARKET_TIME_FOREX_HOURS_HONGKONG = 1 << 2,
    MARKET_TIME_FOREX_HOURS_LONDON = 1 << 3,
    MARKET_TIME_FOREX_HOURS_NEWYORK = 1 << 4,
    MARKET_TIME_FOREX_HOURS_SYDNEY = 1 << 5,
    MARKET_TIME_FOREX_HOURS_TOKYO = 1 << 6,
    MARKET_TIME_FOREX_HOURS_WELLINGTON = 1 << 7,
    // By region.
    MARKET_TIME_FOREX_HOURS_AMERICA = MARKET_TIME_FOREX_HOURS_NEWYORK | MARKET_TIME_FOREX_HOURS_CHICAGO,
    MARKET_TIME_FOREX_HOURS_ASIA = MARKET_TIME_FOREX_HOURS_TOKYO | MARKET_TIME_FOREX_HOURS_HONGKONG,
    MARKET_TIME_FOREX_HOURS_EUROPE = MARKET_TIME_FOREX_HOURS_LONDON | MARKET_TIME_FOREX_HOURS_FRANKFURT,
    MARKET_TIME_FOREX_HOURS_PACIFIC = MARKET_TIME_FOREX_HOURS_SYDNEY | MARKET_TIME_FOREX_HOURS_WELLINGTON,
  };
  // Constructors.
  MarketTimeForex() { Set(::TimeGMT()); }
  MarketTimeForex(datetime _time_gmt) { Set(_time_gmt); }
  MarketTimeForex(MqlDateTime &_dt_gmt) { Set(_dt_gmt); }
  // State methods.
  /* Getters */
  bool CheckHours(unsigned int _hours_enums) {
    // Trading sessions according to GMT (Greenwich Mean Time).
    if (_hours_enums > 0) {
      unsigned short _hopen = 24, _hclose = 0;
      // By city.
      if ((_hours_enums & MARKET_TIME_FOREX_HOURS_LONDON) != 0) {
        _hopen =
            _hopen > GetOpenHour(MARKET_TIME_FOREX_HOURS_LONDON) ? GetOpenHour(MARKET_TIME_FOREX_HOURS_LONDON) : _hopen;
        _hclose = _hclose < GetCloseHour(MARKET_TIME_FOREX_HOURS_LONDON) ? GetCloseHour(MARKET_TIME_FOREX_HOURS_LONDON)
                                                                         : _hclose;
      }
      if ((_hours_enums & MARKET_TIME_FOREX_HOURS_FRANKFURT) != 0) {
        _hopen = _hopen > GetOpenHour(MARKET_TIME_FOREX_HOURS_FRANKFURT)
                     ? GetOpenHour(MARKET_TIME_FOREX_HOURS_FRANKFURT)
                     : _hopen;
        _hclose = _hclose < GetCloseHour(MARKET_TIME_FOREX_HOURS_FRANKFURT)
                      ? GetCloseHour(MARKET_TIME_FOREX_HOURS_FRANKFURT)
                      : _hclose;
      }
      if ((_hours_enums & MARKET_TIME_FOREX_HOURS_NEWYORK) != 0) {
        _hopen = _hopen > GetOpenHour(MARKET_TIME_FOREX_HOURS_NEWYORK) ? GetOpenHour(MARKET_TIME_FOREX_HOURS_NEWYORK)
                                                                       : _hopen;
        _hclose = _hclose < GetCloseHour(MARKET_TIME_FOREX_HOURS_NEWYORK)
                      ? GetCloseHour(MARKET_TIME_FOREX_HOURS_NEWYORK)
                      : _hclose;
      }
      if ((_hours_enums & MARKET_TIME_FOREX_HOURS_CHICAGO) != 0) {
        _hopen = _hopen > GetOpenHour(MARKET_TIME_FOREX_HOURS_CHICAGO) ? GetOpenHour(MARKET_TIME_FOREX_HOURS_CHICAGO)
                                                                       : _hopen;
        _hclose = _hclose < GetCloseHour(MARKET_TIME_FOREX_HOURS_CHICAGO)
                      ? GetCloseHour(MARKET_TIME_FOREX_HOURS_CHICAGO)
                      : _hclose;
      }
      if ((_hours_enums & MARKET_TIME_FOREX_HOURS_TOKYO) != 0) {
        _hopen =
            _hopen > GetOpenHour(MARKET_TIME_FOREX_HOURS_TOKYO) ? GetOpenHour(MARKET_TIME_FOREX_HOURS_TOKYO) : _hopen;
        _hclose = _hclose < GetCloseHour(MARKET_TIME_FOREX_HOURS_TOKYO) ? GetCloseHour(MARKET_TIME_FOREX_HOURS_TOKYO)
                                                                        : _hclose;
      }
      if ((_hours_enums & MARKET_TIME_FOREX_HOURS_HONGKONG) != 0) {
        _hopen = _hopen > GetOpenHour(MARKET_TIME_FOREX_HOURS_HONGKONG) ? GetOpenHour(MARKET_TIME_FOREX_HOURS_HONGKONG)
                                                                        : _hopen;
        _hclose = _hclose < GetCloseHour(MARKET_TIME_FOREX_HOURS_HONGKONG)
                      ? GetCloseHour(MARKET_TIME_FOREX_HOURS_HONGKONG)
                      : _hclose;
      }
      if ((_hours_enums & MARKET_TIME_FOREX_HOURS_SYDNEY) != 0) {
        // @todo: _market_hours.CheckHours(MarketForexTime::MARKET_TIME_FOREX_HOURS_EUROPE |
        // MarketForexTime::MARKET_TIME_FOREX_HOURS_PACIFIC)
        _hopen =
            _hopen > GetOpenHour(MARKET_TIME_FOREX_HOURS_SYDNEY) ? GetOpenHour(MARKET_TIME_FOREX_HOURS_SYDNEY) : _hopen;
        _hclose = _hclose < GetCloseHour(MARKET_TIME_FOREX_HOURS_SYDNEY) ? GetCloseHour(MARKET_TIME_FOREX_HOURS_SYDNEY)
                                                                         : _hclose;
      }
      if ((_hours_enums & MARKET_TIME_FOREX_HOURS_WELLINGTON) != 0) {
        // @todo: _market_hours.CheckHours(MarketForexTime::MARKET_TIME_FOREX_HOURS_EUROPE |
        // MarketForexTime::MARKET_TIME_FOREX_HOURS_PACIFIC)
        _hopen = _hopen > GetOpenHour(MARKET_TIME_FOREX_HOURS_WELLINGTON)
                     ? GetOpenHour(MARKET_TIME_FOREX_HOURS_WELLINGTON)
                     : _hopen;
        _hclose = _hclose < GetCloseHour(MARKET_TIME_FOREX_HOURS_WELLINGTON)
                      ? GetCloseHour(MARKET_TIME_FOREX_HOURS_WELLINGTON)
                      : _hclose;
      }
      return _hopen < _hclose ? hour >= _hopen && hour <= _hclose : hour >= _hopen || hour <= _hclose;
    }
    return false;
  }
  // Returns market close hour given a city or a region.
  unsigned short GetCloseHour(ENUM_MARKET_TIME_FOREX_HOURS _enum) {
    // Trading sessions according to GMT (Greenwich Mean Time).
    // Source: http://www.forexmarkethours.com/GMT_hours/02/
    switch (_enum) {
      case MARKET_TIME_FOREX_HOURS_CHICAGO:
        return 23;
      case MARKET_TIME_FOREX_HOURS_FRANKFURT:
        return 16;
      case MARKET_TIME_FOREX_HOURS_HONGKONG:
        return 10;
      case MARKET_TIME_FOREX_HOURS_LONDON:
        return 17;
      case MARKET_TIME_FOREX_HOURS_NEWYORK:
        return 22;
      case MARKET_TIME_FOREX_HOURS_SYDNEY:
        return 7;
      case MARKET_TIME_FOREX_HOURS_TOKYO:
        return 9;
      case MARKET_TIME_FOREX_HOURS_WELLINGTON:
        return 6;
      case MARKET_TIME_FOREX_HOURS_AMERICA:
        return MathMax(GetCloseHour(MARKET_TIME_FOREX_HOURS_NEWYORK), GetCloseHour(MARKET_TIME_FOREX_HOURS_CHICAGO));
      case MARKET_TIME_FOREX_HOURS_ASIA:
        return MathMax(GetCloseHour(MARKET_TIME_FOREX_HOURS_TOKYO), GetCloseHour(MARKET_TIME_FOREX_HOURS_HONGKONG));
      case MARKET_TIME_FOREX_HOURS_EUROPE:
        return MathMax(GetCloseHour(MARKET_TIME_FOREX_HOURS_LONDON), GetCloseHour(MARKET_TIME_FOREX_HOURS_FRANKFURT));
      case MARKET_TIME_FOREX_HOURS_PACIFIC:
        return MathMax(GetCloseHour(MARKET_TIME_FOREX_HOURS_SYDNEY), GetCloseHour(MARKET_TIME_FOREX_HOURS_WELLINGTON));
      default:
        return 0;
    }
  }
  // Returns market open hour given a city or a region.
  unsigned short GetOpenHour(ENUM_MARKET_TIME_FOREX_HOURS _enum) {
    // Trading sessions according to GMT (Greenwich Mean Time).
    // Source: http://www.forexmarkethours.com/GMT_hours/02/
    switch (_enum) {
      case MARKET_TIME_FOREX_HOURS_CHICAGO:
        return 14;
      case MARKET_TIME_FOREX_HOURS_FRANKFURT:
        return 7;
      case MARKET_TIME_FOREX_HOURS_HONGKONG:
        return 1;
      case MARKET_TIME_FOREX_HOURS_LONDON:
        return 8;
      case MARKET_TIME_FOREX_HOURS_NEWYORK:
        return 13;
      case MARKET_TIME_FOREX_HOURS_SYDNEY:
        return 22;
      case MARKET_TIME_FOREX_HOURS_TOKYO:
        return 0;
      case MARKET_TIME_FOREX_HOURS_WELLINGTON:
        return 22;
      case MARKET_TIME_FOREX_HOURS_AMERICA:
        return MathMin(GetOpenHour(MARKET_TIME_FOREX_HOURS_NEWYORK), GetOpenHour(MARKET_TIME_FOREX_HOURS_CHICAGO));
      case MARKET_TIME_FOREX_HOURS_ASIA:
        return MathMin(GetOpenHour(MARKET_TIME_FOREX_HOURS_TOKYO), GetOpenHour(MARKET_TIME_FOREX_HOURS_HONGKONG));
      case MARKET_TIME_FOREX_HOURS_EUROPE:
        return MathMin(GetOpenHour(MARKET_TIME_FOREX_HOURS_LONDON), GetOpenHour(MARKET_TIME_FOREX_HOURS_FRANKFURT));
      case MARKET_TIME_FOREX_HOURS_PACIFIC:
        return MathMin(GetOpenHour(MARKET_TIME_FOREX_HOURS_SYDNEY), GetOpenHour(MARKET_TIME_FOREX_HOURS_WELLINGTON));
      default:
        return 0;
    }
  }
};
