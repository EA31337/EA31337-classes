//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * Chart events.
 */

#include "../Util.h"

enum ENUM_INTERFACE_EVENT {
  INTERFACE_EVENT_NONE,
  INTERFACE_EVENT_MOUSE_MOVE,
  INTERFACE_EVENT_MOUSE_DOWN,
  INTERFACE_EVENT_MOUSE_UP
};

struct InterfaceEvent {
  ENUM_INTERFACE_EVENT type;
  struct EventMouse {
    int x;
    int y;
    datetime dt;
  };

  union EventData {
    EventMouse mouse;
  } data;
};

#ifdef __MQL5__
/**
 * "OnChart" event handler function (MQL5 only).
 *
 * Invoked when the ChartEvent event occurs.
 */
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
  datetime _dt;
  double _mp;
  int _window = 0;
  InterfaceEvent _event;

  if (id == CHART_EVENT_MOUSE_MOVE) {
    Interface::mouse_pos_x = (int)lparam;
    Interface::mouse_pos_y = (int)dparam;
    ChartXYToTimePrice(0, Interface::mouse_pos_x, Interface::mouse_pos_y, _window, _dt, _mp);
    _event.type = INTERFACE_EVENT_MOUSE_MOVE;
    _event.data.mouse.x = Interface::mouse_pos_x;
    _event.data.mouse.y = Interface::mouse_pos_y;
    Interface::FireEvent(_event);
  }
}
#endif

typedef void (*InterfaceListener)(InterfaceEvent&, void*);

class Interface {
 public:
  struct Installation {
    InterfaceListener listener;
    void* target;
  };

  static Installation installations[];

  static bool mouse_was_down;
  static int mouse_pos_x;
  static int mouse_pos_y;
  static bool initialized;

#ifdef __MQL5__
  static void AddListener(InterfaceListener _listener, void* _target) {
    if (!initialized) {
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
      ChartRedraw();
      initialized = true;
    }

    for (int i = 0; i < ArraySize(installations); ++i) {
      if (installations[i].listener == _listener) {
        // Listener already added.
        return;
      }
    }

    Installation _installation;
    _installation.listener = _listener;
    _installation.target = _target;

    Util::ArrayPush(installations, _installation);
  }

  static void FireEvent(InterfaceEvent& _event) {
    for (int i = 0; i < ArraySize(installations); ++i) {
      Installation _installation = installations[i];
      _installation.listener(_event, _installation.target);
    }
  }

  static int GetMouseX() { return mouse_pos_x; }

  static int GetMouseY() { return mouse_pos_y; }
#endif
};

#ifdef __MQL5__
Interface::Installation Interface::installations[];
bool Interface::mouse_was_down = false;
int Interface::mouse_pos_x = 0;
int Interface::mouse_pos_y = 0;
bool Interface::initialized = false;
#endif
