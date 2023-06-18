//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

#include "../../Refs.mqh"

/**
 * Generic vertex to be used by meshes.
 */
struct Vertex {
  DXVector3 Position;
  DXVector3 Normal;
  DXColor Color;

  // Default constructor.
  Vertex(float r = 1, float g = 1, float b = 1, float a = 1) {
    Color.r = r;
    Color.g = g;
    Color.b = b;
    Color.a = a;
  }

  Vertex(const Vertex &r) {
    Position = r.Position;
    Normal = r.Normal;
    Color = r.Color;
  }

  static const ShaderVertexLayout Layout[3];
};

const ShaderVertexLayout Vertex::Layout[3] = {
    {"POSITION", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), 0},
    {"NORMAL", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), sizeof(float) * 3},
    {"COLOR", 0, GFX_VAR_TYPE_FLOAT, 4, false, sizeof(Vertex), sizeof(float) * 6}};
