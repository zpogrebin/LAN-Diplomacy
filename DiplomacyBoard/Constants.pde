//    __             ___  _      __                        
//   / /  ___ ____  / _ \(_)__  / /__  __ _  ___ _______ __
//  / /__/ _ `/ _ \/ // / / _ \/ / _ \/  ' \/ _ `/ __/ // /
// /____/\_,_/_//_/____/_/ .__/_/\___/_/_/_/\_,_/\__/\_, / 
//                      /_/                         /___/  
// Lan Diplomacy Development File
// Sep 13, 2021

final color LIGHT = #FAF5C7;
final color RED = #F74D33;
final color BLUE = #1D3C72;
final color YELLOW = #FED900;
final color BLACK = #101010;
final color DARKLIGHT = color(247, 224, 173);;
PFont PLEXSANS;
PFont PLEXSANSBOLD;
PFont PLEXSANSITA;
PFont PLEXSANSBOLDITA;
PFont PLEXMONO;
PFont PLEXMONOBOLD;
PFont PLEXSERIF;
PFont PLEXSERIFITA;
PFont PLEXSERIFBOLD;
PFont PLEXSERIFBOLDITA;
PFont FUTURA;

// Sets up fonts within processing.
// Effect: Initializes PFont objects with all desired fonts
void setupFonts() {
  PLEXSANS = createFont(dataPath("fonts/plexsansttf/IBMPlexSans-Regular.ttf"), 12);
  PLEXSANSBOLD = createFont(dataPath("fonts/plexsansttf/IBMPlexSans-Bold.ttf"), 12);
  PLEXSANSITA = createFont(dataPath("fonts/plexsansttf/IBMPlexSans-Italic.ttf"), 12);
  PLEXSANSBOLDITA = createFont(dataPath("fonts/plexsansttf/IBMPlexSans-BoldItalic.ttf"), 12);
  PLEXMONO = createFont(dataPath("fonts/plexmonottf/IBMPlexMono-Regular.ttf"), 12);
  PLEXMONOBOLD = createFont(dataPath("fonts/plexmonottf/IBMPlexMono-Bold.ttf"), 12);
  PLEXSERIF = createFont(dataPath("fonts/plexserifttf/IBMPlexSerif-Regular.ttf"), 12);
  PLEXSERIFITA = createFont(dataPath("fonts/plexserifttf/IBMPlexSerif-Italic.ttf"), 12);
  PLEXSERIFBOLD = createFont(dataPath("fonts/plexserifttf/IBMPlexSerif-Bold.ttf"), 12);
  PLEXSERIFBOLDITA = createFont(dataPath("fonts/plexserifttf/IBMPlexSerif-BoldItalic.ttf"), 12);
  FUTURA = createFont(dataPath("fonts/Futura/Futura-Medium-01.ttf"), 100);
}
