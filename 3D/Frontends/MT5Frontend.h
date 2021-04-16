#include "../Frontend.h"

/**
 * MetaTrader 5 chart target.
 */
class MT5Frontend : public Frontend {
  virtual bool Init() {
    // Hiding 2D chart.
    ChartSetInteger(0, CHART_SHOW, false);
    ChartRedraw();
    return true;
  }

  virtual bool Deinit() { return true; }

  virtual int Width() { return (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS); }

  virtual int Height() { return (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS); }
};