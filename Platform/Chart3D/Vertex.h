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
