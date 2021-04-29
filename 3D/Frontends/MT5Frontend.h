//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
 * MT5 graphics front-end (display buffer target).
 */

#include "../Frontend.h"

/**
 * MetaTrader 5 chart target.
 */
class MT5Frontend : public Frontend {
  // Target image pixel buffer.
  unsigned int image[];

  // Previous size of the window.
  int last_width, last_height;

  // Target image's resource name.
  string resname;

  // Target image's object name.
  string objname;

 public:
  /**
   * Initializes canvas.
   */
  virtual bool Init() {
    // Hiding 2D chart.
    ChartSetInteger(0, CHART_SHOW, false);
    ChartRedraw();

    Print("LastError: ", GetLastError());

    objname = "MT5_Frontend_" + IntegerToString(ChartID());
    resname = "::MT5_Frontend" + IntegerToString(ChartID());
    ObjectCreate(0, objname, OBJ_BITMAP_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objname, OBJPROP_XDISTANCE, 0);
    ObjectSetInteger(0, objname, OBJPROP_YDISTANCE, 0);
    Print("LastError: ", GetLastError());

    Print("LastError: ", GetLastError());
    Print("ResourceCreate: width = ", Width(), ", height = ", Height());
    ObjectSetString(ChartID(), objname, OBJPROP_BMPFILE, resname);
    Print("LastError: ", GetLastError());
    return true;
  }

  /**
   * Deinitializes canvas.
   */
  virtual bool Deinit() {
    ResourceFree(resname);
    ObjectDelete(0, objname);
    ChartSetInteger(0, CHART_SHOW, true);
    ChartRedraw();
    return true;
  }

  /**
   * Resizes target image buffer if needed.
   */
  bool Resize() {
    if (Width() == last_width && Height() == last_height) {
      return false;
    }

    ArrayResize(image, Width() * Height());
    Print("resname = ", resname, ", image_size = ", ArraySize(image), ", width = ", Width(), ", height = ", Height());
    ResourceCreate(resname, image, Width(), Height(), 0, 0, Width(), COLOR_FORMAT_ARGB_NORMALIZE);
    Print("ResourceCreate: LastError: ", GetLastError());

    last_width = Width();
    last_height = Height();

    return true;
  }

  /**
   * Executed before render starts.
   */
  virtual void RenderBegin(int context) {
    Print("MT5Frontend: RenderBegin()");
    Print("Image resize: width = ", Width(), ", height = ", Height());

    if (Resize()) {
      DXContextSetSize(context, Width(), Height());
    }

    Print("DXContextSetSize: LastError: ", GetLastError());
  }

  /**
   * Executed after render ends.
   */
  virtual void RenderEnd(int context) {
    Print("MT5Frontend: RenderEnd()");
    Print("ResourceCreate: width = ", Width(), ", height = ", Height());
    Print("MT5Frontend: DXContextGetColors()");
    DXContextGetColors(context, image);
    Print("DXContextGetColors: LastError: ", GetLastError());
    ResourceCreate(resname, image, Width(), Height(), 0, 0, Width(), COLOR_FORMAT_ARGB_NORMALIZE);
    Print("ResourceCreate: LastError: ", GetLastError());
    ChartRedraw();
    Sleep(5);
  }

  /**
   * Returns canvas' width.
   */
  virtual int Width() { return (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS); }

  /**
   * Returns canvas' height.
   */
  virtual int Height() { return (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS); }
};