//    __             ___  _      __                        
//   / /  ___ ____  / _ \(_)__  / /__  __ _  ___ _______ __
//  / /__/ _ `/ _ \/ // / / _ \/ / _ \/  ' \/ _ `/ __/ // /
// /____/\_,_/_//_/____/_/ .__/_/\___/_/_/_/\_,_/\__/\_, / 
//                      /_/                         /___/  
// Lan Diplomacy Development File
// Sep 13, 2021

GameServer gs;

/******************************************************************
 * PROCESSING FUNCTIONS WHICH ARE CALLED BY PROCESSING (SEE DOCS) *
 ******************************************************************/

// Sets up the game
// Effects: initializes fonts, game server, and the size of the window
void setup() {
  setupFonts();
  surface.setSize(515, 768);
  surface.setLocation(0,0);
  pixelDensity(displayDensity());
  gs = new GameServer(this);
}

// Built in draw loop for the game.
void draw() {
  clear();
  background(#EDEADF);
  gs.update();
  gs.draw();
  drawDebugInfo();
}

// Built in function, called if any key is pressed
void keyPressed() {
  gs.keyPressed(key);
  if(key == 'a') gs.m.advanceSeasons(); //temporary, for debugging purposes
}

/*****************************************
 * ADDITIONAL TOP LEVEL HELPER FUNCTIONS *
 *****************************************/

// Helper function for calculating ordinals (1st, 2nd, etc)
// Inputs: int num, the number to ordinate
// Output: string, the ordinal of the number
String ordinal(int num) {
  while(num >= 10) num %= 10;
  if(num == 1) return "st";
  if(num == 2) return "nd";
  if(num == 3) return "rd";
  else return "th";
}

// Helper function for ordinating strings.
// Inputs: int num, the number to ordinate
// Output: string, the number with the ordinal after, as a string
String ordWithNum(int num) {
  return str(num) + ordinal(num);
}

// Helper function for drawing debugging info, including crosshair and fps count
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

// Gets the formatted string names for a list of regions.
// Input: ArrayList of Regions -- a list of regions to get string names
// Output: array of strings, containing the names of each region
String[] regionsToStrings(ArrayList<Region> input) {
  String[] strs = new String[input.size()];
  for(int i = 0; i < input.size(); i++) {
    strs[i] = regionToString(input.get(i));
  }
  return strs;
}

// Gets the formatted string name for a single region
// Input: Region
// Output: string containing the names of each region
String regionToString(Region input) {
  if(input == null) return "(select)";
  return input.abrName + "/" + input.name.replace(" ","_");
}

// Gets the formatted string names for a list of regions.
// Input: Array of strings -- a list of regions names to lookup
// Output: ArrayList of Regions containing the regions corresponding to ea. name
ArrayList<Region> stringsToRegions(String[] strs) {
  ArrayList<Region> regions = new ArrayList<Region>();
  for(String str : strs) {
    regions.add(stringToRegion(str));
  }
  return regions;
}

// Gets the formatted string name for a single region
// Input: String, properly formatted region name
// Output: looks up region by string and returns result
Region stringToRegion(String str) {
  if(str.length() < 3) return null;
  if(str.contains("_nc") || str.contains("_sc")) {
    return gs.m.getRegion(str.substring(0,6));
  }
  return gs.m.getRegion(str.substring(0,3));
}

// Helper function for formatting commands
// Inputs: String command name
//         String command argument
// Output: String, command in proper format
String addCommand(String cmd, String arg) {
  return cmd + ", " + arg + "; ";
}

