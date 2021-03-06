//    __             ___  _      __                        
//   / /  ___ ____  / _ \(_)__  / /__  __ _  ___ _______ __
//  / /__/ _ `/ _ \/ // / / _ \/ / _ \/  ' \/ _ `/ __/ // /
// /____/\_,_/_//_/____/_/ .__/_/\___/_/_/_/\_,_/\__/\_, / 
//                      /_/                         /___/  
// Lan Diplomacy Development File
// Sep 13, 2021

import processing.net.*;

class GameServer {
  Server server;
  Client client;
  Board m;
  String variant;
  String saveFile;
  boolean loadNewGame = true;
  boolean gameInProgress;
  boolean gamesAvailable = true;
  int port;
  int uix,uiy; //UI dims
  PImage cover;
  PApplet parent;
  
  //UIElements
  UIMomentary startButton;
  UIToggleV variantButton;
  UIToggleV saveSelectButton;
  UIToggleH newGameButton;
  UIIncrementBox serverPort;
  UITimer auxTime;
  UITimer moveTime;
  UIButton pauseButton;
  
  GameServer(PApplet parent) {
    uix = 34;
    uiy = 625;
    gameInProgress = false;
    setupUIElements();
    cover = loadImage(dataPath("resources/cover.jpg"));
    this.parent = parent;
  }
  
  void setupUIElements() {
    ColorScheme c = new ColorScheme(#101010, #F84629, #1D3C72, color(255), color(255));
    PositionSpecifier p = new PositionSpecifier(100.0, 100.0, 40.0, 40.0, 0);
    p.set_coords(uix,uiy,190,40);
    String[] saves = listFileNames(dataPath("saves"));
    String[] variants = listFileNames(dataPath("variants"));
    if(saves.length != 0) {
      newGameButton = new UIToggleH(p, "", c, new String[]{"New Game:", "Load Save:"});
      p.set_coords(uix,50+uiy,140,200);
      saveSelectButton = new UIToggleV(p, "Select Savefile", c, saves);
    } else gamesAvailable = false;
    if(!gamesAvailable) p.set_coords(uix,uiy,140,130);
    variantButton = new UIToggleV(p, "Select Variant", c, variants);
    p.set_coords(uix + 150,uiy,120, 40);
    moveTime = new UITimer(p, "move", c, 0, 30, 1, 5);
    p.set_coords(uix + 150,uiy+50,120, 40);
    auxTime = new UITimer(p, "aux", c, 0, 15, 1, 5);
    p.set_coords(352+uix,uiy,90,40);
    serverPort = new UIIncrementBox(p, "Port", c, 6969, 1);//(int)random(1, 65535)
    p.set_coords(352+uix,50+uiy,90,80);
    startButton = new UIMomentary(p, "Start Game", c);
    pauseButton = new UIButton(p, "Pause", c);
  }
  void update() {
    if(!gameInProgress) {
      startButton.update();
      serverPort.update();
      if(startButton.getValue()) startGame(); 
      if(gamesAvailable) {
        newGameButton.update();
        loadNewGame = newGameButton.getIndex()==0;
      }
      auxTime.update();
      moveTime.update();
      if(loadNewGame) variantButton.update();
      else saveSelectButton.update();
    } else {
      parseCommands();
      m.update();
      pauseButton.update();
      if(pauseButton.getValue()) {
        m.paused = true;
        pauseButton.setId("Play");
      } else {
        m.paused = false;
        pauseButton.setId("Pause");
      }
    }
  }
  
  void parseCommands() {
    client = server.available();
    if(client == null) return;
    String inputString = client.readString();
    println("Parsing:\t" + inputString);
    String[] cmds = inputString.split("; ");
    if(cmds.length == 1) client.write(m.getTime());
    if(cmds[0].equals("join")) client.write(m.joinGame(cmds[1]));
    if(cmds[0].equals("update")) client.write(m.getUpdatedData(cmds[1]));
    if(cmds[0].equals("order")) client.write(m.orderHandler(cmds[1],cmds[2]));
    if(cmds[0].equals("orders")) write(client, m.getAllOrders(cmds[1]));
  }
  
  void write(Client c, String str) {
    println("Response:\t" + str);
    c.write(str);
  }
  
  String[] listFileNames(String dir) {
    File file = new File(dir);
    if (file.isDirectory()) {
      String names[] = new String[]{};
      for(String f : file.list()) {
        if(!f.substring(0,1).equals(".")) names = concat(names, new String[]{f});
      }
      return names;
    } else {
      return null;
    }
  }
    
  void draw() {
    if(!gameInProgress) {
      textFont(PLEXSANS);
      image(cover,0,0,515,768);
      if(loadNewGame) variantButton.draw();
      else saveSelectButton.draw();
      startButton.draw();
      if(gamesAvailable) newGameButton.draw();
      serverPort.draw();
      auxTime.draw();
      moveTime.draw();
    } else {
      m.draw();
      pauseButton.draw();
    }
  }
  
  void keyPressed(char k) {
    if(!gameInProgress) {
      serverPort.keyPressed(k);
      auxTime.keyPressed(k);
      moveTime.keyPressed(k);
    }
  }
  
  void startGame() {
    gameInProgress = true;
    if(loadNewGame) m = new Board(variantButton.getValue(), null, moveTime.t, auxTime.t);
    m.updateRender();
    surface.setSize((int)m.w, (int)m.h);
    port = (int)serverPort.getValue();
    server = new Server(parent, port);
    pauseButton.setP(new PositionSpecifier(m.w-100, m.h-100, 50, 50));
  }
}
