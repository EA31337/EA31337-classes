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
   * Returns canvas' width.
   */
  virtual int Width() = NULL;

  /**
   * Returns canvas' height.
   */
  virtual int Height() = NULL;
};