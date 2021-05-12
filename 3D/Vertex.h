#include "../Refs.mqh"

/**
 * Generic vertex to be used by meshes.
 */
struct Vertex {
  DXVector3 Position;
  DXVector3 Normal;
  DXColor Color;

  Vertex() {
    Color.r = 1.0f;
    Color.g = 1.0f;
    Color.b = 1.0f;
    Color.a = 1.0f;
  }

  static const ShaderVertexLayout Layout[3];
};

const ShaderVertexLayout Vertex::Layout[3] = {
    {"POSITION", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), 0},
    {"NORMAL", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), sizeof(float) * 3},
    {"COLOR", 0, GFX_VAR_TYPE_FLOAT, 4, false, sizeof(Vertex), sizeof(float) * 6}};
