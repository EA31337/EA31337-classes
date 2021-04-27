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
 * Generic graphics mesh.
 */

#include "../Dict.mqh"
#include "../Refs.mqh"
#include "../Util.h"
#include "Face.h"
#include "IndexBuffer.h"
#include "Math.h"
#include "VertexBuffer.h"

class Device;

#define GFX_MESH_LOOKUP_PRECISION 0.001f

// Point with a key for faster vertices' lookup by their position.
template <typename T>
struct PointEntry {
  T point;
  long key;

  PointEntry() {}

  PointEntry(const T& _point) {
    point = _point;
    key = MakeKey(_point.Position[0], _point.Position[1], _point.Position[2]);
  }

  bool operator==(const PointEntry<T>& _r) {
    return key == MakeKey(_r.point.Position[0], _r.point.Position[1], _r.point.Position[2]);
  }

  static long MakeKey(float x, float y, float z) {
    return long(x / GFX_MESH_LOOKUP_PRECISION) + 4194304 * long(y / GFX_MESH_LOOKUP_PRECISION) +
           17592186044416 * long(z / GFX_MESH_LOOKUP_PRECISION);
  }
};

template <typename T>
class Mesh : public Dynamic {
  Ref<VertexBuffer> vbuff;
  Ref<IndexBuffer> ibuff;
  Face<T> faces[];

 public:
  /**
   * Constructor.
   */
  Mesh() {}

  /**
   * Adds a single 3 or 4-vertex face.
   */
  void AddFace(Face<T>& face) { Util::ArrayPush(faces, face, 16); }

  /**
   * Returns vertex and index buffers for this mesh.
   *
   * @todo Buffers should be invalidated if mesh has changed.
   */
  bool GetBuffers(Device* _device, VertexBuffer*& _vbuff, IndexBuffer*& _ibuff) {
    if (vbuff.IsSet() && ibuff.IsSet()) {
      _vbuff = vbuff.Ptr();
      _ibuff = ibuff.Ptr();
      return true;
    }

    DictStruct<int, PointEntry<T>> _points;
    T _vertices[];
    unsigned int _indices[];
    int i, k;

    for (i = 0; i < ArraySize(faces); ++i) {
      Face<T> _face = faces[i];
      int _face_indices[4];

      // Adding first triangle.
      for (k = 0; k < 3; ++k) {
        PointEntry<T> point1(_face.points[k]);
        _face_indices[k] = _points.IndexOf(point1);

        if (_face_indices[k] == -1) {
          // Point not yet added.
          _points.Push(point1);
          _face_indices[k] = (int)_points.Size() - 1;
        }

        Util::ArrayPush(_indices, _face_indices[k]);
      }

      // Adding second triangle if needed.
      if ((_face.flags & FACE_FLAGS_QUAD) == FACE_FLAGS_QUAD) {
        PointEntry<T> point2(_face.points[3]);
        _face_indices[3] = _points.IndexOf(point2);

        if (_face_indices[3] == -1) {
          // Point not yet added.
          _points.Push(point2);
          _face_indices[3] = (int)_points.Size() - 1;
        }

        Util::ArrayPush(_indices, _face_indices[0]);
        Util::ArrayPush(_indices, _face_indices[2]);
        Util::ArrayPush(_indices, _face_indices[3]);
      }
    }

    ArrayResize(_vertices, _points.Size());

    for (DictIteratorBase<int, PointEntry<T>> iter(_points.Begin()); iter.IsValid(); ++iter) {
      _vertices[iter.Index()] = iter.Value().point;
    }

    string _s_vertices = "[";

    for (i = 0; i < ArraySize(_vertices); ++i) {
      _s_vertices += "[";
      _s_vertices += "  Pos = " + DoubleToString(_vertices[i].Position[0]) + ", " +
                     DoubleToString(_vertices[i].Position[1]) + "," + DoubleToString(_vertices[i].Position[2]) + " | ";
      _s_vertices += "  Clr = " + DoubleToString(_vertices[i].Color[0]) + ", " + DoubleToString(_vertices[i].Color[1]) +
                     "," + DoubleToString(_vertices[i].Color[2]) + "," + DoubleToString(_vertices[i].Color[3]);
      _s_vertices += "]";
      if (i != ArraySize(_vertices) - 1) {
        _s_vertices += ", ";
      }
    }

    _s_vertices += "]";

    string _s_indices = "[";

    for (i = 0; i < ArraySize(_indices); ++i) {
      _s_indices += DoubleToString(_indices[i]);
      if (i != ArraySize(_indices) - 1) {
        _s_indices += ", ";
      }
    }

    _s_indices += "]";

    Print("Vertices: ", _s_vertices);
    Print("Indices: ", _s_indices);

    vbuff = _vbuff = _device.VertexBuffer<T>(_vertices);
    ibuff = _ibuff = _device.IndexBuffer(_indices);
    return true;
  }
};