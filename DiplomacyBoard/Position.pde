//    __             ___  _      __                        
//   / /  ___ ____  / _ \(_)__  / /__  __ _  ___ _______ __
//  / /__/ _ `/ _ \/ // / / _ \/ / _ \/  ' \/ _ `/ __/ // /
// /____/\_,_/_//_/____/_/ .__/_/\___/_/_/_/\_,_/\__/\_, / 
//                      /_/                         /___/  
// Lan Diplomacy Development File
// Sep 13, 2021

import java.util.Arrays;

class PositionSpecifier {
  public float x, y, w, h;
  protected float[] feather;
  
  PositionSpecifier(float ix, float iy, float iw, float ih) {
    x = ix;
    y = iy;
    w = iw;
    h = ih;
  }
  
  PositionSpecifier(PositionSpecifier ps) {
    x = ps.x;
    y = ps.y;
    w = ps.w;
    h = ps.h;
    feather = ps.feather;
  }
  
  PositionSpecifier(float ix, float iy, float iw, float ih, float[] ifeather) {
    this(ix, iy ,iw ,ih);
    setFeather(ifeather);
  }
  
  PositionSpecifier(float ix, float iy, float iw, float ih, float ifeather) {
    this(ix, iy ,iw ,ih);
    setFeather(ifeather);
  }
  
  PositionSpecifier(float ix, float iy, float iw, float ih, float f1, float f2, float f3, float f4) {
    this(ix, iy ,iw ,ih);
    setFeather(new float[]{f1, f2, f3, f4});
  }
  
  float[] center() {
    return new float[]{x + w/2, y + h/2};
  }
  
  void setFeather(float[] nf) {
    feather = Arrays.copyOf(nf, 4);
  }
  
  void setFeather(float nf) {
    feather = new float[]{nf, nf, nf, nf};
  }
  
  float[] getFeather() {
    return Arrays.copyOf(feather, 4);
  }
    
  String getStr() {
    return "(" + x + ", " + y + "), " + w + "x" + h;
  }
  
  boolean mouseOver() {
    boolean check;
    check = mouseX > x && mouseX < x + w;
    check &= mouseY > y && mouseY < y + h;
    return check;
  }
  
  void makeRect(color fill) {
    makeRect(fill, -1);
  }
  
  void makeRect(color fill, color stroke) {
    fill(fill);
    strokeWeight(2);
    if(stroke == -1) noStroke();
    else stroke(stroke);
    if(feather == null) rect(x, y, w, h);
    else if(feather.length < 4) rect(x, y, w, h, feather[0]);
    else rect(x, y, w, h, feather[0], feather[1], feather[2], feather[3]);
  }
  
  void set_coords(float nx, float ny, float nw, float nh) {
    x = nx;
    y = ny;
    w = nw;
    h = nh;
  }
  
  void set_coords(float nx, float ny) {
    x = nx;
    y = ny;
  }
}
