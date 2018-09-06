import processing.serial.*;


class ArduinoManager {

  Serial port;

  ArduinoManager(PApplet p5) {
    
    println("-|| Serial available: ");
    printArray(Serial.list());

    String portName = Serial.list()[1];
    port = new Serial(p5, portName, 9600);
  }

  void sendBeat(int beat) {
    port.write(beat);
  }

}
