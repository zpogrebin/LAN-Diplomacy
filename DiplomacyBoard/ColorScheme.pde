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
