
TablaVirtual tabla;

void setup() {
  size(700, 500);
  tabla = new TablaVirtual();
}


void draw() {
  background(0);

  tabla.update();
  tabla.render();
}


void mousePressed() {
  tabla.detectarTocarEsquinas(mouseX, mouseY);
}

void mouseReleased() {
  tabla.draggingCorner = false;
}

void keyPressed() {
  if (keyCode == DOWN) {
    tabla.stepDeformCoeficiente.x -= 0.1;
  }
  if (keyCode == UP) {
    tabla.stepDeformCoeficiente.x += 0.1;
  }
  println(tabla.stepDeformCoeficiente.x);
   tabla.detectarTocarEsquinas(mouseX, mouseY);
}
