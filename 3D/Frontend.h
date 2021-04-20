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
   * Executed before render starts.
   */
  virtual void RenderBegin(int context) = NULL;
  
  /**
   * Executed after render ends.
   */
  virtual void RenderEnd(int context) = NULL;
  
  virtual void Refresh(int context) {};

  /**
   * Returns canvas' width.
   */
  virtual int Width() = NULL;

  /**
   * Returns canvas' height.
   */
  virtual int Height() = NULL;
};