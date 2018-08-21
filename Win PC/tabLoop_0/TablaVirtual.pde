class TablaVirtual { //<>//

  PVector [] boundingBox; // topLeft y bottomRight points, in screenSpace. Should fit the camera image.
  PVector[] cornerPoints; // EVERYTHING NORMALIZED
  PVector[][] beatGrid; // [TRACK][STEP] NORMALIZED // Z COMPONENT IS USED TO AS BINARY ON/OFF
  PVector[][] beatGridOffsets; // FOR INDIVIDUAL POINT OFFSETTING
  PVector bezierMidPoint = new PVector(0.5, 0.5); // 0 -> 1
  //PVector gridOffset = new PVector(0.025,0.05);

  boolean calibrationMode = true;
  int selectedGridCorner = 0;
  int selectedBoxCorner = 0;
  int[] selectedPoint = {-1, -1};
  boolean draggingGridCorner = false;
  boolean draggingBoxCorner = false;
  boolean draggingPoints = false;

  int atStep;
  int bpm;

  int kernelSize = 9; // ONLY FOR VISUALIZATION PURPOSES

  public TablaVirtual() {

    int tracks = 10;
    int steps = 16;

    boundingBox = new PVector[2];
    cornerPoints = new PVector[4];
    beatGrid = new PVector[tracks][steps];
    beatGridOffsets = new PVector[tracks][steps];

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


    initPointsOffsets();
    ordenarBeatGrid();


    atStep = 0;
  }

  public void update() {
    
    // AVANZAR TIEMPO (HACER LA LOGICA DE BPM, BIEN)
    if(frameCount % 30 == 0){
     atStep = (atStep + 1) % beatGrid[0].length; 
     //println("-|| atStep: " + atStep);
    }

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

    // if (draggingPoints)
    // EL CALCULO DE OFFSETS SE HACE EN mouseReleased
    //
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

          // ADD INDIVIDUAL POINTS OFFSETING
          PVector offsetedPoint = PVector.add(beatGrid[track][step], beatGridOffsets[track][step]);
          PVector pointInScreen = fitToBoundingBoxScreen(offsetedPoint);

          // gridPoints COLOR
          noStroke();
          fill(colorearPuntos(track, step));
          ellipse(pointInScreen.x, pointInScreen.y, 3, 3);

          // gridPoints BEAT ON
          if (beatGrid[track][step].z >= 0.1) {
            fill(0, 255, 0);
            ellipse(pointInScreen.x, pointInScreen.y, 7, 7);
          }

          // DIBUJAR PIXEL KERNEL
          if (kernelSize != 1) {
            noFill();
            stroke(255, 125, 0);
            int rectOffset = floor(kernelSize * 0.5);
            rect(pointInScreen.x - rectOffset, pointInScreen.y - rectOffset, kernelSize, kernelSize);
          }
        }
      }

      // DIBUJAR CORNER GIZMOS
      dibujarCornerGizmos();

      // DIBUJAR POINTS CROSSHAIR
      // EL CALCULO DE OFFSETS SE HACE EN mouseReleased
      if (draggingPoints) {
        stroke(255, 0, 0);
        line(mouseX, mouseY - 10, mouseX, mouseY - 3);
        line(mouseX, mouseY + 3, mouseX, mouseY + 10);

        line(mouseX - 10, mouseY, mouseX - 3, mouseY );
        line(mouseX + 3, mouseY, mouseX + 10, mouseY );
      }
    }
  }

  private void initPointsOffsets() {
    for (int track=0; track < beatGridOffsets.length; track++) {
      for (int step=0; step < beatGridOffsets[0].length; step++) {
        beatGridOffsets[track][step] = new PVector(0, 0);
      }
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

  public boolean detectarTocarPoints(float x, float y) {

    if ( !draggingGridCorner) {
      for (int track=0; track < beatGrid.length; track++) {
        for (int step=0; step < beatGrid[0].length; step++) {
          // MAP FUNCTION ALSO EXTRAPOLATES (VALUES OUTSIDE RANGES WILL GIVE CORRECT RESULTS)
          PVector offsetedPoint = PVector.add(beatGrid[track][step], beatGridOffsets[track][step]);
          PVector pointInScreen = fitToBoundingBoxScreen(offsetedPoint); 
          if ( dist(x, y, pointInScreen.x, pointInScreen.y) < 10 ) {
            selectedPoint[0] = track;
            selectedPoint[1] = step;
            draggingPoints = true;
            println("Click on Track: " + selectedPoint[0] + " | Step: " + selectedPoint[1]);
            return true;
          }
        }
      }
    }
    return false;
  }

  private PVector fitToBoundingBoxScreen(PVector point) {
    // FROM BOUNDING BOX NORMAL SPACE -> SCREEN PIXEL SPACE
    // MAP FUNCTION ALSO EXTRAPOLATES (VALUES OUTSIDE RANGES WILL GIVE CORRECT RESULTS)
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
    // ADD OFFSET BEFORE SENDING THEM OUT;
    PVector [][] finalOffsetedPoints = new PVector[beatGrid.length][beatGrid[0].length];
    for (int track=0; track < finalOffsetedPoints.length; track++) {
      for (int step=0; step < finalOffsetedPoints[0].length; step++) {
        finalOffsetedPoints[track][step] = PVector.add(beatGrid[track][step], beatGridOffsets[track][step]);
        //println(beatGrid[track][step].y + " \t\t " + finalOffsetedPoints[track][step].y);
      }
    }
    return finalOffsetedPoints;
  }

  public PVector[][] getGridPointOffsets() {
    return beatGridOffsets;
  }

  public void setGridPointState(int track, int step, boolean state) {
    beatGrid[track][step].z =  state ? 1 : 0;
  }

  float getPerspectiveCorrection() {
    return bezierMidPoint.x;
  }

  public void resetPointsOffset() {
    for (int track=0; track < beatGridOffsets.length; track++) {
      for (int step=0; step < beatGridOffsets[0].length; step++) {
        beatGridOffsets[track][step].set(0,0);
      }
    }
  }

  public void loadSettings(SettingsLoader config) {
    try {
      boundingBox = config.loadBoundingBox();
      cornerPoints = config.loadCornerPoints();
      beatGridOffsets = config.loadPointOffset(beatGrid.length, beatGrid[0].length);

      bezierMidPoint.x = map(config.loadPerspectiveCorrection(), -1, 1, 0, 1);
    } 
    catch (Exception error) {
      println(error);
    }
    ordenarBeatGrid();
  }



  // SYSTEM INPUT EVENTS -----------------

  public void onMousePressed(int mX, int mY) {

    detectarTocarEsquinasGrid(mX, mY);
    detectarTocarEsquinasBox(mX, mY);
    detectarTocarPoints(mX, mY);
  }

  public void onMouseReleased(int mX, int mY) {
    draggingGridCorner = false;
    draggingBoxCorner = false;

    if (draggingPoints) {

      int selectedTrack = selectedPoint[0];
      int selectedStep = selectedPoint[1];

      PVector newPosition = fitToBoundingBoxNormalized(new PVector(mX, mY));
      PVector offset = newPosition.sub(beatGrid[selectedTrack][selectedStep]);

      //PVector offset = beatGrid[selectedPoint[0]][selectedPoint[1]].sub(newPosition);
      beatGridOffsets[selectedPoint[0]][selectedPoint[1]].set(offset);
      //beatGrid[selectedPoint[0]][selectedPoint[1]].set(newPosition);

      ordenarBeatGrid();
      draggingPoints = false;
    }
  }

  public void onMouseDragged(int mX, int mY) {
    if (draggingPoints) {
      noCursor();
    }
  }
}
