import processing.serial.*;
import cc.arduino.*;

class ArduinoManager {

  Arduino arduino;

  int selectedPin = 0;
  int ledPins[] = {13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 14, 15, 16, 17};

  ArduinoManager(PApplet p5) {

    println("-|| Arduino >> Serial COMs available: ");
    printArray(Serial.list());

    arduino = new Arduino(p5, Arduino.list()[0], 57600);
    for (int i = 0; i <= 53; i++)arduino.pinMode(i, Arduino.OUTPUT); // ARDUINO MEGA
  }

  void sendBeat(int beat) { 

    //println("-|| Sending beat:");
    //println("|-> " + beat);
    //selectedPin = beat % ledPins.length; // TEST CON MENOS LEDS

    selectedPin = beat;

    for (int i = 0; i < ledPins.length; i++) {
      arduino.digitalWrite(ledPins[i], Arduino.LOW);
    }
    arduino.digitalWrite(ledPins[selectedPin], Arduino.HIGH);
  }

  /*
  void update() {
   if ( port.available() > 0) {
   int inValue = port.read();
   println("->| " + inValue);
   }
   }
   */
}
