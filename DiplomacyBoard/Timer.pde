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
  
  String getStringSeparated() {
    String ret = "";
    String[] seq = getTimeSequenceStrings();
    boolean started = false;
    for(int i = 0; i < seq.length; i++) {
      ret += seq[i] + VALS[i] + " ";
    }
    return ret;
  }
  
  void setByColonSeparated(String input, int offset) {
    String[] sSeq = input.split(":");
    int[] iSeq = new int[sSeq.length];
    int[] timeSeq = new int[] {PERHUN, PERSEC, PERMIN, PERHOUR, PERDAY};
    for(int i = 0; i < iSeq.length; i++) iSeq[i] = Integer.valueOf(sSeq[i]);
    f
  }
}
