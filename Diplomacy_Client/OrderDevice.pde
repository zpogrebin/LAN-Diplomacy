class OrderDevice {
  
  UISentence orders;
  String unitName;
  String location;
  int yNum;
  final int start = 150;
  final int h = 90;
  GameClient c;
  
  OrderDevice (int yNum, String uName, String loc, String ord, GameClient c, ColorScheme cs) {
    this.yNum = yNum;
    this.unitName = uName;
    this.location = loc;
    this.c = c;
    PositionSpecifier p = new PositionSpecifier(25, start + (h*yNum) + h-40, 0, 30);
    this.orders = new UISentence(p, "orders", cs, ord);
  }
  
  void draw() {
    stroke(LIGHT);
    fill(LIGHT);
    line(0,start + (h*yNum),width, start + (h*yNum));
    line(0,start + (h*yNum) + h,width, start + (h*yNum) + h);
    noStroke();
    textFont(PLEXSANSBOLD);
    textAlign(LEFT, TOP);
    textSize(20);
    if(location.length() >= 3) text(unitName + " at " + location,25,start + (h*yNum)+10);
    else text("Action Required!",25,start + (h*yNum)+10);
    textFont(PLEXMONO);
    orders.draw();
  }
  
  void drawTop() {
    orders.drawTop();
  }
  
  void update() {
    orders.update();
    if(orders.didChange()) {
      String args[] = new String[] {c.passphrase.getValue(), location.replace(" ", "_") + " " + orders.getValue()};
      c.sendCommand("order", args, true); //<>// //<>// //<>// //<>// //<>// //<>//
    }
  }
  
  PositionSpecifier updateC(PositionSpecifier p) {
    p = orders.updateC(p);
    if(orders.didChange()) {
      String args[] = new String[] {c.passphrase.getValue(), location.replace(" ", "_") + " " + orders.getValue()};
      c.sendCommand("order", args, true);
    }
    return p;
  }
  
  void refreshOrder(String newOrder) {
    orders.setByString(newOrder);
  }
}
