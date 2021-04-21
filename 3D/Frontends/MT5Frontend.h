#include "../Frontend.h"

/**
 * MetaTrader 5 chart target.
 */
class MT5Frontend : public Frontend {
  unsigned int image[];
  int last_width, last_height;
  string resname;
  string objname;
  
public:
  
  virtual bool Init() {
    // Hiding 2D chart.
    ChartSetInteger(0, CHART_SHOW, false);
    ChartRedraw();
    
    Print("LastError: ", GetLastError());
    
    objname = "MT5_Frontend_" + IntegerToString(ChartID());
    resname = "::MT5_Frontend" + IntegerToString(ChartID());    
    ObjectCreate(0, objname, OBJ_BITMAP_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objname, OBJPROP_XDISTANCE, 0);
    ObjectSetInteger(0, objname, OBJPROP_YDISTANCE, 0);
    Print("LastError: ", GetLastError());
        
    Print("LastError: ", GetLastError());
    Print("ResourceCreate: width = ", Width(), ", height = ", Height());
    ObjectSetString(ChartID(), objname, OBJPROP_BMPFILE, resname);
    Print("LastError: ", GetLastError());
    return true;
  }

  virtual bool Deinit() {
    ResourceFree(resname);
    ObjectDelete(0, objname);
    ChartSetInteger(0, CHART_SHOW, true);
    return true;
  }
  
  bool Resize() {
    if (Width() == last_width && Height() == last_height) {
      return false;
    }
    
    ArrayResize(image, Width() * Height());
    Print("resname = ", resname, ", image_size = ", ArraySize(image), ", width = ", Width(), ", height = ", Height());
    ResourceCreate(resname, image, Width(), Height(), 0, 0, Width(), COLOR_FORMAT_XRGB_NOALPHA);  
    Print("ResourceCreate: LastError: ", GetLastError());
    
    last_width = Width();
    last_height = Height();    
    
    return true;
  }
  
  virtual void RenderBegin(int context) {
    Print("MT5Frontend: RenderBegin()");
    Print("Image resize: width = ", Width(), ", height = ", Height());

    if (Resize()) {
      DXContextSetSize(context, Width(), Height());
    }    
   
    Print("DXContextSetSize: LastError: ", GetLastError());
  }
  
  virtual void RenderEnd(int context) {
    Print("MT5Frontend: RenderEnd()");
    Print("ResourceCreate: width = ", Width(), ", height = ", Height());
    Print("MT5Frontend: DXContextGetColors()");
    DXContextGetColors(context, image);
    Print("DXContextGetColors: LastError: ", GetLastError());
    ResourceCreate(resname, image, Width(), Height(), 0, 0, Width(), COLOR_FORMAT_XRGB_NOALPHA);
    Print("ResourceCreate: LastError: ", GetLastError());
    ChartRedraw();
    Sleep(50);
  }
  
  virtual void Refresh(int context) {
  }

  virtual int Width() { return (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS); }

  virtual int Height() { return (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS); }
};