color NEUTRAL_COLOR = color(153, 153, 153);

class Player {
  
  ArrayList<Region> homeCenters;
  String name;
  String abrName;
  int numCenters;
  ArrayList<Unit> armies;
  ArrayList<Unit> fleets;
  color col;
  PShape armyShape;
  PShape fleetShape;
  Board theater;
  ArrayList<Order> builds;
  String passphrase = "";
  
  Player(String name, String abrName, Board theater) {
    this(name, abrName, theater, #333333);
  }
  
  Player(String name, String abrName, Board theater, color col) {
    this.name = name;
    this.abrName = abrName;
    numCenters = 0;
    armies = new ArrayList<Unit>();
    fleets = new ArrayList<Unit>();
    homeCenters = new ArrayList<Region>();
    this.col = col;
    this.theater = theater;
  }
  
  void initShapes(String filename) {
    armyShape = loadShape(dataPath("variants/" + filename + "/Army.svg"));
    armyShape.getChild("Other").getChild(0).setFill(col);
    fleetShape = loadShape(dataPath("variants/" + filename + "/Fleet.svg"));
    fleetShape.getChild("Other").getChild(0).setFill(col);
  }
  
  color getColor() {return col;} 
  int getArmies() {return armies.size() + fleets.size();}
  String getName() {return name;}
  int getNumCenters() {return numCenters;}
  
  void incrementCenters(boolean plus) {
    if(plus) numCenters++;
    else numCenters--;
  }
  
  PShape render() {
    PShape overall = new PShape();
    for(Unit u: armies) overall.addChild(u.render());
    for(Unit u: fleets) overall.addChild(u.render());
    return overall;
  }
  
  boolean isHomeCenter(Region center) {
    return center.supplyCenter && homeCenters.contains(center);
  }
  
  void createUnit(Region at, boolean fleet, int num) {
    if(at.canBeOwned && at.isEmpty() && isHomeCenter(at)) {
      placeUnit(at, fleet, num);
    }
  }
  
  void placeUnit(Region at, boolean fleet, int num) {
    if(fleet) createFleet(at, num);
    else createArmy(at, num);
  }
  
  void createArmy(Region at, int num) {
    Army newArmy;
    if(num == -1) newArmy = new Army(this, getLowestNum(armies));
    else newArmy = new Army(this, num);
    armies.add(newArmy);
    newArmy.hardMove(at); //TODO hardMove
  }
  
  void createFleet(Region at, int num) {
    Fleet newFleet;
    if(num == -1) newFleet = new Fleet(this, getLowestNum(fleets));
    else newFleet = new Fleet(this, num);
    fleets.add(newFleet);
    newFleet.hardMove(at);
  }
  
  private int getLowestNum(ArrayList<Unit> units) {
    int num = 1;
    int oldNum = 0;
    do {
      oldNum++;
      for(Unit unit : units) {
        if(unit.num == num) {
          oldNum = num;
          num++;
          break;
        }
      }
    } while(num != oldNum);
    return num;
  }
  
  void disbandUnit(Unit unit) {
    unit.location.setOccupier(null);
    if(unit.isFleet()) fleets.remove(unit);
    else armies.remove(unit);
  }
  
  //Handle Order Parsing
  String orderHandler(String partialOrder) {
    String[] args = partialOrder.split("\\s+");
    Region location = stringToRegion(args[0]);
    if(location == null) return "Error: Invalid location " + args[0];
    Unit u;
    if(theater.phase == Phases.MOVEPHASE) u = location.getOccupier();
    else u = location.getDislodged();
    if(u == null || u.owner != this) return "Error: No available units here!";
    if(u.currOrder.convert(args[1]) != null) {
       u.currOrder = u.currOrder.convert(args[1]);
       args = new String[]{"",""};
    }
    String response = u.currOrder.orderHandler(Arrays.copyOfRange(args, 2, args.length));
    response = String.join(", ", "order", regionToString(u.location), u.getName(), response) + "; ";
    return response;
  }
  
  String getAllOrders() {
    ArrayList<String> response = new ArrayList<String>();
    response.add("clearorders, now; ");
    if(theater.phase != Phases.BUILD) {
      for(Unit u: getAllUnits()) {
        if(theater.phase == Phases.MOVEPHASE || u.dislodged) {
          response.add(orderHandler(u.currOrder.getStatus()));
        }
      }
    } else {
      ;
    }
    return String.join("", response);
  }
  
  ArrayList<Region> getAvailableHomeCenters() {
    ArrayList<Region> availableCenters = new ArrayList<Region>();
    for(Region r: homeCenters) {
      if(!r.isEmpty() || r.owner != this) continue;
      for(Order b: builds) {
        if(b.target == r) continue;
      }
      availableCenters.add(r);
    }
    return availableCenters;
  }
  
  String getInfo() {return name + "(" + numCenters + ")\n";}
  
  PShape renderOrders() {
    PShape s = createShape(GROUP);
    PShape i;
    for(Unit u: getAllUnits()) {
      i = u.currOrder.render();
      s.addChild(i);
    }
    return s;
  }
  
  void defaultOrders(Phases phase) {
    for(Unit u: getAllUnits()) u.resetOrders(phase);
  }
  
  String getUpdatedData() {
    String commands = addCommand("name", name);
    commands += addCommand("color", Integer.toString(col));
    commands += addCommand("centers", Integer.toString(numCenters));
    return commands;
  }
  
  ArrayList<Order> getAllOrders(Phases phase) {
    if(phase == Phases.BUILD) return builds;
    ArrayList<Order> ret = new ArrayList<Order>();
    for(Unit u: getAllUnits()) ret.add(u.currOrder);
    return ret;
  }
  
  ArrayList<Unit> getAllUnits() {
    ArrayList<Unit> ret = new ArrayList<Unit>();
    ret.addAll(armies);
    ret.addAll(fleets);
    return ret;
  }
}
