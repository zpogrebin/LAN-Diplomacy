//GENERIC SUPERCLASS
class UIElement {
  protected PositionSpecifier p;
  protected String label;
  protected ColorScheme c;
  
  UIElement(PositionSpecifier ip, String ilabel, ColorScheme ic) {
    p = new PositionSpecifier (ip);
    label = ilabel;
    c = ic;
  }
  
  void draw() {
    ;
  }
  
  void update() {
    ;
  }
  
  String getStr() {
    return label + " (" + this.getClass().getSimpleName() + ") @" + p.getStr();
  }
  
  String getId() {
    return label;
  }
  
  void setId(String i) {
    label = i;
  }
  
  void setColor(ColorScheme cs) {
    c = cs;
  }
  
  void setP(PositionSpecifier ip) {
    p = new PositionSpecifier (ip);
  }
}

//BUTTON
class UIButton extends UIElement {
  protected boolean hover;
  protected boolean value;
  protected boolean mouseclicking;
  
  UIButton(PositionSpecifier ip, String ilabel, ColorScheme ic) {
    super(ip, ilabel, ic);
    value = false;
    mouseclicking = false;
  }
  
  boolean getValue() {
    return value;
  }
  
  void changeLabel(String newLabel) {
    label = newLabel;
  }
  
  void setValue(boolean newval) {
    value = newval;
  }
  
  void draw() {
    if(value) {
      p.makeRect(c.clicked);
      fill(c.clickedtext);
    } else if(hover) {
      p.makeRect(c.highlight);
      fill(c.text);
    } else {
      p.makeRect(c.unclicked);
      fill(c.text);
    }
    textAlign(CENTER);
    textSize(c.fontSize);
    text(label, p.center()[0], p.center()[1] + c.fontSize/3);
  }
  
  void update() {  
    if(p.mouseOver()) hover = true;
    else hover = false;
    if(mousePressed && p.mouseOver()) {
      if(!mouseclicking) {
        value = !value;
        mouseclicking = true;
      }
    } else mouseclicking = false;
  }
}

//MOMENTARY
class UIMomentary extends UIButton {
  UIMomentary(PositionSpecifier ip, String ilabel, ColorScheme ic) {
    super(ip, ilabel, ic);
  }
  
  boolean getValue() {
    boolean val = value;
    value = false;
    return val;
  }
  
  void draw() {
    if(mousePressed && p.mouseOver()) {
      p.makeRect(c.clicked);
      fill(c.clickedtext);
      text(label, p.center()[0], p.center()[1] + c.fontSize/3);
    } else super.draw();
    
  }
}

//Options
class UIBaseToggle extends UIElement {
  UIButton[] buttons;
  int curr_button;
  
  UIBaseToggle(PositionSpecifier ip, String ilabel, ColorScheme ic) {
    super(ip, ilabel, ic);
  }
  
  void draw() {
    for(UIButton i : buttons) i.draw();
  }
  
  void update() {
    buttons[curr_button].setValue(true);
    for(UIButton i : buttons) i.update();
    for(int i = 0; i < buttons.length; i++) {
      if(buttons[i].getValue() && i != curr_button) {
        buttons[curr_button].setValue(false);
        curr_button = i;
      }
    }
  }
  
  String getValue() {
    return buttons[curr_button].getId();
  }
  
  int getIndex() {
    return curr_button;
  }
  
  void setIndex(int i) {
    buttons[curr_button].setValue(false);
    curr_button = i;
    buttons[i].setValue(true);
  }
}

class UIToggleH extends UIBaseToggle {
  UIToggleH(PositionSpecifier ip, String ilabel, ColorScheme ic, String[] values) {
    super(ip, ilabel, ic);
    int len = values.length;
    buttons = new UIButton[len];
    for(int i = 0; i < len; i++) {    
      buttons[i] = new UIButton(ip, values[i], ic);
    }
    setIndex(0);
    setP(ip);
  }
  
  void setP(PositionSpecifier ip) {
    p = new PositionSpecifier(ip);
    PositionSpecifier pn = new PositionSpecifier(p.x, p.y, p.w/buttons.length, p.h);
    for(int i = 0; i < buttons.length; i++) {
      if(i == 0) pn.setFeather(new float[]{ip.feather[0], 0, 0, ip.feather[3]});
      else if(i == buttons.length - 1) pn.setFeather(new float[]{0, ip.feather[1], ip.feather[2], 0});
      else pn.setFeather(0);
      buttons[i].setP(pn);
      pn.x += pn.w;
    }
  }
}

class UIToggleV extends UIBaseToggle {
  UIToggleV(PositionSpecifier ip, String ilabel, ColorScheme ic, String[] values) {
    super(ip, ilabel, ic);
    int len = values.length;
    buttons = new UIButton[len];
    for(int i = 0; i < len; i++) {
      buttons[i] = new UIButton(ip, values[i], ic);
    }
    setIndex(0);
    setP(ip);
  }
  
  void setP(PositionSpecifier ip) {
    p = new PositionSpecifier(ip);
    PositionSpecifier pn = new PositionSpecifier(p.x, p.y, p.w, p.h/buttons.length);
    for(int i = 0; i < buttons.length; i++) {
      if(i == 0) pn.setFeather(new float[]{p.feather[0], p.feather[1], 0, 0});
      else if(i == buttons.length - 1) pn.setFeather(new float[]{0, 0, p.feather[2], p.feather[3]});
      else pn.setFeather(0);
      buttons[i].setP(pn);
      pn.y += pn.h;
    }
  }
}

class UITextBox extends UIElement {
  protected String value;
  protected String curr_value;
  protected boolean typing;
  protected String def_value;
  protected char lastkey = '\0';
  protected ColorScheme tbcs;
  protected UIButton button;
  protected int last_press;
  protected int cursor_time = 0;
  protected boolean key_repeat;
  protected int[] selection = new int[]{0,0};
  protected PositionSpecifier cp;
  public String suffix = "";
  
  UITextBox(PositionSpecifier ip, String ilabel, ColorScheme ic, String def) {
    super(ip, ilabel, ic);
    typing = false;
    value = "";
    def_value = def;
    curr_value = value;
    tbcs = new ColorScheme(ic.clicked, ic.clicked, ic.clicked, ic.clickedtext, ic.clickedtext);
    button = new UIButton(p, "", tbcs);
    cp = new PositionSpecifier(p.x + 12, p.y + p.h/4, 0.5, p.h/2);
  }
  
  void setColor(ColorScheme cs) {
    super.setColor(cs);
    tbcs = new ColorScheme(c.clicked, c.clicked, c.clicked, c.clickedtext, c.clickedtext);
    button.setColor(tbcs);
  }
  
  UITextBox(PositionSpecifier ip, String ilabel, ColorScheme ic) {
    this(ip, ilabel, ic, ilabel);
  }
  
  String getValue() {
    return value;
  }
  
  void setValue(String s) {
    value = s;
  }
  
  void setP(PositionSpecifier ip) {
    super.setP(ip);
    button.setP(ip);
    cp = new PositionSpecifier(p.x + 12, p.y + p.h/4, 0.5, p.h/2);
  }
  
  void draw() {
    button.draw();
    noStroke();
    String disp_text;
    if(typing) {
      p.makeRect(color(0,1), c.unclicked);
      fill(c.clickedtext);
      drawCursor();
      disp_text = curr_value;
    } else if(value == "") {
      fill(c.unclicked);
      disp_text = def_value;
    } else {
      fill(c.clickedtext);
      disp_text = value;
    }
    disp_text += suffix;
    dispText(disp_text);
  }
  
  void dispText(String disp_text) {
    float x;
    textSize(c.fontSize);
    noStroke();
    if(textWidth(disp_text) > p.w - 20) {
      textAlign(RIGHT);
      x = p.x + p.w - 10;
    } else {
      textAlign(LEFT);  
      x = p.x + 10;
    }
    while(textWidth(disp_text) > p.w - 20) {
      if(disp_text.length() == 0) break;
      disp_text = disp_text.substring(1, disp_text.length());
    }
    text(disp_text, x, p.center()[1] + c.fontSize/3);
  }
  
  void drawCursor() {
    if(millis() - cursor_time > 800) cursor_time = millis() + 200;
    else if(millis() - cursor_time > 400 || keyPressed) { 
      cp.x = p.x + 1.25 + min(p.w - 10, textWidth(curr_value) + 10);
      cp.makeRect(tbcs.text);
    }
  }
  
  protected void startTyping() {
    typing = true;
    curr_value = value;
  }
  
  protected void stopTyping() {
    typing = false;
    value = curr_value;
  }
  
  void update() {
    button.update();
    if(button.getValue() && !typing) startTyping();
    if(typing) {
      if(mousePressed && !p.mouseOver()) stopTyping();
      if(keyPressed) keyPressed();
      else lastkey = '\0';
    }
    button.setValue(typing);
  }
  
  protected void keyPressed() {
    if(key == lastkey) {
      if(key_repeat && millis() - last_press < 40) return;
      else if(!key_repeat && millis() -last_press < 750) return;
      key_repeat = true;
    } else key_repeat = false;
    lastkey = key;
    last_press = millis();
    if(key == ENTER || key == RETURN) {
      stopTyping();
    } else if(key == ESC) {
      typing = false;
    } else if(key == DELETE || key == BACKSPACE) {
      if(curr_value.length() == 0) return;
      curr_value = curr_value.substring(0, curr_value.length() - 1);
    } else if(key == CODED) {
      return;
    } else {
      curr_value += key;
    }
  }
}

class UIIncrementBox extends UIElement {
  UITextBox text_box;
  UIButton up;
  UIButton down;
  float value;
  float increment;
  
  UIIncrementBox(PositionSpecifier ip, String ilabel, ColorScheme ic, float idef, float iincrement) {
    super(ip, ilabel, ic);
    value = idef;
    increment = iincrement;
    text_box = new UITextBox(ip, "", ic);
    text_box.setValue(nf(idef, 0, 1));
    up = new UIMomentary(ip, "+", ic);
    down = new UIMomentary(ip, "-", ic);
    setP(ip);
  }
  
  float getValue() {
    return value;
  }
  
  void setValue(float newval) {
    value = newval;
    text_box.setValue(nf(value, 0, 1));
  }
  
  void setP(PositionSpecifier ip) {
    super.setP(ip);
    text_box.setP(ip);
    PositionSpecifier temp_p = new PositionSpecifier(p.x, p.y, p.w - 25, p.h, p.feather[0], 0, 0, p.feather[3]);
    text_box.setP(temp_p);
    temp_p.setFeather(new float[]{0,p.feather[1],0,0});
    temp_p.set_coords(p.x + p.w - 25, p.y, 25, p.h/2);
    up.setP(temp_p);
    temp_p.setFeather(new float[]{0,0,p.feather[1],0});
    temp_p.set_coords(temp_p.x, p.y + p.h/2, 25, p.h/2);
    down.setP(temp_p);
  }
  
  void setColor(ColorScheme cs) {
    super.setColor(cs);
    text_box.setColor(cs);
    up.setColor(cs);
    down.setColor(cs);
  }
  
  void setSuffix(String s) {
    text_box.suffix = s;
  }
  
  void draw() {
    up.draw();
    down.draw();
    text_box.draw();
  }
  
  void update() {
    text_box.update();
    try {
      value = Float.parseFloat(text_box.getValue());
    } catch(Exception e) {
    }
    up.update();
    down.update();
    if(up.getValue()) value += increment;
    if(down.getValue()) value -= increment;
    text_box.setValue(nf(value, 0, 0));
  }
}
