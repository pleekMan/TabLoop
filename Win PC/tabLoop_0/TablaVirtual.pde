class TablaVirtual { //<>//

  PVector [] boundingBox; // topLeft y bottomRight points, in screenSpace. Should fit the camera image.
  PVector[] cornerPoints; // EVERYTHING NORMALIZED
  PVector[][] beatGrid; // [TRACK][STEP] NORMALIZED // Z COMPONENT IS USED TO AS BINARY ON/OFF
  PVector[][] beatGridOffsets; // FOR INDIVIDUAL POINT OFFSETTING
  float [] stepwiseOffset; // FOR OFFSETING BY STEP FORWARD/BACKWARDS
  PVector[] stepGizmoPos; // GIZMO / HANDLE TO DRAG THE stepwiseOfset
  PVector bezierMidPoint = new PVector(0.5, 0.5); // 0 -> 1, FOR QUAD BEZIER-BASED PERSPECTIVE

  boolean calibrationMode = true;
  int selectedBoxCorner = 0;
  int selectedGridCorner = 0;
  int selectedStepGizmo = 0;
  int[] selectedPoint = {-1, -1};
  boolean draggingGridCorner = false;
  boolean draggingBoxCorner = false;
  boolean draggingSteps = false;
  boolean draggingPoints = false;

  int atStep;
  int bpm;

  int kernelSize = 9; // ONLY FOR VISUALIZATION PURPOSES (mmhh not really..!)

  public TablaVirtual() {

    int tracks = 10;
    int steps = 16;

    boundingBox = new PVector[2];
    cornerPoints = new PVector[4];
    beatGrid = new PVector[tracks][steps];
    beatGridOffsets = new PVector[tracks][steps];
    stepwiseOffset = new float[steps];
    stepGizmoPos = new PVector[steps];

    boundingBox[0] = new PVector(0, 0 );
    boundingBox[1] = new PVector(640, 480);
    boundingBox[0].add(20, 20, 0);
    boundingBox[1].add(20, 20, 0);

    cornerPoints[0] = new PVector(0.1, 0.1);
    cornerPoints[1] = new PVector(0.9, 0.1);
    cornerPoints[2] = new PVector(0.9, 0.9);
    cornerPoints[3] = new PVector(0.1, 0.9);


    initPointsOffsets();
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

    if (draggingSteps) {

      float offset = fitToBoundingBoxNormalized(new PVector(mouseX, mouseY)).x - beatGrid[0][selectedStepGizmo].x;
      stepwiseOffset[selectedStepGizmo] = offset;
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

          // DIBUJAR stepGizmos
          if (track == 0) {
            stroke(colorPalette.HIGHLIGHT_RED);
            if (step == selectedStepGizmo) {
              fill(colorPalette.HIGHLIGHT_RED);
            } else {
              noFill();
            }
            rect(stepGizmoPos[step].x - 5, stepGizmoPos[step].y - 5, 10, 10);
            line(stepGizmoPos[step].x, stepGizmoPos[step].y + 5, pointInScreen.x, pointInScreen.y - 10);
          }
        }
      }

      // DIBUJAR CORNER GIZMOS
      dibujarCornerGizmos();

      // DIBUJAR PLAYHEAD
      dibujarPlayHead();


      // DIBUJAR POINTS CROSSHAIR
      // EL CALCULO DE OFFSETS SE HACE EN mouseReleased
      if (draggingPoints) {
        stroke(255, 0, 0);
        line(mouseX, mouseY - 10, mouseX, mouseY - 3);
        line(mouseX, mouseY + 3, mouseX, mouseY + 10);

        line(mouseX - 10, mouseY, mouseX - 3, mouseY );
        line(mouseX + 3, mouseY, mouseX + 10, mouseY );
      }

      // DRAW MINI-SEQUENCER AT TEMPO MENU
      drawMiniSequencer();
    }
  }

  public void stepTime() {
    atStep = (atStep + 1) % beatGrid[0].length; 
    //println("-|| atStep: " + atStep);
  }

  private void initPointsOffsets() {
    for (int track=0; track < beatGridOffsets.length; track++) {
      for (int step=0; step < beatGridOffsets[0].length; step++) {

        // INDIVIDUAL POINTS OFFSET
        beatGridOffsets[track][step] = new PVector(0, 0);

        // PER-STEP OFFSET
        stepwiseOffset[step] = 0;
        stepGizmoPos[step] = new PVector();
      }
    }
  }

  public int getAtBeat() {
    return atStep;
  }

  void ordenarBeatGrid() {

    // for each (Track for each (step))
    for (int track=0; track < beatGrid.length; track++) {

      float normalizedTrackNumber = float(track) /  (beatGrid.length - 1);
      PVector trackLeft = PVector.lerp(cornerPoints[0], cornerPoints[3], normalizedTrackNumber);
      PVector trackRight = PVector.lerp(cornerPoints[1], cornerPoints[2], normalizedTrackNumber);

      for (int step=0; step < beatGrid[0].length; step++) {
        float normalizedStepNumber = float(step) /  (beatGrid[0].length - 1);

        float stepOffsetAdd = normalizedStepNumber + stepwiseOffset[step];

        PVector stepPos = PVector.lerp(trackLeft, trackRight, stepOffsetAdd);

        // ACTUALIZAR stepWise GIZMOS
        if (track == 0) {
          //println("-|| " + track + " : " + step);
          stepGizmoPos[step].set(stepPos.x, stepPos.y - 0.05);
          stepGizmoPos[step] = fitToBoundingBoxScreen(stepGizmoPos[step]);
        }


        // ECUACION PARA UNA CURVA BEZIER CUADRATICA (1 PUNTO DE CONTROL + 2 VERTICES)
        //stepPos.x = (pow(1-normalizedStepNumber, 2) * trackLeft.x) + (2*(1-normalizedStepNumber)*normalizedStepNumber*bezierMidPoint.x) + ((normalizedStepNumber*normalizedStepNumber) * trackRight.x);
        //stepPos.y = lerp(trackLeft.y, trackRight.y, stepPos.x);


        beatGrid[track][step] = stepPos;
      }
    }
  }

  void ordenarBeatGridBkUp() {

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

  public boolean detectarTocarStepGizmo(float x, float y) {

    for (int step=0; step < beatGrid[0].length; step++) {
      PVector gizmoPos = stepGizmoPos[step];
      if (dist(gizmoPos.x, gizmoPos.y, x, y) < 10) {
        selectedStepGizmo = step;
        draggingSteps = true;
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

  private void dibujarPlayHead() {
    PVector playHeadTop = fitToBoundingBoxScreen(beatGrid[0][atStep]);
    PVector playHeadBottom = fitToBoundingBoxScreen(beatGrid[beatGrid.length - 1][atStep]);
    stroke(255, 0, 255);
    line(playHeadTop.x, playHeadTop.y, playHeadBottom.x, playHeadBottom.y);
  }

  private color colorearPuntos(int track, int step) {

    // CORNER POINTS SON ROJOS. TODO LO DEMAS, BLANCO
    if ((track == 0 && step ==0) || (track == beatGrid.length - 1 && step ==0) || (track == 0 &&  step == beatGrid[0].length - 1) || (track == beatGrid.length - 1 && step == beatGrid[0].length - 1)) {
      return color (255, 0, 0);
    } else {
      return color (0, 0, 255);
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
        beatGridOffsets[track][step].set(0, 0);
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

  public void drawMiniSequencer() {

    int posX = 790;
    int posY = 580;
    int w = 80;
    int h = 15;
    int steps = beatGrid[0].length;
    int separation = int(float(w) / steps);

    // LINES
    noFill();
    stroke(colorPalette.BACKGROUND_LIGHT);
    for (int i=1; i < steps; i++) {
      line(posX + (i * separation), posY, posX + (i * separation), posY + h );
    }


    //  PLAYHEAD
    noStroke();
    fill(colorPalette.HIGHLIGHT_RED);
    float headPosX = posX + (separation * atStep);
    rect(headPosX, posY, separation, h);


    // BACK RECTANGLE
    noFill();
    stroke(colorPalette.BACKGROUND_LIGHT);
    rect(posX, posY, w, h);

    noStroke();
    fill(colorPalette.HIGHLIGHT_RED);
    text(atStep + 1, posX + w + 5, posY + (h * 0.8));
  }



  // SYSTEM INPUT EVENTS -----------------

  public void onMousePressed(int mX, int mY) {

    detectarTocarEsquinasGrid(mX, mY);
    detectarTocarEsquinasBox(mX, mY);
    detectarTocarStepGizmo(mX, mY);
    //detectarTocarPoints(mX, mY);
  }

  public void onMouseReleased(int mX, int mY) {
    draggingGridCorner = false;
    draggingBoxCorner = false;
    draggingSteps = false;

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

  public void onKeyPressed(char _key) {
    if (_key ==  'a') {
      stepwiseOffset[0] -= 0.05;
    }
    if (_key ==  's') {
      stepwiseOffset[0] += 0.05;
    }
    ordenarBeatGrid();
  }
}
