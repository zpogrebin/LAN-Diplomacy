GameServer gs;

void setup() {
  surface.setSize(515, 768);
  surface.setLocation(0,0);
  pixelDensity(displayDensity());
  gs = new GameServer(this);
}

String ordinal(int num) {
  while(num >= 10) num %= 10;
  if(num == 1) return "st";
  if(num == 2) return "nd";
  if(num == 3) return "rd";
  else return "th";
}

String ordWithNum(int num) {
  return str(num) + ordinal(num);
}

void draw() {
  clear();
  background(#EDEADF);
  gs.update();
  gs.draw();
  drawDebugInfo();
}

void drawDebugInfo() {
  stroke(255);
  line(0,mouseY,width,mouseY);
  line(mouseX,0,mouseX, height);
  noStroke();
  fill(0);
  textAlign(LEFT,TOP);
  text("(" + Float.toString(mouseX) + ", " + Float.toString(mouseY) + ")",  + 20, mouseY + 20);
  text(frameRate + "fps", 10, 10);
  text("port" + gs.port, 10,30);
}

String[] regionsToStrings(ArrayList<Region> input) {
  String[] strs = new String[input.size()];
  for(int i = 0; i < input.size(); i++) {
    strs[i] = regionToString(input.get(i));
  }
  return strs;
}

String regionToString(Region input) {
  if(input == null) return "(select)";
  return input.abrName + "/" + input.name.replace(" ","_");
}

ArrayList<Region> stringsToRegions(String[] strs) {
  ArrayList<Region> regions = new ArrayList<Region>();
  for(String str : strs) {
    regions.add(stringToRegion(str));
  }
  return regions;
}

Region stringToRegion(String str) {
  if(str.length() < 3) return null;
  if(str.contains("_nc") || str.contains("_sc")) {
    return gs.m.getRegion(str.substring(0,6));
  }
  return gs.m.getRegion(str.substring(0,3));
}

String addCommand(String cmd, String arg) {
  return cmd + ", " + arg + "; ";
}

void keyPressed() {
  if(key == 'a') gs.m.advanceSeasons();
}
