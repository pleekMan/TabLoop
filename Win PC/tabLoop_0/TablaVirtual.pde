class TablaVirtual { //<>//

  PVector [] boundingBox; // topLeft y bottomRight points, in screenSpace. Should fit the camera image
  PVector[] cornerPoints; // EVERYTHING NORMALIZED
  PVector[][] beatGrid; // [TRACK][STEP]
  PVector bezierMidPoint = new PVector(0.5, 0.5);
  //PVector gridOffset = new PVector(0.025,0.05);
  int atStep;

  boolean calibrationMode = true;
  int selectedCorner = 0;
  boolean draggingCorner = false;

  PImage camImage;

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

    cornerPoints[0] = new PVector(0, 0);
    cornerPoints[1] = new PVector(1, 0);
    cornerPoints[2] = new PVector(1, 1);
    cornerPoints[3] = new PVector(0, 1);

    //cornerPoints[0] = new PVector(0.1, 0.1);
    //cornerPoints[1] = new PVector(0.9, 0.1);
    //cornerPoints[2] = new PVector(0.9, 0.9);
    //cornerPoints[3] = new PVector(0.1, 0.9);

    ordenarBeatGrid();


    atStep = 0;

    camImage = loadImage("BWgrid.png");
  }

  public void update() {

    if (draggingCorner) {
      PVector posInsideBoundingBox = new PVector();
      cornerPoints[selectedCorner].set(fitToBoundingBoxNormalized(new PVector(mouseX, mouseY)));
      ordenarBeatGrid();
    }

    //sampleImage();
  }


  public void render() {

    //image(camImage, 0, 0);

    if (calibrationMode) {

      // DIBUJAR BOUNDING BOX
      stroke(255, 0, 255);
      rect(boundingBox[0].x, boundingBox[0].y, boundingBox[1].x - boundingBox[0].x, boundingBox[1].y - boundingBox[0].y);

      // DIBUJAR PUNTOS EN GRILLA

      noStroke();
      for (int track=0; track < beatGrid.length; track++) {
        for (int step=0; step < beatGrid[0].length; step++) {

          PVector pointInScreen = fitToBoundingBoxScreen(beatGrid[track][step]);

          fill(colorearPuntos(track, step));
          ellipse(pointInScreen.x, pointInScreen.y, 5, 5);


          if (beatGrid[track][step].z >= 0.99) {
            fill(0, 255, 0);
            ellipse(pointInScreen.x, pointInScreen.y, 7, 7);
          }

          //fill(0, 0, 255);
          //text(trackStepPos[track][step].z, xPos + 5, yPos);
        }
      }



      // DIBUJAR CORNER GIZMOS
      dibujarCornerGizmos();
    }
  }

  void sampleImage() {

    for (int track=0; track < beatGrid.length; track++) {
      for (int step=0; step < beatGrid[0].length; step++) {

        //float pixelSlot = trackStepPos[track][step].x + (trackStepPos[track][step].y * 1);
        int pixelSlot = (int(beatGrid[track][step].x) * camImage.width) + (((int(beatGrid[track][step].y) * camImage.width ) * camImage.width));
        float b = brightness(camImage.pixels[pixelSlot]);

        beatGrid[track][step].z = map(b, 0, 255, 1, 0);
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



  public boolean detectarTocarEsquinas(float x, float y) {

    for (int i=0; i < cornerPoints.length; i++) {
      // MAP FUNCTION ALSO EXTRAPOLATES (VALUES OUTSIDE RANGES WILL GIVE CORRECT RESULTS)
      PVector pointInScreen = fitToBoundingBoxScreen(cornerPoints[i]); 
      if ( dist(x, y, pointInScreen.x, pointInScreen.y) < 10 ) {
        selectedCorner = i;
        draggingCorner = true;
        println("Click on CornerPoint: " + i);
        return true;
      }
    }
    return false;
  }

  private PVector fitToBoundingBoxScreen(PVector point) {
    // FROM BOUNDING BOX NORMAL SPACE -> SCREEN SPACE
    float x = map(point.x, 0, 1, boundingBox[0].x, boundingBox[1].x);
    float y = map(point.y, 0, 1, boundingBox[0].y, boundingBox[1].y);
    return new PVector(x, y);
  }

  private PVector fitToBoundingBoxNormalized(PVector point) {
    // FROM SCREEN SPACE -> BOUNDING BOX NORMAL SPACE
    float x = map(point.x, boundingBox[0].x, boundingBox[1].x, 0, 1);
    float y = map(point.y, boundingBox[0].y, boundingBox[1].y, 0, 1);
    return new PVector(x, y);
  }

  private void dibujarCornerGizmos() {

    noFill();
    stroke(0, 255, 255);

    float[][] vizCorners = new float[4][2];
    for (int i=0; i < vizCorners.length; i++) {
      vizCorners[i][0] = map(cornerPoints[i].x, 0, 1, boundingBox[0].x, boundingBox[1].x);
      vizCorners[i][1] = map(cornerPoints[i].y, 0, 1, boundingBox[0].y, boundingBox[1].y);

      ellipse(vizCorners[i][0], vizCorners[i][1], 15, 15);
    }
  }


  private color colorearPuntos(int track, int step) {

    // CORNER POINTS SON ROJOS. TODO LO DEMAS, BLANCO
    if ((track == 0 && step ==0) || (track == beatGrid.length - 1 && step ==0) || (track == 0 &&  step == beatGrid[0].length - 1) || (track == beatGrid.length - 1 && step == beatGrid[0].length - 1)) {
      return color (255, 255, 0);
    } else {
      return color (255);
    }
  }


  private PVector getBoundingBoxSize() {
    return new PVector(boundingBox[1].x - boundingBox[0].x, boundingBox[1].y - boundingBox[0].y);
  }
}



/*
  private void buildInterpolations() {
 
 // CREATING THE QUADRATIC GRADIENT FROM 0 TO 1 (NOT FROM POINT TO POINT IN SPACE)
 // X
 for (int t = 0; t < trackStepPos[0].length; t++) {
 float normalizedResolution = (float) t / trackStepPos[0].length;
 trackStepPos[t].x = 2 * (1 - (normalizedResolution)) * (normalizedResolution) * midPoint.x + pow((normalizedResolution), 2) * 1;
 // ENTERA: subDivsX[t] = p5.pow((1 - normalizeResolution),2) * 0 +
 // 2*(1 - (normalizeResolution)) * (normalizeResolution) *
 // midPoints[0] + p5.pow((normalizeResolution),2) * 1;
 // System.out.println("Line " + t + " X at:" + xSubT);
 }
 
 // Y
 for (int t = 0; t < trackStepPos.length; t++) {
 float normalizedResolution = (float) t / trackStepPos.length;
 trackStepPos[t].y = 2 * (1 - (normalizedResolution)) * (normalizedResolution) * midPoints[1] + p5.pow((normalizedResolution), 2) * 1;
 }
 
 }
 }
 */
