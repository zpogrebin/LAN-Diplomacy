//GENERIC SUPERCLASS
class UIElement {
  protected PositionSpecifier p;
  protected String label;
  protected ColorScheme c;
  UIElement next;
  boolean active;
  boolean justActivated;
  
  UIElement(PositionSpecifier ip, String ilabel, ColorScheme ic) {
    p = new PositionSpecifier (ip);
    label = ilabel;
    c = ic;
  }
  
  void setNext(UIElement next) {
    this.next = next;
  }
  
  void keyPressed(char k) {
    if(active && !justActivated && k == TAB) activateNext();
  }
  
  void activateNext() {
    if(next != null) next.activate();
    this.deactivate();
  }
  
  void draw() {
    ;
  }
  
  void activate() {
    this.active = true;
    this.justActivated = true;
  }
  
  void deactivate() {
    this.active = false;
    this.justActivated = true;
  }
  
  void update() {
    justActivated = false;
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
    justActivated = false;
    if(p.mouseOver()) hover = true;
    else hover = false;
    if(mousePressed && p.mouseOver()) {
      if(!mouseclicking) {
        value = !value;
        mouseclicking = true;
      }
    } else mouseclicking = false;
  }
  
  void keyPressed(char k) {
    if(!active) return;
    if(k == TAB && !justActivated) activateNext();
    else if(k == ' ') setValue(!getValue());
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
  
  void keyPressed(char k) {
    if(!active) return;
    if(k == TAB && !justActivated) activateNext();
    else if(k == ' ') setValue(true);
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
    justActivated = false;
    buttons[curr_button].setValue(true);
    for(UIButton i : buttons) i.update();
    for(int i = 0; i < buttons.length; i++) {
      if(buttons[i].getValue() && i != curr_button) {
        buttons[curr_button].setValue(false);
        curr_button = i;
      }
    }
  }
  
  void keyPressed(char k) {
    if(!active) return;
    if(k == TAB && !justActivated) activateNext();
    else if(k == ' ') setIndex(getIndex() + 1);
    else if(k - 30 >= 0 && k - 30 < 40) setIndex(Integer.valueOf(k));
  }
  
  String getValue() {
    return buttons[curr_button].getId();
  }
  
  int getIndex() {
    return curr_button;
  }
  
  void setIndex(int i) {
    buttons[curr_button].setValue(false);
    curr_button = i % buttons.length;
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
  protected String def_value;
  protected char lastkey = '\0';
  protected ColorScheme tbcs;
  protected UIButton button;
  protected int last_press;
  protected int cursor_time = 0;
  protected boolean key_handled;
  protected int[] selection = new int[]{0,0};
  protected PositionSpecifier cp;
  public String suffix = "";
  
  UITextBox(PositionSpecifier ip, String ilabel, ColorScheme ic, String def) {
    super(ip, ilabel, ic);
    active = false;
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
    if(active) {
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
    if(millis() - cursor_time > 800) cursor_time = millis();
    else if(millis() - cursor_time > 400 || keyPressed) {
      textSize(c.fontSize);
      cp.x = p.x + 1.25 + min(p.w - 10, textWidth(curr_value) + 10);
      cp.makeRect(tbcs.text);
    }
  }
  
  protected void startTyping() {
    active = true;
    curr_value = value;
    button.setValue(true);
  }
  
  protected void stopTyping() {
    active = false;
    value = curr_value;
    button.setValue(false);
  }
  
  void activate() {startTyping();}
  void deactivate() {stopTyping();}
  
  void update() {
    justActivated = false;
    button.update();
    if(button.getValue() && !active) startTyping();
    if(active) {
      if(mousePressed && !p.mouseOver()) stopTyping();
    }
    button.setValue(active);
  }
  
  void keyPressed(char k) {
    if(!active) return;
    if(k == TAB && !justActivated) activateNext();
    else if(k == ENTER || k == RETURN) {
      stopTyping();
    } else if(k == ESC) {
      active = false;
    } else if (k == CODED) {
      return;
    } else if(k == DELETE || k == BACKSPACE) {
      if(curr_value.length() == 0) return;
      curr_value = curr_value.substring(0, curr_value.length() - 1);
    } else {
      curr_value += k;
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
    justActivated = false;
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
  
  void activate() {
    this.active = true;
    text_box.activate();
  }
  
  void deactivate() {
    this.active = false;
    text_box.deactivate();
  }
  
  void keyPressed(char k) {
    if(!active || justActivated) return;
    text_box.keyPressed(k);
  }
}

class UIDropDown extends UIElement {
  
  private ArrayList<UIMomentary> buttons;
  private int selected = -1;
  private ColorScheme altcs;
  private boolean open;
  private boolean justClosed;
  
  UIDropDown(PositionSpecifier p, String name, ColorScheme cs, String[] values, String curr) {
    super(p, name, cs);
    altcs = new ColorScheme(cs.clicked, cs.highlight, cs.unclicked, cs.clickedtext, cs.text);
    buttons = new ArrayList<UIMomentary>();
    for(int i = 0; i < values.length; i++) {
      buttons.add(new UIMomentary(p, values[i], cs));
      if(values[i].equals(curr)) setClosed(i);
    }
    if(selected < 0) setClosed(0);
    justClosed = false;
  }
  
  UIDropDown(PositionSpecifier p, String name, ColorScheme cs, String[] values) {
    super(p, name, cs);
    altcs = new ColorScheme(cs.clicked, cs.highlight, cs.unclicked, cs.clickedtext, cs.text);
    buttons = new ArrayList<UIMomentary>();
    for(int i = 1; i < values.length; i++) {
      buttons.add(new UIMomentary(p, values[i], cs));
      if(values[i].equals(values[0])) setClosed(i-1);
    }
    if(selected < 0) setClosed(0);
    justClosed = false;
  }
  
  private void setClosed(int selected) {
    buttons.get(selected).c = c;
    this.selected = selected;
    open = false;
    p.set_coords(p.x, p.y, getWidth(),p.h);
    buttons.get(selected).setP(p);
    justClosed = true;
  }
  
  private void setOpen() {
    open = true;
    PositionSpecifier newP = new PositionSpecifier(0,0,0,0);
    p.set_coords(p.x,p.y,getWidth(),p.h);
    for(UIMomentary button: buttons) {
      newP.set_coords(p.x,p.y+p.h*(buttons.indexOf(button)-selected),p.w, p.h);
      button.setP(newP);
    }
    buttons.get(selected).c = altcs;
  }
  
  String getValue() {
    return buttons.get(selected).label;
  }
  
  float getWidth() {
    if(open) return getMaxWidth()+10;
    else return 10+textWidth(buttons.get(selected).label);
  }
  
  float getMaxWidth() {
    float max = 0;
    float curr;
    for(UIMomentary button: buttons) {
      curr = textWidth(button.label);
      if(curr > max) max = curr;
    }
    return max;
  }
  
  void update() {
    justActivated = false;
    if(!open) {
      buttons.get(selected).p = p;
      buttons.get(selected).update();
      if(buttons.get(selected).getValue()) setOpen();
    } else {
      for(UIMomentary button : buttons) button.update();
      if(mousePressed) {
        boolean outside = mouseY < p.y-p.h*selected;
        outside |= mouseY > p.y+p.h*(buttons.size()-selected);
        outside |= mouseX < p.x || mouseX > p.x+p.w;
        if(outside) setClosed(selected);
      }
      for(int i = 0; i < buttons.size(); i++) {
        if(buttons.get(i).getValue()) setClosed(i);
      }
    }
  }
  
  PositionSpecifier updateC(PositionSpecifier activePos) {
    if(activePos == null) update();
    else if(!activePos.mouseOver() || open) update();
    if(open) activePos = getP();
    if(justClosed) activePos = null;
    return activePos;
  }
  
  PositionSpecifier getP() {
    float y = p.y-p.h*selected;
    float h = p.h*buttons.size();
    return new PositionSpecifier(p.x, y, getWidth(), h);
  }
  
  boolean justClosed() {
    if(justClosed) {
      justClosed = false;
      return true;
    }
    return false;
  }
  
  void draw() {
    float w = getWidth();
    for(UIMomentary button: buttons) {
      button.p.w = w;
    }
    if(!open) {
      buttons.get(selected).draw();
    } else {
      for(UIMomentary button : buttons) button.draw();
    }
  }
}

class UISentence extends UIElement {
  
  ArrayList<Object> objects;

  UISentence(PositionSpecifier p, String label, ColorScheme cs, String setString) {
    super(p, label, cs);
    setByString(setString);  }
  
  void setByString(String str) {
    String[] sections = str.split("\\|");
    objects = new ArrayList<Object>();
    for(String sec : sections) {
      if(sec.length() < 3) continue;
      if(sec.charAt(0) == '@') {
        sec = sec.substring(1,sec.length());
        objects.add(new UIDropDown(p, sec, c, sec.split(": ")));
      } else {
        objects.add(sec);
      }
    }
  }
  
  void draw() {
    float x = p.x;
    for(Object object : objects) {
      if(object instanceof UIDropDown) {
        ((UIDropDown)object).p.x = x;
        ((UIDropDown)object).draw();
        x += ((UIDropDown)object).getWidth();
      } else if(object instanceof String) {
        fill(LIGHT);
        textAlign(LEFT);
        text((String)object,x,p.center()[1] + c.fontSize/3);
        x += textWidth((String)object);
      }
    }
  }
  
  void update() {
    justActivated = false;
    for(Object object : objects) {
      if(object instanceof UIElement) {
        ((UIElement)object).update();
      }
    }
  }
  
  PositionSpecifier updateC(PositionSpecifier p) {
    for(Object object : objects) {
      if(object instanceof UIDropDown) {
        p = ((UIDropDown)object).updateC(p);
      }
    }
    return p;
  }
  
  String getValue() {
    String str = "";
    for(Object object : objects) {
      if(object instanceof UIDropDown) {
        str = String.join(" ", str, ((UIDropDown)object).getValue().replace(" ","_"));
      }
    }
    return trim(str);
  }
  
  boolean didChange() {
    for(Object object : objects) {
      if(object instanceof UIDropDown) {
        if(((UIDropDown)object).justClosed()) return true;
      }
    } return false;
  }
}
