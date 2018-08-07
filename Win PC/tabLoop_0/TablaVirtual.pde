class TablaVirtual { //<>//

  PVector [] boundingBox; // topLeft y bottomRight points, in screenSpace. Should fit the camera image
  PVector[] cornerPoints; // EVERYTHING NORMALIZED
  PVector[][] trackStepPos; // [TRACK][STEP]
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
    trackStepPos = new PVector[tracks][steps];

    boundingBox[0] = new PVector(0, 0);
    boundingBox[1] = new PVector(640, 480);

    cornerPoints[0] = new PVector(0, 0);
    cornerPoints[1] = new PVector(1, 0);
    cornerPoints[2] = new PVector(1, 1);
    cornerPoints[3] = new PVector(0, 1);

    //cornerPoints[0] = new PVector(0.1, 0.1);
    //cornerPoints[1] = new PVector(0.9, 0.1);
    //cornerPoints[2] = new PVector(0.9, 0.9);
    //cornerPoints[3] = new PVector(0.1, 0.9);

    ordenarTrackSteps();


    atStep = 0;

    camImage = loadImage("BWgrid.png");
  }

  void update() {

    if (draggingCorner) {
      PVector posInsideBoundingBox = new PVector();
      //posInsideBoundingBox.x = map(mouseX, 0, width, boundingBox[0].x, boundingBox[1].x);
      //posInsideBoundingBox.y = map(mouseY, 0, height, boundingBox[0].y, boundingBox[1].y);
      posInsideBoundingBox.x = norm(mouseX, boundingBox[0].x, boundingBox[1].x);
      posInsideBoundingBox.y = norm(mouseY, boundingBox[0].y, boundingBox[1].y);

      //cornerPoints[selectedCorner].set( (float)mouseX / width, (float)mouseY / height);
      cornerPoints[selectedCorner].set(posInsideBoundingBox);

      ordenarTrackSteps();
    }

    //sampleImage();
  }


  void render() {

    image(camImage, 0, 0);

    if (calibrationMode) {

      // DIBUJAR BOUNDING BOX
      stroke(255, 0, 255);
      rect(boundingBox[0].x, boundingBox[0].y, boundingBox[1].x - boundingBox[0].x, boundingBox[1].y - boundingBox[0].y);

      // DIBUJAR PUNTOS
      noStroke();
      for (int track=0; track < trackStepPos.length; track++) {
        for (int step=0; step < trackStepPos[0].length; step++) {
          float xPos = trackStepPos[track][step].x * width;
          float yPos = trackStepPos[track][step].y * height;

          fill(colorearPuntos(track, step));
          ellipse(xPos, yPos, 5, 5);


          if (trackStepPos[track][step].z >= 0.99) {
            fill(0, 255, 0);
            ellipse(xPos, yPos, 7, 7);
          }

          //fill(0, 0, 255);
          //text(trackStepPos[track][step].z, xPos + 5, yPos);
        }
      }

      // DIBUJAR CORNER GIZMOS
      noFill();
      stroke(0, 255, 255);
      ellipse(cornerPoints[0].x * getBoundingBoxSize().x, cornerPoints[0].y * getBoundingBoxSize().y, 15, 15);
      ellipse(cornerPoints[1].x * getBoundingBoxSize().x, cornerPoints[1].y *  getBoundingBoxSize().y, 15, 15);
      ellipse(cornerPoints[2].x * getBoundingBoxSize().x, cornerPoints[2].y *  getBoundingBoxSize().y, 15, 15);
      ellipse(cornerPoints[3].x * getBoundingBoxSize().x, cornerPoints[3].y *  getBoundingBoxSize().y, 15, 15);
    }
  }

  void sampleImage() {

    for (int track=0; track < trackStepPos.length; track++) {
      for (int step=0; step < trackStepPos[0].length; step++) {

        //float pixelSlot = trackStepPos[track][step].x + (trackStepPos[track][step].y * 1);
        int pixelSlot = (int(trackStepPos[track][step].x) * camImage.width) + (((int(trackStepPos[track][step].y) * camImage.width ) * camImage.width));
        float b = brightness(camImage.pixels[pixelSlot]);

        trackStepPos[track][step].z = map(b, 0, 255, 1, 0);
      }
    }
  }

  void ordenarTrackSteps() {


    // for each (Track for each (step))
    for (int track=0; track < trackStepPos.length; track++) {
      float normalizedTrackNumber = float(track) /  (trackStepPos.length - 1);
      PVector trackLeft = PVector.lerp(cornerPoints[0], cornerPoints[3], normalizedTrackNumber);
      PVector trackRight = PVector.lerp(cornerPoints[1], cornerPoints[2], normalizedTrackNumber);

      for (int step=0; step < trackStepPos[0].length; step++) {
        float normalizedStepNumber = float(step) /  (trackStepPos[0].length - 1);

        PVector stepPos = new PVector();// = PVector.lerp(trackLeft, trackRight, normalizedStepNumber);

        //stepPos.x = (pow(1-normalizedStepNumber, 2) * trackLeft.x) + (2*(1-normalizedStepNumber)*normalizedStepNumber*midPoint.x) + ((normalizedStepNumber*normalizedStepNumber) * trackRight.x);
        stepPos.x = (pow(1-normalizedStepNumber, 2) * trackLeft.x) + (2*(1-normalizedStepNumber)*normalizedStepNumber*bezierMidPoint.x) + ((normalizedStepNumber*normalizedStepNumber) * trackRight.x);
        //stepPos.y = lerp(trackLeft.y, trackRight.y, normalizedStepNumber);
        stepPos.y = lerp(trackLeft.y, trackRight.y, stepPos.x);
        //stepPos.y = (pow(1-normalizedStepNumber, 2) * trackLeft.y) + (2*(1-normalizedStepNumber)*normalizedStepNumber*lerp(trackLeft.y,trackRight.y,normalizedStepNumber)) + ((normalizedStepNumber*normalizedStepNumber) * trackRight.y);
        //stepPos.y = (pow(1-stepPos.y, 2) * trackLeft.y) + (2*(1-stepPos.y)*stepPos.y*midPoint.y) + ((stepPos.y*stepPos.y) * trackRight.y);

        /*
        if (track == 0) {
         //rect((stepPos.y  * width - 5), (stepPos.y * height - 5) , 10,10);
         text(stepPos.y,(stepPos.x  * width - 5), (stepPos.y * height - 5));
         }
         */

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


  private color colorearPuntos(int track, int step) {

    // CORNER POINTS SON ROJOS. TODO LO DEMAS, BLANCO
    if ((track == 0 && step ==0) || (track == trackStepPos.length - 1 && step ==0) || (track == 0 &&  step == trackStepPos[0].length - 1) || (track == trackStepPos.length - 1 && step == trackStepPos[0].length - 1)) {
      return color (255, 0, 0);
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
