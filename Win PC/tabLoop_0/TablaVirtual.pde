class TablaVirtual {

  PVector[] cornerPoints; // EVERYTHING NORMALIZED
  PVector[][] trackStepPos; // [TRACK][STEP]
  PVector midPoint = new PVector(0.5, 0.5);
  //PVector gridOffset = new PVector(0.025,0.05);
  int atStep;

  boolean calibrationMode = true;
  int selectedCorner = 0;
  boolean draggingCorner = false;
  float stepDeformCoeficiente;

  public TablaVirtual() {

    int tracks = 10;
    int steps = 16;
    stepDeformCoeficiente = 1;


    cornerPoints = new PVector[4];
    trackStepPos = new PVector[tracks][steps];

    cornerPoints[0] = new PVector(0.1, 0.1);
    cornerPoints[1] = new PVector(0.9, 0.1);
    cornerPoints[2] = new PVector(0.9, 0.9);
    cornerPoints[3] = new PVector(0.1, 0.9);

    ordenarTrackSteps();


    atStep = 0;
  }

  void update() {

    if (draggingCorner) {
      cornerPoints[selectedCorner].set( (float)mouseX / width, (float)mouseY / height);
      ordenarTrackSteps();
    }
  }


  void render() {

    if (calibrationMode) {
      // DIBUJAR PUNTOS
      noStroke();
      for (int track=0; track < trackStepPos.length; track++) {
        for (int step=0; step < trackStepPos[0].length; step++) {
          float xPos = trackStepPos[track][step].x * width;
          float yPos = trackStepPos[track][step].y * height;

          fill(255, 255, 0);
          ellipse(xPos, yPos, 5, 5);

          fill(127);
          text(track + "|" + step, xPos + 5, yPos);
        }
      }

      // DIBUJAR CORNER GIZMOS
      noFill();
      stroke(0, 255, 255);
      ellipse(cornerPoints[0].x * width, cornerPoints[0].y * height, 5, 5);
      ellipse(cornerPoints[0].x * width, cornerPoints[0].y * height, 15, 15);
      ellipse(cornerPoints[1].x * width, cornerPoints[1].y * height, 5, 5);
      ellipse(cornerPoints[1].x * width, cornerPoints[1].y * height, 15, 15);
      ellipse(cornerPoints[2].x * width, cornerPoints[2].y * height, 5, 5);
      ellipse(cornerPoints[2].x * width, cornerPoints[2].y * height, 15, 15);
      ellipse(cornerPoints[3].x * width, cornerPoints[3].y * height, 5, 5);
      ellipse(cornerPoints[3].x * width, cornerPoints[3].y * height, 15, 15);
    }
  }

  void ordenarTrackSteps() {


    // for each (Track for each (step))
    for (int track=0; track < trackStepPos.length; track++) {
      float normalizedTrackNumber = float(track) /  (trackStepPos.length -1);
      PVector trackLeft = PVector.lerp(cornerPoints[0], cornerPoints[3], normalizedTrackNumber);
      PVector trackRight = PVector.lerp(cornerPoints[1], cornerPoints[2], normalizedTrackNumber);

      for (int step=0; step < trackStepPos[0].length; step++) {
        float normalizedStepNumber = float(step) /  (trackStepPos[0].length - 1);

        PVector stepPos = new PVector();// = PVector.lerp(trackLeft, trackRight, normalizedStepNumber);
        //float x = 2 * (1 - (normalizedStepNumber)) * (normalizedStepNumber) * 0.5 + pow((normalizedStepNumber), 2) * 1;

        //stepPos.x = (pow(1-normalizedStepNumber, 2) * trackLeft.x) + (2*(1-normalizedStepNumber)*normalizedStepNumber*midPoint.x) + ((normalizedStepNumber*normalizedStepNumber) * trackRight.x);
        stepPos.x = (pow(1-normalizedStepNumber, 2) * trackLeft.x) + (2*(1-normalizedStepNumber)*normalizedStepNumber*midPoint.x) + ((normalizedStepNumber*normalizedStepNumber) * trackRight.x);
        stepPos.y = lerp(trackLeft.y,trackRight.y,normalizedStepNumber);
        //stepPos.y = (pow(1-normalizedStepNumber, 2) * trackLeft.y) + (2*(1-normalizedStepNumber)*normalizedStepNumber*lerp(trackLeft.y,trackRight.y,normalizedStepNumber)) + ((normalizedStepNumber*normalizedStepNumber) * trackRight.y);
        //stepPos.y = (pow(1-stepPos.y, 2) * trackLeft.y) + (2*(1-stepPos.y)*stepPos.y*midPoint.y) + ((stepPos.y*stepPos.y) * trackRight.y);

        //stepPos.add(gridOffset);
        trackStepPos[track][step] = stepPos;
      }
    }
  }

  public float easeOut(float t, float b, float c, float d) {
    return c * ((t = t / d - 1) * t * t + 1) + b;
  }


  public boolean detectarTocarEsquinas(float x, float y) {

    for (int i=0; i < cornerPoints.length; i++) {
      if ( dist(x, y, cornerPoints[i].x * width, cornerPoints[i].y * height) < 10 ) {
        selectedCorner = i;
        draggingCorner = true;
        return true;
      }
    }
    return false;
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