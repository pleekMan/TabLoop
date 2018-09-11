//For more information, see: http://playground.arduino.cc/Interfacing/Processing

import processing.serial.*;

import cc.arduino.*;

Arduino arduino;

int selectedPin = 0;
int ledPins[] = {14,15,16,17,18};

void setup() {
  size(880, 540);

  // Prints out the available serial ports.
  println(Arduino.list());

  arduino = new Arduino(this, Arduino.list()[9], 57600);

  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  //arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);

  // Set the Arduino digital pins as inputs.
  for (int i = 2; i <= 53; i++)
    arduino.pinMode(i, Arduino.OUTPUT);
}

void draw() {
  background(0);

  if (frameCount % 5 == 0) {
    selectedPin = (selectedPin + 1) % ledPins.length;


    for (int i = 0; i < ledPins.length; i++) {
      arduino.digitalWrite(ledPins[i], Arduino.LOW);
    }
    arduino.digitalWrite(ledPins[selectedPin], Arduino.HIGH);
    
  }
}
