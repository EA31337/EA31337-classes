#include "../Refs.mqh"

/**
 * Generic vertex to be used by meshes.
 */
struct Vertex {
  DXVector3 Position;
  DXVector3 Normal;
  DXVector Color;

  Vertex() {
    Color.x = 1.0f;
    Color.y = 1.0f;
    Color.z = 1.0f;
    Color.w = 1.0f;
  }

  static const ShaderVertexLayout Layout[3];
};

const ShaderVertexLayout Vertex::Layout[3] = {
    {"POSITION", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), 0},
    {"NORMAL", 0, GFX_VAR_TYPE_FLOAT, 3, false, sizeof(Vertex), sizeof(float) * 3},
    {"COLOR", 0, GFX_VAR_TYPE_FLOAT, 4, false, sizeof(Vertex), sizeof(float) * 6}};
