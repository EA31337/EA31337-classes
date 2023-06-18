#include "Math.h"

/**
 * Generic vertex to be used by meshes.
 */
class Material {
 public:
  DXColor Color;

  Material(unsigned int _color = 0xFFFFFFFF) { Color = DXColor(_color); }

  Material(const Material& _r) { Color = _r.Color; }

  Material* SetColor(unsigned int _color) {
    Color = DXColor(_color);
    return &this;
  }
};
