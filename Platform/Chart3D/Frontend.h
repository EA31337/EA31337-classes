//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
  // Allows the preprocessor to include a header file when it is needed.
  #pragma once
#endif

#include "../../Refs.mqh"

struct DrawTextQueueItem {
  float x;
  float y;
  string text;
  unsigned int rgb;
  unsigned int align;
};

/**
 * Represents visual target (OS window/canvas for rendering).
 */
class Frontend : public Dynamic {
 protected:
  ARRAY(DrawTextQueueItem, draw_text_queue);

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
  virtual bool Init() = 0;

  /**
   * Deinitializes canvas.
   */
  virtual bool Deinit() = 0;

  /**
   * Executed before render starts.
   */
  virtual void RenderBegin(int context) = 0;

  /**
   * Executed after render ends.
   */
  virtual void RenderEnd(int context) = 0;

  /**
   * Returns canvas' width.
   */
  virtual int Width() = 0;

  /**
   * Returns canvas' height.
   */
  virtual int Height() = 0;

  /**
   * Enqueues text to be drawn directly into the pixel buffer. Queue will be processed in the Device::End() method.
   */
  virtual void DrawText(float _x, float _y, string _text, unsigned int _color = 0xFFFFFFFF, unsigned int _align = 0) {
    DrawTextQueueItem _item;
    _item.x = _x;
    _item.y = _y;
    _item.text = _text;
    _item.rgb = _color;
    _item.align = _align;
    Util::ArrayPush(draw_text_queue, _item);
  }

  void ProcessDrawText() {
    for (int i = 0; i < ArraySize(draw_text_queue); ++i) {
      DrawTextQueueItem _item = draw_text_queue[i];
      DrawTextNow((int)_item.x, (int)_item.y, _item.text, _item.rgb, _item.align);
    }
    ArrayResize(draw_text_queue, 0);
  }

 protected:
  /**
   * Draws text directly into the pixel buffer. Should be executed after all 3d drawing.
   */
  virtual void DrawTextNow(int _x, int _y, string _text, unsigned int _color = 0xFFFFFFFF, unsigned int _align = 0) {}
};
