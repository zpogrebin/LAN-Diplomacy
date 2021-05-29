class Order {
  boolean failed;
  boolean valid;
  boolean targetRequired;
  boolean supportRequired;
  Region location;
  Region target;
  Region support;
  Phases availablePhase;
  Unit unit;
  int strength;
  String type;
  final int stroke = 2;
  final int arrowLength = 15;
  final int arrowWidth = 4;
  final color failColor = #ff0000;
  final color moveColor = #ff00ff;
  final color holdColor = #00ff00;
  final color convColor = #0000ff;
  final color retrColor = #00ffff;
  final int dia = 28;
  final String HOLDSTR = "Hold";
  final String MOVESTR = "Move";
  final String SUPPORTHOLDSTR = "Support-hold";
  final String CONVOYSTR = "Convoy";
  final String RETREATSTR = "Retreat";
  final String SUPPORTMOVESTR = "Support-move";
  final String DISBANDSTR = "Disband";
  final String BUILDSTR = "Build";
  final String NOTHINGSTR = "Pospone";
  final String MOVEPOSSIBILITIES = String.join(": ",
    HOLDSTR,
    MOVESTR,
    SUPPORTHOLDSTR,
    SUPPORTMOVESTR
  );
  final String FAILUREPOSSIBILITIES = String.join(": ",
    DISBANDSTR, RETREATSTR
  );
  final String BUILDPOSSIBILITES = String.join(": ",
    BUILDSTR, NOTHINGSTR
  );
  
  Order(Unit unit) {
    valid = true;
    this.unit = unit;
    failed = false;
    strength = 1;
    this.location = unit.location;
    this.type = NOTHINGSTR;
  }
  
  void fail() {
    this.failed = true;
    println("FAILED: " + getStatus());
  }
  
  void execute() {;}
  
  void breakSupport() {;}
  
  //Conversion & String handling
  Order convert(String toCode) {
    if(toCode.equals(type)) return null;
    if(toCode.equals(HOLDSTR)) return new Hold(unit);
    if(toCode.equals(MOVESTR)) return new Move(unit, target);
    if(toCode.equals(SUPPORTHOLDSTR)) return new SupportHold(unit, null);
    if(toCode.equals(SUPPORTMOVESTR)) return new SupportMove(unit, null, null);
    if(toCode.equals(CONVOYSTR)) return new Convoy(unit, null, null);
    if(toCode.equals(RETREATSTR)) return new Retreat(unit, null);
    if(toCode.equals(DISBANDSTR)) return new Disband(unit);
    if(toCode.equals(BUILDSTR)) return new Build(null, null, "Army");
    else return new Order(unit);
  }
  
  String orderHandler(String[] args) {
    return null;
  }
  
  String makeButton(String activeField, String otherFields) {
    return "|@"+activeField+": "+otherFields + "|";
  }
  
  String makeButton(Region r, ArrayList<Region> otherRs) {
    String[] otherRStrings = regionsToStrings(otherRs);
    return makeButton(regionToString(r), String.join(": ", otherRStrings));
  }
  
  String getOrderTypes() {
    if(MOVEPOSSIBILITIES.contains(type) && unit.isFleet() && location instanceof Sea) {
      return makeButton(type, MOVEPOSSIBILITIES + ": " + CONVOYSTR);
    } else if(MOVEPOSSIBILITIES.contains(type)) {
      return makeButton(type, MOVEPOSSIBILITIES);
    } else if(FAILUREPOSSIBILITIES.contains(type)) {
      if(getEmptyAdjacentRegions().size() == 0) return makeButton(type, DISBANDSTR);
      return makeButton(type, FAILUREPOSSIBILITIES);
    } else {
      return makeButton(type, BUILDPOSSIBILITES);
    }
  }
  
  String getStatus() {
    String response = regionToString(location) + " " + type;
    if(target != null) response += " " + regionToString(target);
    if(support != null) response += " " + regionToString(support);
    return response;
  }
  
  //MOVE POSSIBILITIES
  ArrayList<Region> getPossibleMoves() {
    ArrayList<Region> moves = new ArrayList<Region>(getAdjacentRegions());
    //if(!unit.isFleet()) moves.addAll(getPossibleConvoys(location));
    return moves;
  }
  
  ArrayList<Region> getPossibleMoves(Unit u) {
    ArrayList<Region> moves = new ArrayList<Region>(getAdjacentRegions());
    if(!u.isFleet()) moves.addAll(getPossibleConvoys(u.location));
    return moves;
  }
  
  ArrayList<Region> getPossibleConvoySupports() {
    if(!unit.isFleet()) return new ArrayList<Region>();
    ArrayList<Region> moves = new ArrayList<Region>(getAdjacentRegions());
    for(Region move : moves) if(move instanceof Sea) moves.remove(move);
    return moves;
  }
  
  ArrayList<Region> getPossibleConvoys(Region r) {
    return getPossibleConvoys(r, r, new ArrayList<Region>());
  }
  
  ArrayList<Region> getPossibleConvoys(Region orig, Region r, ArrayList<Region> checkedSeas) {
    ArrayList<Region> possibleDests = new ArrayList<Region>();
    for(Region possibleR : r.seaBorders) {
      if(possibleDests.contains(possibleR)) continue;
      else if(checkedSeas.contains(possibleR)) continue;
      if(possibleR instanceof Land && !orig.landBorders.contains(possibleR)) {
        possibleDests.add(possibleR);
      } else if(possibleR instanceof Sea && !possibleR.isEmpty()) {
        checkedSeas.add(possibleR);
        possibleDests.addAll(getPossibleConvoys(orig,possibleR,checkedSeas));
      }
    }
    return possibleDests;
  }
  
  ArrayList<Region> getAdjacentRegions() {
    if(unit.isFleet()) return location.seaBorders;
    else return location.landBorders;
  }
  
  ArrayList<Region> getEmptyAdjacentRegions() {
    ArrayList<Region> moves = new ArrayList<Region>();
    for(Region r: getAdjacentRegions()) {
      if(r.isEmpty()) moves.add(r);
    }
    return moves;
  }
  
  ArrayList<Region> getPossibleAttackPartners(Region r) {
    ArrayList<Region> ret = new ArrayList<Region>();
    for(Region endp : r.landBorders) {
      if(endp.getOccupier() == null) continue;
      if(endp.getOccupier() == unit) continue;
      if(endp.getOccupier().isArmy()) ret.add(endp);
    }
    for(Region endp : r.seaBorders) {
      if(endp.getOccupier() == null) continue;
      if(endp.getOccupier() == unit) continue;
      if(endp.getOccupier().isFleet()) ret.add(endp);
    } //Todo add convoys
    return ret;
  }
  
  ArrayList<Region> getPossibleTargets() {
    return null;
  }
  
  ArrayList<Region> getPossibleSupports() {
    return null;
  }
  
  //VALIDITY AND FAILURE CHECKING
  void makeInvalid() {
    valid = false;
    failed = true;
  }
  
  void checkValidity() {
    if(targetRequired) {
      if(target == null) makeInvalid();
      else if(!getPossibleTargets().contains(target)) makeInvalid();
    } if(supportRequired) {
      if(support == null) makeInvalid();
      else if(!getPossibleSupports().contains(support)) makeInvalid();
      else if(support.isEmpty()) makeInvalid();
    }
  }
  
  //DRAWING
  PShape render() {
    println("returning null render @ " + unit.getInfo());
    return createShape();
  }
  
  void vertexPair(float[] pair, PShape shape) {
    shape.vertex(pair[0],pair[1]);
  }
  
  PShape renderArrow(Region from, Region to, color c) {
    Unit u;
    if(!from.isEmpty()) u = from.getOccupier();
    else u = unit;
    PShape arrow = createShape();
    float[] end = to.getPos(u);
    float[] arrowCenter = getPointAlong(end, from.getPos(u), 0.5, false);
    float[] arrowTip = getPointAlong(arrowCenter, end, arrowLength, true);
    float[] arrowLeft = getPerpPoint(arrowCenter, end, arrowWidth, true);
    float[] arrowRight = getPerpPoint(arrowCenter, end, arrowWidth, false);
    arrow.beginShape();
    arrow.stroke(c);
    arrow.strokeCap(2);
    arrow.strokeJoin(2);
    arrow.fill(c);
    arrow.strokeWeight(stroke);
    arrow.beginShape();
    vertexPair(from.getPos(u), arrow);
    vertexPair(end, arrow);
    vertexPair(arrowCenter, arrow);
    vertexPair(arrowLeft, arrow);
    vertexPair(arrowTip, arrow);
    vertexPair(arrowRight, arrow);
    vertexPair(arrowCenter, arrow);
    vertexPair(end, arrow);
    arrow.endShape();
    return arrow;
  }
  
  PShape drawToMidPoint(Region from, Region to1, Region to2, color c) {
    Unit u;
    if(!to1.isEmpty()) u = to1.getOccupier();
    else u = unit;
    PShape s = createShape();
    s.beginShape();
    s.stroke(c);
    s.strokeWeight(stroke);
    vertexPair(from.getPos(unit), s);
    vertexPair(getPointAlong(to1.getPos(u), to2.getPos(u), 0.5, false), s);
    s.endShape();
    return s;
  }
  
  float getLength(float[] val) {
    return sqrt(pow(val[0], 2) + pow(val[1], 2));
  }
  
  float[] addCoords(float[] a, float[] b) {
    return new float[] {a[0] + b[0], a[1] + b[1]};
  }
  
  float[] getD(float[] from, float[] to) {
    return new float[] {to[0] - from[0], to[1] - from[1]};
  }
  
  float[] getPointAlong(float[] from, float[] to, float percentage, boolean absoluteLength) {
    if(absoluteLength) percentage = percentage/(float)getLength(getD(from,to));
    return new float[] {
      (int) (from[0] + getD(from,to)[0] * percentage),
      (int) (from[1] + getD(from,to)[1] * percentage)
    };
  }
  
  float[] getPerpPoint(float[] start, float[] along, float dist, boolean right) {
    float[] disp = getD(start,along);
    if(right) disp = new float[]{disp[1], -disp[0]};
    else disp = new float[]{-disp[1], disp[0]};
    disp = addCoords(disp, start);
    return getPointAlong(start, disp, dist, true);
  }
}

class Hold extends Order {
  Hold(Unit unit) {
    super(unit);
    availablePhase = Phases.MOVEPHASE;
    targetRequired = false;
    supportRequired = false;
    type = HOLDSTR;
  }
  
  PShape render() {
    color c;
    if(failed) c = failColor;
    else c = holdColor;
    float[] pos = location.getPos(unit);
    PShape s = createShape(ELLIPSE, pos[0], pos[1], dia, dia);
    s.setStrokeWeight(stroke/2);
    s.setStroke(true);
    s.setStroke(c);
    s.setStrokeWeight(stroke);
    s.setFill(false);
    return s;
  }
  
  String orderHandler(String[] args) {
    return getOrderTypes();
  }
}

class Move extends Order {
  Move(Unit unit, Region target) {
    super(unit);
    this.target = target;
    availablePhase = Phases.MOVEPHASE;
    targetRequired = true;
    supportRequired = false;
    type = MOVESTR;
  }
  
  ArrayList<Region> getPossibleTargets() {
    return getPossibleMoves();
  }
  
  PShape render() {
    if(target == null) {
      return createShape(GROUP);
    }
    if(failed) return renderArrow(location, target, failColor);
    else return renderArrow(location, target, moveColor);
  }
  
  String orderHandler(String[] args) {
    if(args.length == 1) target = stringToRegion(args[0]);
    else target = getPossibleTargets().get(0);
    return getOrderTypes() + "into" + makeButton(target, getPossibleTargets());
  }
  
  void execute() {
    if(failed || !valid) return;
    unit.hardMove(target);
  }
}

class SupportMove extends Order {
  SupportMove(Unit unit, Region target, Region support) {
    super(unit);
    availablePhase = Phases.MOVEPHASE;
    this.target = target;
    this.support = support;
    targetRequired = true;
    supportRequired = true;
    type = SUPPORTMOVESTR;
  }
  
  ArrayList<Region> getPossibleTargets() {
    ArrayList<Region> inp = getAdjacentRegions();
    ArrayList<Region> ret = new ArrayList<Region>();
    for(Region r: inp) {
      if(getPossibleAttackPartners(r).size() != 0) ret.add(r);
    }
    return ret;
  }
  
  ArrayList<Region> getPossibleSupports() {
    return getPossibleAttackPartners(target);
  }
  
  PShape render() {
    PShape s = createShape(GROUP);
    color c;
    if(failed) c = failColor;
    else c = moveColor;
    s.addChild(renderArrow(support, target, 0xAAAAAAAA));
    s.addChild(drawToMidPoint(location, support, target, c));
    return s;
  }
  
  String orderHandler(String[] args) {
    String ret = getOrderTypes() + "an action into";
    if(args.length < 1) target = getPossibleTargets().get(0);
    else target = stringToRegion(args[0]);
    if(args.length < 2) support = getPossibleSupports().get(0);
    else if(!args[0].equals(regionToString(target))) {
      support = getPossibleSupports().get(0);
    }
    else support = stringToRegion(args[1]);
    ret += makeButton(target, getPossibleTargets());
    ret += "by the unit in" + makeButton(support, getPossibleSupports());
    return ret;
  }
  
  void checkValidity() {
    if(target == null || support == null) makeInvalid();
    if(!getPossibleTargets().contains(target)) makeInvalid();
    if(!getPossibleSupports().contains(support)) makeInvalid();
    if(support.getOccupier().currOrder.type != MOVESTR) makeInvalid();
    if(support.getOccupier().currOrder.target != target) makeInvalid();
  }
  
  void execute() {
    checkValidity();
    if(failed || !valid) return;
    support.getOccupier().incrementStrength();
  }
  
  void breakSupport() {fail();}
} 

class SupportHold extends Order {
  SupportHold(Unit unit, Region support) {
    super(unit);
    availablePhase = Phases.MOVEPHASE;
    this.support = support;
    targetRequired = false;
    supportRequired = true;
    type = SUPPORTHOLDSTR;
  }
  
  ArrayList<Region> getPossibleSupports() {
    return getAdjacentRegions();
  }
  
  PShape render() {
    color c;
    if(failed) c = failColor;
    else c = holdColor;
    float[] pos = support.getPos();
    PShape circ = createShape(ELLIPSE, pos[0], pos[1], dia, dia);
    circ.setStrokeWeight(stroke);
    circ.setStroke(c);
    circ.setFill(false);
    PShape line = createShape();
    line.beginShape();
    line.stroke(c);
    line.strokeWeight(stroke);
    vertexPair(location.getPos(), line);
    vertexPair(getPointAlong(support.getPos(), location.getPos(), dia/2, true), line);
    PShape grp = createShape(GROUP);
    grp.addChild(line);
    grp.addChild(circ);
    return grp;
  }
  
  String orderHandler(String[] args) {
    if(args.length == 1) support = stringToRegion(args[0]);
    else support = getPossibleSupports().get(0);
    return getOrderTypes() + "the unit in" + makeButton(support, getPossibleSupports());
  }
  
  void checkValidity() {
    if(support == null) makeInvalid();
    if(!getPossibleSupports().contains(support)) makeInvalid();
    if(support.getOccupier().currOrder.type == MOVESTR) makeInvalid();
    if(support.getOccupier().currOrder.type == SUPPORTHOLDSTR) makeInvalid(); //Is this true?
  }
  
  void execute() {
    checkValidity();
    if(failed || !valid) return;
    if(target.isEmpty()) return;
    target.getOccupier().incrementStrength();
  }
  
  void breakSupport() {fail();}
}

class Convoy extends Order {
  Convoy(Unit unit, Region target, Region from) {
    super(unit);
    availablePhase = Phases.MOVEPHASE;
    this.target = target;
    this.support = from;
    targetRequired = true;
    supportRequired = true;
    type = CONVOYSTR;
  }
  
  ArrayList<Region> getPossibleTargets() {
    return getPossibleConvoySupports();
  }
  
  ArrayList<Region> getPossibleSupports() {
    return getPossibleConvoySupports();
  }
  
  PShape render() {
    PShape s = createShape(GROUP);
    color c;
    if(failed) c = failColor;
    else c = convColor;
    s.addChild(renderArrow(support, target, 0xAAAAAAAA));
    s.addChild(drawToMidPoint(location, support, target, c));
    return s;
  }
  
  String orderHandler(String[] args) {
    String ret = getOrderTypes() + "the unit in";
    if(args.length < 1) support = this.getPossibleSupports().get(0);
    else if(args.length < 2) {
      target = getPossibleTargets().get(0);
    }
    support = stringToRegion(args[0]);
    ret += makeButton(target, getPossibleTargets());
    if (args.length == 2) {
      target = stringToRegion(args[1]);
      ret += "into" + makeButton(target, getPossibleTargets());
    }
    return ret;
  }
  
  String getStatus() {
    String response = regionToString(location) + " " + type;
    if(support != null) response += " " + regionToString(support);
    if(target != null) response += " " + regionToString(target);
    return response;
  }
}

class Retreat extends Order {
  Retreat(Unit unit, Region target) {
    super(unit);
    this.target = target;
    availablePhase = Phases.RETREAT;
    targetRequired = true;
    supportRequired = false;
    type = RETREATSTR;
  }
  
  ArrayList<Region> getPossibleTargets() {
    return getEmptyAdjacentRegions();
  }
  
  PShape render() {
    return renderArrow(location, target, retrColor);
  }
  
  String orderHandler(String[] args) {
    if(args.length == 1) target = stringToRegion(args[0]);
    else target = getPossibleTargets().get(0);
    return getOrderTypes() + "into" + makeButton(target, getPossibleTargets());
  }
  
  void execute() {
    if(failed || !valid) return;
    unit.location.setDislodged(null);
    unit.hardMove(target);
    unit.dislodged = false;
  }
}

class Disband extends Order {
  Disband(Unit unit) {
    super(unit);
    availablePhase = Phases.RETREAT;
    targetRequired = true;
    supportRequired = false;
    type = DISBANDSTR;
  }
  
  String orderHandler(String[] args) {
    return getOrderTypes();
  }
  
  void execute() {
    unit.location.setDislodged(null);
    if(unit.isFleet()) unit.owner.fleets.remove(unit);
    if(unit.isArmy()) unit.owner.armies.remove(unit);
  }
}

class Build extends Order {
  String type;
  Player player;
  
  Build(Player player, Region target, String type) {
    super(null);
    availablePhase = Phases.BUILD;
    this.target = target;
    this.type = type;
    this.player = player;
  }
}

class DisbandInPlace extends Order {
  
  Player player;
  
  DisbandInPlace(Player player, Region target) {
    super(null);
    this.target = target;
    this.player = player;
  }
}
