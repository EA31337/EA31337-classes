#include "../Refs.mqh"

struct Vertex {
  struct Position {
    float x, y, z;
  } position;

  struct Color {
    float r, g, b, a;
  } color;
};