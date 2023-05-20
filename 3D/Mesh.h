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
 * Generic graphics mesh.
 */

#include "../Dict.mqh"
#include "../Refs.mqh"
#include "../Util.h"
#include "Face.h"
#include "IndexBuffer.h"
#include "Material.h"
#include "Math.h"
#include "TSR.h"
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
    key = MakeKey(_point.Position.x, _point.Position.y, _point.Position.z);
  }

  bool operator==(const PointEntry<T>& _r) {
    return key == MakeKey(_r.point.Position.x, _r.point.Position.y, _r.point.Position.z);
  }

  static long MakeKey(float x, float y, float z) {
    return long(x / GFX_MESH_LOOKUP_PRECISION) + 4194304 * long(y / GFX_MESH_LOOKUP_PRECISION) +
           17592186044416 * long(z / GFX_MESH_LOOKUP_PRECISION);
  }
};

// Mesh points type.
enum ENUM_MESH_TYPE { MESH_TYPE_CONNECTED_POINTS, MESH_TYPE_SEPARATE_POINTS };

template <typename T>
class Mesh : public Dynamic {
  Ref<VertexBuffer> vbuff;
  Ref<IndexBuffer> ibuff;
  Ref<Shader> shader_ps;
  Ref<Shader> shader_vs;
  Face<T> faces[];
  TSR tsr;
  ENUM_MESH_TYPE type;
  bool initialized;
  Material material;

 public:
  /**
   * Constructor.
   */
  Mesh(ENUM_MESH_TYPE _type = MESH_TYPE_SEPARATE_POINTS) {
    type = _type;
    initialized = false;
  }

  /**
   * Initializes graphics device-related things.
   */
  virtual void Initialize(Device* _device) {}

  TSR* GetTSR() { return &tsr; }

  void SetTSR(const TSR& _tsr) { tsr = _tsr; }

  /**
   * Adds a single 3 or 4-vertex face.
   */
  void AddFace(Face<T>& face) {
    face.UpdateNormal();
    Util::ArrayPush(faces, face, 16);
  }

  /**
   * Returns material assigned to mesh.
   */
  Material* GetMaterial() { return &material; }

  /**
   * Assigns material to mesh.
   */
  void SetMaterial(Material& _material) { material = _material; }

  /**
   * Returns vertex shader for mesh rendering.
   */
  Shader* GetShaderVS() { return shader_vs.Ptr(); }

  /**
   * Sets pixel shader for mesh rendering.
   */
  void SetShaderVS(Shader* _shader_vs) { shader_vs = _shader_vs; }

  /**
   * Returns pixel shader for mesh rendering.
   */
  Shader* GetShaderPS() { return shader_ps.Ptr(); }

  /**
   * Sets pixel shader for mesh rendering.
   */
  void SetShaderPS(Shader* _shader_ps) { shader_ps = _shader_ps; }

  /**
   * Returns vertex and index buffers for this mesh.
   *
   * @todo Buffers should be invalidated if mesh has changed.
   */
  bool GetBuffers(Device* _device, VertexBuffer*& _vbuff, IndexBuffer*& _ibuff) {
    if (!initialized) {
      Initialize(_device);
      initialized = true;
    }

#ifdef __debug__
    Print("Getting buffers. Mesh type = ", EnumToString(type));
#endif
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
        PointEntry<T> _point1(_face.points[k]);
        _face_indices[k] = type == MESH_TYPE_SEPARATE_POINTS ? -1 : _points.IndexOf(_point1);

        if (_face_indices[k] == -1) {
          // Point not yet added.
          _points.Push(_point1);
          _face_indices[k] = (int)_points.Size() - 1;
        }

        Util::ArrayPush(_indices, _face_indices[k]);
      }

      // Adding second triangle if needed.
      if ((_face.flags & FACE_FLAGS_QUAD) == FACE_FLAGS_QUAD) {
        if (type == MESH_TYPE_CONNECTED_POINTS) {
          PointEntry<T> _point3(_face.points[3]);
          _face_indices[3] = _points.IndexOf(_point3);

          if (_face_indices[3] == -1) {
            // Point not yet added.
            _points.Push(_point3);
            _face_indices[3] = (int)_points.Size() - 1;
          }

          Util::ArrayPush(_indices, _face_indices[0]);
          Util::ArrayPush(_indices, _face_indices[2]);
          Util::ArrayPush(_indices, _face_indices[3]);
        } else {
          int _i1 = ArraySize(_indices) + 0;
          int _i2 = ArraySize(_indices) + 1;
          int _i3 = ArraySize(_indices) + 2;

          Util::ArrayPush(_indices, _i1);
          Util::ArrayPush(_indices, _i2);
          Util::ArrayPush(_indices, _i3);

          PointEntry<T> _point0(_face.points[0]);
          PointEntry<T> _point2(_face.points[2]);
          PointEntry<T> _point3(_face.points[3]);

          _points.Push(_point0);
          _points.Push(_point2);
          _points.Push(_point3);
        }
      }
    }

    ArrayResize(_vertices, _points.Size());

    for (DictIteratorBase<int, PointEntry<T>> iter(_points.Begin()); iter.IsValid(); ++iter) {
      _vertices[iter.Index()] = iter.Value().point;
    }

    string _s_vertices = "[";

    for (i = 0; i < ArraySize(_vertices); ++i) {
      _s_vertices += "[";
      _s_vertices += "  Pos = " + DoubleToString(_vertices[i].Position.x) + ", " +
                     DoubleToString(_vertices[i].Position.y) + "," + DoubleToString(_vertices[i].Position.z) + " | ";
      _s_vertices += "  Clr = " + DoubleToString(_vertices[i].Color.r) + ", " + DoubleToString(_vertices[i].Color.g) +
                     "," + DoubleToString(_vertices[i].Color.b) + "," + DoubleToString(_vertices[i].Color.a);
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

#ifdef __debug__
    Print("Vertices: ", _s_vertices);
    Print("Indices: ", _s_indices);
#endif

    vbuff = _vbuff = _device.VertexBuffer<T>(_vertices);
    ibuff = _ibuff = _device.IndexBuffer(_indices);
    return true;
  }
};
