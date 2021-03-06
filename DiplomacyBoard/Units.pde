//    __             ___  _      __                        
//   / /  ___ ____  / _ \(_)__  / /__  __ _  ___ _______ __
//  / /__/ _ `/ _ \/ // / / _ \/ / _ \/  ' \/ _ `/ __/ // /
// /____/\_,_/_//_/____/_/ .__/_/\___/_/_/_/\_,_/\__/\_, / 
//                      /_/                         /___/  
// Lan Diplomacy Development File
// Sep 13, 2021

class Unit {
  int num;
  String type;
  Player owner;
  Region location;
  boolean dislodged;
  Order lastOrder;
  Order currOrder;
  
  Unit(Player owner, int num, String type) {
    this.num = num;
    this.owner = owner;
    this.type = type;
    dislodged = false;
  }
  
  void incrementStrength() {
    currOrder.strength++;
  }
  
  void resetOrders(Phases phase) {
    lastOrder = currOrder;
    if(phase == Phases.MOVEPHASE) {
      currOrder = new Hold(this);
    } else if(phase == Phases.RETREAT) {
      if(dislodged) currOrder = new Disband(this);
    } else {
      currOrder = new Order(this);
    }
  }
  
  PShape render() {
    if(dislodged || location == null) return new PShape();
    float w, h;
    PShape overall = new PShape();
    if(isFleet()) overall.addChild(owner.fleetShape);
    else overall.addChild(owner.armyShape);
    float[] offset = location.getPos(this);
    w = overall.getChild(0).width;
    h = overall.getChild(0).height;
    overall.translate(offset[0]-w/2,offset[1]-h/2);
    return overall;
  }
  
  boolean isFleet() {
    return type == "Fleet";
  }
  
  boolean isArmy() {
    return !isFleet();
  }
  
  String getInfo() {
    return owner.getName() + "'s " + getName();
  }
  
  String getName() {
    return ordWithNum(num) + " " + type;
  }
  
  void dislodge() {
    dislodged = true;
    location.setOccupier(null);
    location.setDislodged(this);
  }
  
  void hardMove(Region to) {
    if(location != null && !dislodged) location.setOccupier(null);
    else if(location != null) location.setDislodged(null);
    if(!to.isEmpty()) to.getOccupier().dislodge();
    location = to;
    to.setOccupier(this);
  }
}

class Army extends Unit {
  Army(Player owner, int num) {
    super(owner, num, "Army");
  }
}

class Fleet extends Unit {
  Fleet(Player owner, int num) {
    super(owner, num, "Fleet");
  }
}
