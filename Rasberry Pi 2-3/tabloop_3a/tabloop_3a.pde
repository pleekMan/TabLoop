
import processing.video.*;
// -------------------------------

import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;

import org.opencv.core.Mat;
import org.opencv.core.CvType;
// -------------------------------

import java.awt.Rectangle;
// -------------------------------

import ddf.minim.*;
import ddf.minim.ugens.*;
// -------------------------------

Minim       minim;
AudioOutput out;
// -------------------------------

Sampler     kick;
Sampler     snare;
Sampler     hat;
Sampler     opHat;
Sampler     fx;

boolean[] hatRow = new boolean[16];
boolean[] opHatRow = new boolean[16];
boolean[] snrRow = new boolean[16];
boolean[] kikRow = new boolean[16];
boolean[] fxRow = new boolean[16];

// -------------------------------
OpenCV opencv1, opencv2;
Capture cam;

PImage proc, contoursImage;
PImage captura, tablero, lecturaActual, lecturaPr;

ArrayList<Contour> contours;
IntList coordsLecturaActual;

PVector[] coordsCalibV;
ArrayList<PVector> coordsCalibVL;

// -------------------------------

int thresholdc, thresholdg;

boolean calibracion;
int contadorCalib;
int contadorSeq, cantPasosSeq;

int tableroWidth, tableroHeight;

int bpm = 120;

int beat; // which beat we're on

int cantKiks, cantSnares, cantHats, cantOpHats, cantFXs;

// -------------------------------

void setup() {
  //frameRate(15);
  size(960, 600);
  //fullScreen();
  colorMode(HSB);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(4);

  minim = new Minim(this);
  out   = minim.getLineOut();

  // load all of our samples, using 4 voices for each.
  // this will help ensure we have enough voices to handle even
  // very fast tempos.
  kick  = new Sampler( "JXL Kick 11.wav", 4, minim );
  snare = new Sampler( "JXL Snare 01.wav", 4, minim );
  hat   = new Sampler( "JXL Hat 15.wav", 4, minim );
  opHat   = new Sampler( "JXL Hat 06.wav", 4, minim );
  fx   = new Sampler( "1980 ANALOG DRUM 10 KT.wav", 4, minim );
  // patch samplers to the output
  kick.patch( out );
  snare.patch( out );
  hat.patch( out );
  opHat.patch( out );
  fx.patch( out );

  beat = 0;  

  thresholdc = 100;
  thresholdg = 128;

  cam = new Capture(this);
  cam.start();

  opencv1 = new OpenCV(this, 640, 480);
  opencv2 = new OpenCV(this, 40, 480);

  contours = new ArrayList<Contour>();
  coordsCalibVL = new ArrayList<PVector>();
  coordsLecturaActual = new IntList();

  contadorCalib = 0;
  calibracion = true;

  contadorSeq = 0;
  cantPasosSeq = 16;

  tableroWidth = 640;
  tableroHeight = 480;
}

// -------------------------------

void draw() {
  background(0);

  if (cam.available() == true) {
    cam.read();
    opencv1.loadImage(cam);
  }

  if (calibracion) {

    //threshold = map(mouseX, 0, width, 0, 255);
    opencv1.gray();
    opencv1.blur(4);
    opencv1.threshold(thresholdc);
    opencv1.dilate();
    opencv1.erode();
    opencv1.blur(2);
    opencv1.invert();

    proc = opencv1.getSnapshot();

    image(cam, 0, 0);
    //image(proc, 0, 0);
    //image(cam, proc.width, 0, 320, 240);
  } else {

    tablero = createImage(tableroWidth, tableroHeight, ARGB);  
    opencv1.toPImage(warpPerspective(coordsCalibVL, tableroWidth, tableroHeight), tablero);

    lecturaActual = tablero.get(tablero.width/cantPasosSeq*contadorSeq, 0, tablero.width/cantPasosSeq, tablero.height);
    opencv2.loadImage(lecturaActual);

    opencv2.gray();
    opencv2.blur(4);
    opencv2.threshold(thresholdg);
    opencv2.dilate();
    opencv2.erode();
    lecturaActual = opencv2.getSnapshot();
    contours = opencv2.findContours(true, false);
    coordsLecturaActual.clear();
    cantKiks = 0;
    cantSnares = 0;
    cantHats = 0;
    cantOpHats = 0;
    cantFXs = 0;
    for (int i=0; i<contours.size(); i++) {
      Contour contour = contours.get(i);
      Rectangle r = contour.getBoundingBox();

      coordsLecturaActual.append(r.y);
    }

    if (coordsLecturaActual.size() < 2) {
      kikRow[contadorSeq] = false;
      snrRow[contadorSeq] = false;
      hatRow[contadorSeq] = false;
      opHatRow[contadorSeq] = false;
      fxRow[contadorSeq] = false;
    } else {
      for (int i = 0; i < coordsLecturaActual.size(); i++) {
        int fila = int(float(coordsLecturaActual.get(i))/lecturaActual.height*5);
        println(coordsLecturaActual.get(i), lecturaActual.height, fila);

        switch(fila) {
        case 0: 
          cantKiks++;
          break;
        case 1: 
          cantSnares++;
          break;
        case 2: 
          cantHats++;
          break;
        case 3: 
          cantOpHats++;
          break;
        case 4: 
          cantFXs++;
          break;
        }
      }
    }

    if (cantKiks > 1) {
      kikRow[contadorSeq] = true;
    } else {
      kikRow[contadorSeq] = false;
    }

    if (cantSnares > 0) {
      snrRow[contadorSeq] = true;
    } else {
      snrRow[contadorSeq] = false;
    }

    if (cantHats > 0) {
      hatRow[contadorSeq] = true;
    } else {
      hatRow[contadorSeq] = false;
    }

    if (cantOpHats > 0) {
      opHatRow[contadorSeq] = true;
    } else {
      opHatRow[contadorSeq] = false;
    }

    if (cantFXs > 0) {
      fxRow[contadorSeq] = true;
    } else {
      fxRow[contadorSeq] = false;
    }


    //println(coordsLecturaActual);
    image(tablero, 0, 0);
    image(lecturaActual, contadorSeq*tablero.width/cantPasosSeq, 0);
    image(cam, tablero.width, 0, 320, 240);

    rect(beat*tablero.width/cantPasosSeq, 0, tablero.width/cantPasosSeq, lecturaActual.height);

    contadorSeq++;
    //println(contadorSeq);
    if (contadorSeq>=16) {
      contadorSeq = 0;
    }
  }
}

// -------------------------------


void colectarCoordCalib() {
  contours = opencv1.findContours(true, false);

  Contour contour = contours.get(0);
  Rectangle r = contour.getBoundingBox();

  PVector v;
  //v = new PVector(r.x, r.y);
  v = new PVector(mouseX, mouseY);
  coordsCalibVL.add(v);

  contadorCalib++;
  println("contadorCalib: "+contadorCalib, v);
  if (contadorCalib >= 4) {
    println(coordsCalibVL);
    calibracion = false;

    // start the sequencer
    out.setTempo( bpm );
    out.playNote( 0, 0.25f, new Tick() );
  }
}

void keyPressed() {
  if (key == 'c') {
    colectarCoordCalib();
  }

  if (key == 'T') {
    bpm++;
  }
  if (key == 't') {
    bpm--;
  }
}


void mousePressed() {
  if (calibracion) {
    colectarCoordCalib();
  }
}

// -------------------------------


Mat getPerspectiveTransformation(ArrayList<PVector> inputPoints, int w, int h) {
  Point[] canonicalPoints = new Point[4];
  canonicalPoints[0] = new Point(w, 0);
  canonicalPoints[1] = new Point(0, 0);
  canonicalPoints[2] = new Point(0, h);
  canonicalPoints[3] = new Point(w, h);

  MatOfPoint2f canonicalMarker = new MatOfPoint2f();
  canonicalMarker.fromArray(canonicalPoints);

  Point[] points = new Point[4];
  for (int i = 0; i < 4; i++) {
    points[i] = new Point(inputPoints.get(i).x, inputPoints.get(i).y);
  }
  MatOfPoint2f marker = new MatOfPoint2f(points);
  return Imgproc.getPerspectiveTransform(marker, canonicalMarker);
}

Mat warpPerspective(ArrayList<PVector> inputPoints, int w, int h) {
  Mat transform = getPerspectiveTransformation(inputPoints, w, h);
  Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
  Imgproc.warpPerspective(opencv1.getColor(), unWarpedMarker, transform, new Size(w, h));
  return unWarpedMarker;
}

// -------------------------------

class Tick implements Instrument
{
  void noteOn( float dur )
  {
    if ( hatRow[beat] ) hat.trigger();
    if ( snrRow[beat] ) snare.trigger();
    if ( kikRow[beat] ) kick.trigger();
    if ( opHatRow[beat] ) opHat.trigger();
    if ( fxRow[beat] ) fx.trigger();
  }

  void noteOff()
  {
    // next beat
    beat = (beat+1)%16;
    // set the new tempo2
    out.setTempo( bpm );
    // play this again right now, with a sixteenth note duration
    out.playNote( 0, 0.25f, this );
  }
}


// -------------------------------
