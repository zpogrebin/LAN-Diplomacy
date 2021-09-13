//    __             ___  _      __                        
//   / /  ___ ____  / _ \(_)__  / /__  __ _  ___ _______ __
//  / /__/ _ `/ _ \/ // / / _ \/ / _ \/  ' \/ _ `/ __/ // /
// /____/\_,_/_//_/____/_/ .__/_/\___/_/_/_/\_,_/\__/\_, / 
//                      /_/                         /___/  
// Lan Diplomacy Development File
// Sep 13, 2021

// Container class for the color scheme of UI Buttons. Contains colors for the 
// UI Element background text for various states.
class ColorScheme {
  color unclicked;
  color highlight;
  color clicked;
  color text;
  color clickedtext;
  int fontSize = 12;
  
  ColorScheme(color iun, color ihi, color icl, color ite, color ict) {
    unclicked = iun;
    highlight = ihi;
    clicked = icl;
    text = ite;
    clickedtext = ict;
  }
  
  ColorScheme(color iun, color ihi, color icl, color ite, color ict, int ifs) {
    this(iun, ihi, icl, ite, ict);
    fontSize = ifs;
  }
}
