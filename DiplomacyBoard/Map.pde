import java.util.Map;
import java.util.Arrays;
import java.util.Collections;

enum Phases {MOVEPHASE, BUILD, RETREAT};

class Board {
  
  HashMap<String, Region> regions;
  HashMap<String, Player> players;
  int year;
  boolean spring;
  Phases phase;
  PShape globalPattern;
  PShape labelPattern;
  PShape render;
  float w, h;
  Timer auxTime;
  Timer moveTime;

  Board(String variant, String saveFile, Timer moveTime, Timer auxTime) {
    regions = new HashMap<String, Region>();
    players = new HashMap<String, Player>();
    year = 0;
    phase = Phases.MOVEPHASE;
    loadFromFile(dataPath("variants/" + variant + "/config.ddat"), variant);
    loadFromFile(dataPath("variants/" + variant + "/start.ddat"), variant);
    loadShapes(dataPath("variants/" + variant + "/map.svg"));
    defaultOrders(phase);
    this.auxTime = auxTime;
    this.moveTime = moveTime;
    if(saveFile != null) {
      ;
    }
  }
  
  Board(String variant) {
    this(variant, null, null, null);
  }
  
  String getInfo() {
    String str = "";
    str += "PLAYERS\n";
    for(Map.Entry<String, Player> p:players.entrySet()) str += p.getValue().getInfo();
    str += "REGIONS\n";
    for(Map.Entry<String, Region> r:regions.entrySet()) str += r.getValue().getInfo() + "\n";
    return str;
  }
  
  Player getPlayer(String passphrase) {
    for(Player p : players.values()) {
      if(p.passphrase.equals(passphrase)) return p;
      else if(passphrase.equals(p.abrName)) {
        println("HARD JOIN");
        return p;
      } //TODO: REMOVE LATER
    }
    return null;
  }

  //GRAPHICS FUNCTIONS
  void draw() {
    shapeMode(CORNER);
    shape(render);
    textAlign(LEFT, CENTER);
    fill(0);
    text(getPhase(), 50, h-50);
    if(phase == Phases.MOVEPHASE) text(moveTime.getColonSeparated(2), 50, h-20);
    else text(auxTime.getColonSeparated(2), 50, h-20);
  }
  
  void update() {
    boolean next = false;
    if(auxTime != null) {
      next |= auxTime.update();
      next |= moveTime.update();
    }
    if(next) advanceSeasons();
  }
  
  void updateRender() {
    render = getMapRender(null);
  }
  
  PShape getBaseRender() {
    PShape rend = createShape(GROUP);
    PShape subRender;
    shapeMode(CORNER);
    rend.addChild(globalPattern);
    for(Map.Entry<String, Region> r : regions.entrySet()) {
      subRender = r.getValue().render();
      if(subRender != null) rend.addChild(subRender);
    }
    return rend;
  }
    
  PShape getMapRender(Player p) {
    PShape rend = createShape(GROUP);
    PShape subRender;
    rend.addChild(getBaseRender());
    rend.addChild(labelPattern);
    if(p == null) {
      for(Map.Entry<String, Player> p_i : players.entrySet()) {
        subRender = p_i.getValue().renderOrders();
        rend.addChild(subRender);
      }
    } else {
      rend.addChild(p.renderOrders());
    }
    for(Map.Entry<String, Player> p_i: players.entrySet()) {
      rend.addChild(p_i.getValue().render());
    }
    return rend;
  }
  
  //FILE HANDLING COMMANDS
  void loadFromFile(String filename, String variant) {
    boolean midGame = true;
    String lines[] = loadStrings(filename);
    for(String line : lines) {
      try {
        line = trim(line);
        String[] cmds = line.split(" ");
        if(line.substring(0,2).equals("//")) continue;
        else if(cmds[0].equals("player")) newPlayer(cmds, variant);
        else if(cmds[0].equals("sea")) newRegion(cmds, midGame);
        else if(cmds[0].equals("sea")) newRegion(cmds, midGame);
        else if(cmds[0].equals("land")) newRegion(cmds, midGame);
        else if(cmds[0].equals("coastal")) newRegion(cmds, midGame);
        else if(cmds[0].equals("mode") && cmds[1].equals("init")) midGame = false;
        else if(cmds[0].equals("connect")) connectRegions(cmds);
        else if(cmds[0].equals("cncoast")) connectCoast(cmds);
        else if(cmds[0].equals("pos")) positionCommand(cmds);
        else if(cmds[0].equals("@")) setOccupier(cmds);
        else if(cmds[0].equals("<")) setOwner(cmds, midGame);
        else if(cmds[0].equals("date")) setDate(cmds[1], cmds[2], cmds[3]);
      } catch(Exception e) {
        println("\nERROR ON: " + line);
        println("EXCEPTION: " + e + "\n");
      }
    }
  }

  void loadShapes(String filename) {
    PShape image = loadShape(filename);
    w = image.width;
    h = image.height;
    globalPattern = image.getChild("Global");
    labelPattern = image.getChild("Labels");
    for(Map.Entry<String, Region> r : regions.entrySet()) {
      r.getValue().attachShape(image.getChild(r.getKey()));
    }
    println("All Images Loaded");
  }

  private void newPlayer(String[] args, String filename) {
    println("Adding player: " + args[1]);
    if(args.length == 4) {
      players.put(args[2], new Player(args[1], args[2], this, unhex("FF"+args[3])));
    } else {
      players.put(args[2], new Player(args[1], args[1].substring(0,3), this, unhex("FF"+args[2])));
    }
    players.get(args[2]).initShapes(filename);
  }
  
  private void newRegion(String[] args, boolean midGame) {
    println("Adding region: " + args[1]);
    String type = args[0];
    String name = args[1];
    String abrName = name.substring(0,3);
    boolean center = false;
    for(String arg : args) if(arg.equals("center")) center = true;
    Region region;
    if(args.length >= 3 && !args[2].equals("center") && !args[2].equals("<")) {
      abrName = args[2];
    }
    if(type.equals("sea")) region = new Sea(name, abrName);
    else if(type.equals("land")) region = new Land(name, abrName, center);
    else region = new Coastal(name, abrName, center);
    regions.put(abrName, region);
    checkModifiers(args, region, midGame);
  }
  
  private void checkModifiers(String[] args, Region r, boolean midGame) {
    for(int i = 0; i < args.length; i++) {
      if(args[i].equals("@")) {
        setOccupier(new String[]{args[i], r.abrName, args[i+1]});
      } else if(args[i].equals("<")) {
        setOwner(new String[]{args[i], r.abrName, args[i+1]}, midGame);
      }
    }
  }
  
  private void setOccupier(String[] args) {
    ArrayList<String> subArgs;
    int num = -1;
    Player commander;
    subArgs = new ArrayList<String>(Arrays.asList(args[2].split("\\.")));
    commander = players.get(subArgs.get(0));
    if(subArgs.size() > 2) num = Integer.valueOf(subArgs.get(2));
    commander.placeUnit(getRegion(args[1]), subArgs.get(1).equals("f"), num);
  }
  
  private void setOwner(String[] args, boolean mid) {
    Region r = getRegion(args[1]);
    r.owner = players.get(args[2]);
    if(r.supplyCenter) r.owner.incrementCenters(true);
    if(!mid) r.owner.homeCenters.add(r);
  }
  
  private void connectRegions(String[] args) {
    Region from = getRegion(args[1]);
    Region to;
    ArrayList<String> subArgs;
    boolean land, sea;
    for(int i = 2; i < args.length; i++) {
      subArgs = new ArrayList<String> (Arrays.asList(args[i].split("\\.")));
      println("Connecting " + from.abrName + " <=> " + args[i]);
      land = false;
      sea = false;
      if(subArgs. contains("l")) land = true;
      if(subArgs.contains("s")) sea = true;
      if(!land && !sea) {
        land = true;
        sea = true;
      }
      to = getRegion(subArgs.get(subArgs.size() - 1));
      from.connect(to,land,sea);
      to.connect(from,land,sea);
    }
  }
  
  private void connectCoast(String[] args) {
    Region to;
    Coastal from = (Coastal)getRegion(args[1]);
    ArrayList<String> subArgs;
    boolean land, north, south;
    for(int i = 2; i < args.length; i++) {
      subArgs = new ArrayList<String> (Arrays.asList(args[i].split("\\.")));
      println("Connecting " + from.abrName + " <=> " + args[i] + " coastally");
      land = false;
      north = false;
      south = false;
      to = getRegion(subArgs.get(subArgs.size()-1));
      if(subArgs.contains("l")) land = true;
      if(subArgs.contains("s")) south = true;
      if(subArgs.contains("n")) north = true;
      if(!land && !north && !south) {
        land = true;
        south = true;
        north = true;
      }
      if(land) {
        from.connect(to, true, false);
        to.connect(from,true, false);
      } 
      if(north) {
        to.connect(from.northCoast,false, true);
        from.northCoast.connect(to, false, true);
      }
      if(south) {
        to.connect(from.southCoast,false, true);
        from.southCoast.connect(to, false, true);
      }
    }
  }
  
  private void positionCommand(String[] args) {
    println("Building map: @" + args[1]); 
    int x[] = new int[args[2].split("\\.").length];
    Region from = getRegion(args[1]);
    for(int i = 0; i < x.length; i++) {
      x[i] = Integer.parseInt(args[2].split("\\.")[i]);
    }
    if(from instanceof Coastal) {
      ((Coastal)from).setCoastalPos(x[0], x[1], x[2], x[3], x[4], x[5]);
    } else {
      if(x.length == 2) from.setPos(x[0], x[1]);
      else from.setPos(x[0], x[1], x[2], x[3]);
    }
  }

  void setDate(String year, String season, String phase) {
    this.year = Integer.valueOf(year);
    if(season.toLowerCase().equals("spring")) spring = true;
    else spring = false;
    if(phase.equals("retreat")) this.phase = Phases.RETREAT;
    else if(phase.equals("build")) this.phase = Phases.BUILD;
    else this.phase = Phases.MOVEPHASE;
  }
  
  //WIFI COMMANDS
  String getPhase() {
    String p = "";
    if(phase == Phases.BUILD) p += "Builds ";
    else if(spring) p += "Spring ";
    else p += "Autumn ";
    if(phase == Phases.RETREAT) p += "(retreat) ";
    return p + Integer.toString(year);
  }

  String getTime() {
    return "time, time";
  }

  String joinGame(String passphrase) {
    if(passphrase == "" || passphrase == "passphrase") return "Error: Invalid passphrase";
    Player p = getPlayer(passphrase);
    if(p != null) return p.name;
    ArrayList<Player> availablePlayers = new ArrayList<Player>();
    for(Map.Entry<String, Player> p_i : players.entrySet()) {
      if(p_i.getValue().passphrase == "") availablePlayers.add(p_i.getValue());
    }
    if(availablePlayers.size() == 0) return "Error: No available slots in this game!";
    Collections.shuffle(availablePlayers);
    println("Player joined!");
    availablePlayers.get(0).passphrase = passphrase;
    return availablePlayers.get(0).name;
  }

  String getUpdatedData(String passphrase) {
    Player p = getPlayer(passphrase);
    if(p == null) return "Error: invalid passphrase";
    String data = p.getUpdatedData();
    data += addCommand("date", getPhase());
    return data;
  }

  String orderHandler(String passphrase, String orders) {
    Player p = getPlayer(passphrase);
    if(p == null) return "Error: invalid passphrase";
    String response = p.orderHandler(orders);
    updateRender(); //TEMPORARY;
    return response;
  }
  
  String getAllOrders(String passphrase) {
    Player p = getPlayer(passphrase);
    if(p == null) return "Error: invalid passphrase";
    return p.getAllOrders();
  }

  //GAME OPERATION
  Region getRegion(String k) {
    String c = k.substring(k.length()-3,k.length());
    if(c.equals("_sc")) {
      return ((Coastal)regions.get(k.substring(0,3))).southCoast;
    } else if(c.equals("_nc")) {
      return ((Coastal)regions.get(k.substring(0,3))).northCoast;
    } else return regions.get(k);
  }

  void defaultOrders(Phases phase) {
    for(Map.Entry<String, Player> p_i: players.entrySet()) {
      p_i.getValue().defaultOrders(phase);
    }
  }

  void advanceSeasons() {
    //TODO ACTUALLY ADJUDICATE MOVES;
    println("Advancing game");
    adjudicatePhase();
    println("adjudication done");
    if(phase != Phases.BUILD) {
      if(retreatsNecessary()) {
        phase = Phases.RETREAT;
        return;
      } else if(!spring) {
        for(Region r : regions.values()) r.advanceOwnership();
        phase = Phases.BUILD;
      } else {
        spring = false;
      }
    } else {
      spring = true;
      year += 1;
      phase = Phases.MOVEPHASE;
    }
    updateRender();
    defaultOrders(phase);
  }

  boolean retreatsNecessary() {
    return false;
  }
  
  void adjudicatePhase() {
    if(phase == Phases.MOVEPHASE) adjudicateMoves();
  }
  
  void adjudicateMoves() {
    println("Adjudicating Moves");
    ArrayList<Order> orders = getAllOrders();
    HashMap<Region, Battle> battles = new HashMap<Region, Battle>();
    for(Order order : orders) {
      order.checkValidity();
      if(!order.valid) {
        order.fail();
        continue;
      } if(order.type == order.MOVESTR) {
        if(battles.containsKey(order.target)) {
          battles.get(order.target).addContender((Move)order);
        }
        else battles.put(order.target,new Battle(order.target, (Move)order));
      }
    }
    for(Map.Entry<Region, Battle> battle : battles.entrySet()) {
      if(battle.getKey().getOccupier() != null) {
        battle.getKey().getOccupier().currOrder.breakSupport();
      }
    } for(Order order : orders) {
      if(order.type.contains("Support")) order.execute();
    }
    boolean allDone = false;
    if(battles.size() == 0) return;
    while(allDone == false) {
      for(Battle b : battles.values()) {
        allDone = !b.simulateBattle(false);
      }
    }
    updateRender(); // temporary
    for(Battle b : battles.values()) b.simulateBattle(true);
  }
  
  ArrayList<Order> getAllOrders() {
    ArrayList<Order> ret = new ArrayList<Order>();
    for(Map.Entry<String, Player> p:players.entrySet()) {
      ret.addAll(p.getValue().getAllOrders(phase));
    }
    return ret;
  }
}
