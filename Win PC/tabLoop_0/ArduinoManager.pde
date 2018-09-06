import processing.serial.*;


class ArduinoManager {

  Serial port;

  ArduinoManager(PApplet p5) {

    println("-|| Serial COMs available: ");
    printArray(Serial.list());

    String portName = Serial.list()[0];
    port = new Serial(p5, portName, 9600);
  }

  void sendBeat(int beat) {
    //port.write(beat);
    port.write(int(beat % 7)); // TEST CON MENOS LEDS
    println("-|| Sending beat:");
    println("|-> " + beat);
  }
  void update() {
    if ( port.available() > 0) {
      int inValue = port.read();
      println("->| " + inValue);
    }
  }
}
