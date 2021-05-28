import processing.net.*;

GameClient gc;

OrderDevice od;

void setup() {
  surface.setSize(515,768);
  println("SETUP DONE");
  gc = new GameClient(this);
  setupFonts();
}

void draw() {
  clear();
  background(BLACK);
  gc.draw();
  gc.update();
}

void keyPressed() {
  gc.keyPressed(key);
  if(key == CODED && keyCode == LEFT) gc.mode = Mode.START;
  if(key == CODED && keyCode == RIGHT) gc.updateBaseWindow();
}
