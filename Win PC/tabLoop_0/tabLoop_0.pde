
TablaVirtual tabla;

void setup() {
  size(700, 500);
  tabla = new TablaVirtual();
}


void draw() {
  background(0);

  
  //tabla.stepDeformCoeficiente = map(mouseX, 0, width, 0, 2);
  tabla.midPoint.set((float)mouseX / width, (float)mouseY / height);
  tabla.ordenarTrackSteps();
  
  tabla.update();
  tabla.render();
  
  text(tabla.stepDeformCoeficiente, 10,10);
}


void mousePressed() {
  tabla.detectarTocarEsquinas(mouseX, mouseY);
}

void mouseReleased() {
  tabla.draggingCorner = false;
}

void keyPressed() {
  if (keyCode == DOWN) {
    tabla.stepDeformCoeficiente -= 0.1;
  }
  if (keyCode == UP) {
    tabla.stepDeformCoeficiente += 0.1;
  }
  println(tabla.stepDeformCoeficiente);
   tabla.detectarTocarEsquinas(mouseX, mouseY);
}