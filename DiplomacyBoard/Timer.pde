class Timer {
  
  private int currTime;
  private int maxTime;
  private int lastMillis;
  private boolean active;
  private boolean wrap;
  private final String[] VALS = new String[]{"d", "h", "m", "s", ""};
  private final int PERSEC = 1000;
  private final int PERHUN = 10;
  private final int PERMIN = PERSEC * 60;
  private final int PERHOUR = PERMIN * 60;
  private final int PERDAY = PERHOUR * 24;
  
  Timer(int time) {
    maxTime = time;
    stop();
  }
  
  boolean update() {
    if(!active) return false;
    int deltaT = millis() - lastMillis;
    lastMillis = millis();
    currTime -= deltaT;
    if(currTime < 0) {
      if(wrap) currTime += maxTime;
      else stop();
      return true;
    } 
    return false;
  }
  
  void start() {
    active = true;
    lastMillis = millis();
  }
  
  void stop() {
    active = false;
    currTime = maxTime;
  }
  
  void pause() {
    active = false;
  }
  
  void set(int time) {
    maxTime = time;
  }
  
  void setAndStart(int time) {
    set(time);
    start();
  }
  
  int getTime() {
    return currTime;
  }
  
  int getHundredths(int millis) {return (millis/PERHUN % 100);}
  int getSeconds(int millis) {return (millis/PERSEC % 60);}
  int getMinutes(int millis) {return (millis/PERMIN % 60);}
  int getHours(int millis) {return (millis/PERHOUR % 60);}
  int getDays(int millis) {return (millis/PERDAY % 24);}
  int getHundredths() {return getHundredths(currTime);}
  int getSeconds() {return getSeconds(currTime);}
  int getMinutes() {return getMinutes(currTime);}
  int getHours() {return getHours(currTime);}
  int getDays() {return getDays(currTime);}
  int[] getTimeSequence() {return getTimeSequence(currTime);}
  
  String[] getTimeSequenceStrings() {
    int iSeq[] = getTimeSequence();
    String nSeq[] = new String[iSeq.length];
    for(int i = 0; i < iSeq.length; i++) nSeq[i] = String.valueOf(iSeq[i]);
    return nSeq;
  }
  
  int[] getTimeSequence(int millis) {
    return new int[] {
      getHundredths(millis),
      getSeconds(millis),
      getMinutes(millis),
      getHours(millis),
      getDays(millis)
    };
  }
  
  String getColonSeparated() {
    return String.join(":", getTimeSequenceStrings());
  }
  
  String getColonSeparated(int sigfigs) {
    int[] iSeq = getTimeSequence();
    ArrayList<String> sSeq = new ArrayList<String>();
    int j = 0;
    for(int i = 0; i < iSeq.length; i++) {
      if(j == 0 && iSeq[i] == 0) continue;
      if(j == sigfigs) break;
      j++;
      sSeq.add(String.format("%02d", String.valueOf(iSeq[i])));
    }
    while(sSeq.size() < sigfigs) sSeq.add("00");
    return String.join(":", sSeq);
  }
  
  String getStringSeparated() {
    String ret = "";
    boolean started = false;
    String[] seq = getTimeSequenceStrings();
    for(int i = 0; i < seq.length; i++) {
      if(!started && Integer.valueOf(seq[i]) == 0) continue;
      started = true;
      ret += seq[i] + VALS[i] + " ";
    }
    return ret;
  }
  
  void setByHMS(int hours, int minutes, int seconds) {
    set(hours * PERHOUR + minutes * PERMIN + seconds * PERSEC);
  }
}

class UITimer extends UIElement {
  
  UIIncrementBox hours;
  UIIncrementBox minutes;
  Timer t;
  
  UITimer(PositionSpecifier p, String label, ColorScheme cs, int dHours, int dMinutes) {
    this(p, label, cs, dHours, dMinutes, 1, 1);
  }
  
  UITimer(PositionSpecifier p, String label, ColorScheme cs, int dHours, int dMinutes, int hInc, int mInc) {
    super(p, label, cs);
    p.set_coords(p.x, p.y, p.w/2, p.h);
    hours = new UIIncrementBox(p, "hours", cs, dHours, hInc);
    p.set_coords(p.x + p.w, p.y, p.w, p.h);
    minutes = new UIIncrementBox(p, "minutes", cs, dMinutes, mInc);
    t = new Timer(0);
  }
  
  void setTime() {
    t.setByHMS(
      (int)hours.getValue(),
      (int)minutes.getValue(),
      0
    );
  }
  
  void update() {
    hours.update();
    minutes.update();
    if(minutes.getValue() < 0) {
      minutes.setValue(0);
      hours.setValue(hours.getValue() - 1);
    }
    if(hours.getValue() < 0) hours.setValue(0);
    if(minutes.getValue() >= 60) {
      minutes.setValue(minutes.getValue() - 60);
      hours.setValue(hours.getValue() + 1);
    }
    setTime();
  }
  
  void draw() {
    hours.draw();
    minutes.draw();
  }
  
  void keyPressed(char k) {
    hours.keyPressed(k);
    minutes.keyPressed(k);
  }
  
}
