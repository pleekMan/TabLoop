class TablaVirtual { //<>//

  PVector [] boundingBox; // topLeft y bottomRight points, in screenSpace. Should fit the camera image.
  PVector[] cornerPoints; // EVERYTHING NORMALIZED
  PVector[][] beatGrid; // [TRACK][STEP] NORMALIZED // Z COMPONENT IS USED TO AS BINARY ON/OFF
  PVector bezierMidPoint = new PVector(0.5, 0.5);
  //PVector gridOffset = new PVector(0.025,0.05);

  boolean calibrationMode = true;
  int selectedGridCorner = 0;
  int selectedBoxCorner = 0;
  boolean draggingGridCorner = false;
  boolean draggingBoxCorner = false;

  int atStep;

  public TablaVirtual() {

    int tracks = 10;
    int steps = 16;

    boundingBox = new PVector[2];
    cornerPoints = new PVector[4];
    beatGrid = new PVector[tracks][steps];

    boundingBox[0] = new PVector(0, 0 );
    boundingBox[1] = new PVector(640, 480);
    boundingBox[0].add(20, 20, 0);
    boundingBox[1].add(20, 20, 0);

    cornerPoints[0] = new PVector(0.1, 0.1);
    cornerPoints[1] = new PVector(0.9, 0.1);
    cornerPoints[2] = new PVector(0.9, 0.9);
    cornerPoints[3] = new PVector(0.1, 0.9);

    //cornerPoints[0] = new PVector(0.1, 0.1);
    //cornerPoints[1] = new PVector(0.9, 0.1);
    //cornerPoints[2] = new PVector(0.9, 0.9);
    //cornerPoints[3] = new PVector(0.1, 0.9);

    ordenarBeatGrid();


    atStep = 0;
  }

  public void update() {

    if (draggingGridCorner) {
      // CONSTRAINING mouse MOTION TO boundingBox, BEFORE CONVERTING TO BBOX NORMALIZED
      PVector screenPoint = new PVector(constrain(mouseX, boundingBox[0].x, boundingBox[1].x), constrain(mouseY, boundingBox[0].y, boundingBox[1].y));
      cornerPoints[selectedGridCorner].set(fitToBoundingBoxNormalized(screenPoint));
      ordenarBeatGrid();
    }

    if (draggingBoxCorner) {
      boundingBox[selectedBoxCorner].set(mouseX, mouseY);
      ordenarBeatGrid();
    }

  }


  public void render() {


    if (calibrationMode) {

      // DIBUJAR BOUNDING BOX
      stroke(255, 0, 255);
      rect(boundingBox[0].x, boundingBox[0].y, boundingBox[1].x - boundingBox[0].x, boundingBox[1].y - boundingBox[0].y);

      // DIBUJAR PUNTOS EN GRILLA
      noStroke();
      for (int track=0; track < beatGrid.length; track++) {
        for (int step=0; step < beatGrid[0].length; step++) {

          PVector pointInScreen = fitToBoundingBoxScreen(beatGrid[track][step]);
          
          // gridPoints COLOR
          fill(colorearPuntos(track, step));
          ellipse(pointInScreen.x, pointInScreen.y, 5, 5);

          // gridPoints BEAT ON
          if (beatGrid[track][step].z >= 0.1) {
            fill(0, 255, 0);
            ellipse(pointInScreen.x, pointInScreen.y, 10, 10);
          }
          
          // DIBUJAR PIXEL KERNEL
          
        }
      }

      // DIBUJAR CORNER GIZMOS
      dibujarCornerGizmos();
    }
  }



  void ordenarBeatGrid() {

    // for each (Track for each (step))
    for (int track=0; track < beatGrid.length; track++) {

      float normalizedTrackNumber = float(track) /  (beatGrid.length - 1);
      PVector trackLeft = PVector.lerp(cornerPoints[0], cornerPoints[3], normalizedTrackNumber);
      PVector trackRight = PVector.lerp(cornerPoints[1], cornerPoints[2], normalizedTrackNumber);

      for (int step=0; step < beatGrid[0].length; step++) {
        float normalizedStepNumber = float(step) /  (beatGrid[0].length - 1);

        PVector stepPos = new PVector();// = PVector.lerp(trackLeft, trackRight, normalizedStepNumber);

        // ECUACION PARA UNA CURVA BEZIER CUADRATICA (1 PUNTO DE CONTROL + 2 VERTICES)
        stepPos.x = (pow(1-normalizedStepNumber, 2) * trackLeft.x) + (2*(1-normalizedStepNumber)*normalizedStepNumber*bezierMidPoint.x) + ((normalizedStepNumber*normalizedStepNumber) * trackRight.x);
        stepPos.y = lerp(trackLeft.y, trackRight.y, stepPos.x);

        beatGrid[track][step] = stepPos;
      }
    }
  }



  public boolean detectarTocarEsquinasGrid(float x, float y) {

    for (int i=0; i < cornerPoints.length; i++) {
      // MAP FUNCTION ALSO EXTRAPOLATES (VALUES OUTSIDE RANGES WILL GIVE CORRECT RESULTS)
      PVector pointInScreen = fitToBoundingBoxScreen(cornerPoints[i]); 
      if ( dist(x, y, pointInScreen.x, pointInScreen.y) < 10 ) {
        selectedGridCorner = i;
        draggingGridCorner = true;
        println("Click on CornerPoint: " + i);
        return true;
      }
    }
    return false;
  }

  public boolean detectarTocarEsquinasBox(float x, float y) {

    for (int i=0; i < boundingBox.length; i++) {
      // MAP FUNCTION ALSO EXTRAPOLATES (VALUES OUTSIDE RANGES WILL GIVE CORRECT RESULTS)
      if ( dist(x, y, boundingBox[i].x, boundingBox[i].y) < 10 ) {
        selectedBoxCorner = i;
        draggingBoxCorner = true;
        println("Click on BoxPoint: " + i);
        return true;
      }
    }
    return false;
  }

  private PVector fitToBoundingBoxScreen(PVector point) {
    // FROM BOUNDING BOX NORMAL SPACE -> SCREEN PIXEL SPACE
    float x = map(point.x, 0, 1, boundingBox[0].x, boundingBox[1].x);
    float y = map(point.y, 0, 1, boundingBox[0].y, boundingBox[1].y);
    return new PVector(x, y);
  }

  private PVector fitToBoundingBoxNormalized(PVector point) {
    // FROM SCREEN PIXEL SPACE -> BOUNDING BOX NORMAL SPACE
    float x = map(point.x, boundingBox[0].x, boundingBox[1].x, 0, 1);
    float y = map(point.y, boundingBox[0].y, boundingBox[1].y, 0, 1);
    return new PVector(x, y);
  }

  private void dibujarCornerGizmos() {

    noFill();
    stroke(0, 255, 255);

    // GRID CORNERS
    float[][] vizCorners = new float[4][2];
    for (int i=0; i < vizCorners.length; i++) {
      vizCorners[i][0] = map(cornerPoints[i].x, 0, 1, boundingBox[0].x, boundingBox[1].x);
      vizCorners[i][1] = map(cornerPoints[i].y, 0, 1, boundingBox[0].y, boundingBox[1].y);

      ellipse(vizCorners[i][0], vizCorners[i][1], 15, 15);
    }

    // BOUNDING BOX CORNERS
    stroke(0, 200, 255);
    ellipse(boundingBox[0].x, boundingBox[0].y, 15, 15);
    ellipse(boundingBox[1].x, boundingBox[1].y, 15, 15);
  }


  private color colorearPuntos(int track, int step) {

    // CORNER POINTS SON ROJOS. TODO LO DEMAS, BLANCO
    
    if ((track == 0 && step ==0) || (track == beatGrid.length - 1 && step ==0) || (track == 0 &&  step == beatGrid[0].length - 1) || (track == beatGrid.length - 1 && step == beatGrid[0].length - 1)) {
      return color (255, 0, 0);
    } else {
      return color (255, 255, 0);
    }
  }


  private PVector getBoundingBoxSize() {
    return new PVector(boundingBox[1].x - boundingBox[0].x, boundingBox[1].y - boundingBox[0].y);
  }

  PVector[][] getGridPoints() {
    return beatGrid;
  }



  // SYSTEM INPUT EVENTS -----------------

  public void onMousePressed() {

    tabla.detectarTocarEsquinasGrid(mouseX, mouseY);
    tabla.detectarTocarEsquinasBox(mouseX, mouseY);
  }

  public void onMouseReleased() {
    draggingGridCorner = false;
    draggingBoxCorner = false;
  }
}
