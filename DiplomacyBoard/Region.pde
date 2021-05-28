class Region {
  boolean supplyCenter;
  String name;
  String abrName;
  ArrayList<Region> landBorders;
  ArrayList<Region> seaBorders;
  protected Unit occupiedUnit;
  Player owner;
  boolean canBeOwned;
  protected boolean canDraw;
  PShape shape;
  float landPos[]; 
  float seaPos[];
  Region parent;
  
  Region(String name, String abrName, boolean supplyCenter) {
    this.name = name.replace('_', ' ');
    this.abrName = abrName;
    this.supplyCenter = supplyCenter;
    this.owner = null;
    landBorders = new ArrayList<Region>();
    seaBorders = new ArrayList<Region>();
    canDraw = false;
    landPos = new float[]{0,0};
    seaPos = new float[]{0,0};
  }
  
  PShape render() {
    PShape overall = createShape(GROUP);
    shapeMode(CORNER);
    if(owner != null) changeShapeFill(shape, owner.getColor());
    if(canDraw) overall.addChild(shape);
    else overall.setFill(NEUTRAL_COLOR);
    return overall;
  }
  
  void setPos(int lx, int ly, int sx, int sy) {
    landPos = new float[]{lx,ly};
    seaPos = new float[]{sx,sy};
  }
  
  void setPos(int x, int y) {
    setPos(x,y,x,y);
  }
  
  void attachShape(PShape shape) {
    if(shape == null) {
      if(canBeOwned)println(abrName + " Failed");
      return;
    }
    canDraw = true;
    this.shape = shape;
  }
  
  void setOccupier(Unit newUnit) {
    this.occupiedUnit = newUnit;
    
  }
  
  float[] getPos(Unit u) {
    if(u.isFleet()) return seaPos;
    else return landPos;
  }
  
  float[] getPos() {
    if(isEmpty()) return landPos;
    else if(occupiedUnit.isFleet()) return seaPos;
    else return landPos;
  }

  void autoSetAbrName() {
    this.abrName = name.substring(0,3);
  }

  void setOwner(Player newOwner) {
    if(canBeOwned) owner = newOwner;
  }

  void advanceOwnership() {
    if(this.occupiedUnit == null) return;
    if(!canBeOwned) return;
    Region subject;
    if(parent != null) subject = parent;
    else subject = this;
    if(supplyCenter) {
      if(subject.owner != null) subject.owner.incrementCenters(false);
      subject.getOccupier().owner.incrementCenters(true);
    }
    subject.setOwner(subject.getOccupier().owner);
  }
  
  boolean equals(Region other) {
    if(this == other | this.parent == other) return true;
    return false;
  }
  
  String getInfo() {
    String info = "";
    if(supplyCenter) info += "***";
    else info += "   ";
    info += " " + abrName + ":\t" + name;
    if(owner != null) info += "\n\t> Under " + owner.getName();
    if(occupiedUnit != null) info += "\n\t> Held by " + occupiedUnit.getInfo();
    return info;
  }
  
  void connect(Region adjacent, boolean land, boolean sea) {
    if(adjacent == this) return;
    if(land && !landBorders.contains(adjacent)) this.landBorders.add(adjacent);
    if(sea && !seaBorders.contains(adjacent)) this.seaBorders.add(adjacent);
  }
  
  void changeShapeFill(PShape shape, color newColor) {
    for(int i = 0; i < shape.getChildCount(); i++) {
      changeShapeFill(shape.getChild(i), newColor);
    }
    shape.setFill(newColor);
  }
  
  boolean isEmpty() {
    if(parent != null) return parent.isEmpty();
    return occupiedUnit == null;
  }
  
  Unit getOccupier() {
    if(parent != null) return parent.getOccupier();
    return occupiedUnit;
  }
  
  boolean landLocked() {return seaBorders.size() == 0;}
}

class Sea extends Region {
  
  Sea(String name, String abrName) {
    super(name, abrName, false);
    canBeOwned = false;
    owner = null;
    canDraw = false;
  }
  
  void draw() {
    return;
  }
  
  void connect(Region adjacent) {
    if(adjacent == this) return;
    if(!seaBorders.contains(adjacent)) seaBorders.add(adjacent);
  }
  
  float[] getPos() {
    return seaPos;
  }
  
  float[] getPos(Unit u) {return getPos();}
  
  void connect(Region adjacent, boolean land, boolean sea) {connect(adjacent);}
}

class Land extends Region {
  
  Land(String name, String abrName, boolean supplyCenter) {
    super(name, abrName, supplyCenter);
    canBeOwned = true;
  }
  
}

class Coastal extends Region {
  
  Land northCoast;
  Land southCoast;
  
  Coastal(String name, String abrName, boolean supplyCenter) {
    super(name, abrName, supplyCenter);
    northCoast = new Land(name + " (North Coast)", abrName + "_nc", false);
    southCoast = new Land(name + " (South Coast)", abrName + "_sc", false);
    northCoast.parent = this;
    southCoast.parent = this;
    canBeOwned = true;
  }
  
  boolean landLocked() {return false;}
  
  void coastalConnect(Region adjacent, boolean land, boolean north, boolean south) {
    if(this == adjacent) return;
    if(land) connect(adjacent, true, false);
    if(north) this.northCoast.connect(adjacent, false, true);
    if(south) this.southCoast.connect(adjacent, false, true);
  }
  
  void setCoastalPos(int lx, int ly, int nx, int ny, int sx, int sy) {
    southCoast.setPos(sx, sy);
    northCoast.setPos(nx, ny);
    setPos(lx,ly);
  }
  
  boolean isEmpty() {
    boolean res = occupiedUnit==null;
    res = res && northCoast.occupiedUnit==null;
    res = res && southCoast.occupiedUnit == null;
    return res;
  }
  
  Unit getOccupier() {
    if(occupiedUnit != null) return occupiedUnit;
    else if(northCoast.occupiedUnit != null) return northCoast.occupiedUnit;
    else return southCoast.occupiedUnit;
  }
  
  void advanceOwnership() {
    if(isEmpty()) return;
    if(supplyCenter) {
      if(owner != null) owner.incrementCenters(false);
      getOccupier().owner.incrementCenters(true);
    }
    setOwner(getOccupier().owner);
  }
  
  void setOccupier(Unit newUnit) {
    if(newUnit == null) {
      northCoast.occupiedUnit=null;
      southCoast.occupiedUnit=null;
      this.occupiedUnit=null;
    } else this.occupiedUnit = newUnit;
  }
}
