import java.util.Map;
import java.util.Collections;

enum Mode {
  START, MOVES, HOLDING;  
}

class GameClient {
  
  Mode mode;
  Client c;
  PApplet applet;
  int lastUpdate;
  final int updateFrequency = 20000;
  Timer timer;
  
  //UI Elements
  PositionSpecifier activeP = null;
  UITextBox ipAddress;
  UIIncrementBox port;
  UITextBox passphrase;
  UIMomentary start;
  ColorScheme col;
  HashMap<String, OrderDevice> orders;
  
  //Data
  String countryName;
  String numCenters;
  color countryColor;
  String phase;
  
  
  GameClient(PApplet applet) {
    setupUI();
    this.applet = applet;
    mode = Mode.START;
    countryName = "";
    numCenters = "";
    countryColor = #ffffff;
    phase = "";
    orders = new HashMap<String, OrderDevice>();
    timer = new Timer(10000);
  }
  
  void setupUI() {
    col = new ColorScheme(LIGHT, RED, DARKLIGHT, BLACK, BLACK, 12);
    PositionSpecifier p = new PositionSpecifier(50,50,140,40,0);
    ipAddress = new UITextBox(p, "IP", col, "192.168.0.2");
    ipAddress.setValue("192.168.0.2");
    p.set_coords(200, 50);
    port = new UIIncrementBox(p, "port", col, 6969, 1);
    p.set_coords(50, 100, 290, 40);
    passphrase = new UITextBox(p, "passphrase", col, "");
    p.set_coords(250, 150, 90, 40);
    start = new UIMomentary(p, "Join", col);
    start.setNext(ipAddress);
    ipAddress.setNext(port);
    port.setNext(passphrase);
    passphrase.setNext(start);
  }
  
  void joinGame() {
    try {
      c = new Client(applet, ipAddress.getValue(), (int)port.getValue());
    } catch(Exception e) {
      println("Connection failed");
    }
    println("joining with " + passphrase.getValue());
    if(isErrorResponse(sendCommand("join", passphrase.getValue()))) return;
    updateBaseWindow(true);
  }
  
  String sendCommand(String command, String[] args, boolean quick) {
    for(String arg : args) command += "; " + arg;
    println("Sending: " + command);
    c.write(command);
    int time = millis();
    if(quick) return "";
    while(millis() - time < 1000) {
      if(c.available() > 0) {
        return c.readString();
      }
    }
    return "Error: Timeout";
  }
  
  String sendCommand(String command, String[] args) {return sendCommand(command, args, false);}
  
  String sendCommand(String command, String arg) {return sendCommand(command, new String[]{arg});}
  
  boolean isErrorResponse(String input) {
    if(input == "") return true;
    if(input.length() > 5) {
      if(input.substring(0,5).equals("Error")) return true;
    }
    return false;
  }
  
  void updateBaseWindow(boolean updateOrders) {
    lastUpdate = millis();
    if(!c.active()) mode = Mode.START;
    String data = sendCommand("update", passphrase.getValue());
    if(!isErrorResponse(data)) mode = Mode.MOVES;
    parseCommands(data);
    if(updateOrders) parseCommands(sendCommand("orders", new String[]{passphrase.getValue()}, true));
  }
  
  void parseCommands(String unparsed) {
    unparsed = unparsed.replace("_", " ");
    if(isErrorResponse(unparsed)) {
      println(unparsed);
      return;
    }
    String[] commands = unparsed.split("; ");
    for(String command : commands) {
      if(!command.contains(", ")) return;
      parseCommand(command.split(", "));
    }
  }
  
  void parseCommand(String[] v) {
    println("Parsing: " + String.join(",", v));
    if(v[0].equals("name")) countryName = v[1];
    else if(v[0].equals("color")) countryColor = Integer.valueOf(v[1]);
    else if(v[0].equals("centers")) numCenters = v[1];
    else if(v[0].equals("order")) updateOrderList(v[1], v[2], v[3]);
    else if(v[0].equals("clearorders")) resetOrders();
    else if(v[0].equals("date")) phase = v[1];
    else if(v[0].equals("time")) updateTime(v[1]);
  }
  
  void updateTime(String s) {
    timer.setByString(s);
    timer.stop();
    timer.start();
  }
  
  void resetOrders() {
    orders = new HashMap<String, OrderDevice>();
  }
  
  void updateOrderList(String location, String name, String command) {
    if(orders.containsKey(location)) orders.get(location).refreshOrder(command);
    else orders.put(location, new OrderDevice(orders.size(), name, location, command, this, col)); 
  }
  
  void draw() {
    textFont(PLEXSANS);
    if(mode == Mode.START) {
      passphrase.draw();
      port.draw();
      textFont(PLEXSANSBOLD);
      start.draw();
      textFont(PLEXSANS);
      ipAddress.draw();
    } else if(mode == Mode.MOVES) {
      drawHeading();
      for(Map.Entry<String, OrderDevice> od : orders.entrySet()) od.getValue().draw();
      for(Map.Entry<String, OrderDevice> od : orders.entrySet()) od.getValue().drawTop();
    }
  }
  
  void drawHeading() {
    noStroke();
    fill(countryColor);
    rect(0,0,width, 100);
    noFill();
    fill(LIGHT);
    textAlign(LEFT,BASELINE);
    textFont(FUTURA);
    textSize(50);
    text(countryName,25,70);
    stroke(LIGHT);
    strokeWeight(2);
    line(0,100,width,100);
    strokeWeight(1);
    line(0,150,width,150);
    textFont(PLEXSERIFBOLD);
    textSize(20);
    textAlign(LEFT,CENTER);
    text(phase, 25, 122);
    textFont(PLEXMONOBOLD);
    textAlign(RIGHT,CENTER);
    textSize(20);
    text(timer.getColonSeparated(2), width - 25, 122);
  }
  
  void keyPressed(char k) {
    if(mode == Mode.START) {
      passphrase.keyPressed(k);
      ipAddress.keyPressed(k);
      start.keyPressed(k);
      port.keyPressed(k);
    }
  }
  
  void update() {
    if(mode == Mode.START) {
      ipAddress.update();
      port.update();
      start.update();
      passphrase.update();
      if(start.getValue()) joinGame();
    } else {
      if(millis() - updateFrequency > lastUpdate) updateBaseWindow(false);
      if(c.available() > 0) parseCommands(c.readString());
      for(Map.Entry<String, OrderDevice> od : orders.entrySet()) {
        activeP = od.getValue().updateC(activeP);
      }
      if(timer.update()) {
        delay(20);
        updateBaseWindow(true);
      }
    }
  }
}
