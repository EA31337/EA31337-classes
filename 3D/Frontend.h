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
 * Generic graphics front-end (display buffer target).
 */

#include "../Refs.mqh"

/**
 * Represents visual target (OS window/canvas for rendering).
 */
class Frontend : public Dynamic {
 public:
  /**
   * Initializes canvas.
   */
  bool Start() { return Init(); }

  /**
   * Deinitializes canvas.
   */
  bool End() { return Deinit(); }

  /**
   * Initializes canvas.
   */
  virtual bool Init() = NULL;

  /**
   * Deinitializes canvas.
   */
  virtual bool Deinit() = NULL;

  /**
   * Executed before render starts.
   */
  virtual void RenderBegin(int context) = NULL;

  /**
   * Executed after render ends.
   */
  virtual void RenderEnd(int context) = NULL;

  /**
   * Returns canvas' width.
   */
  virtual int Width() = NULL;

  /**
   * Returns canvas' height.
   */
  virtual int Height() = NULL;
};