// Dimmer - sends bytes over a serial port //<>// //<>//
// by David A. Mellis
//This example code is in the public domain.

import controlP5.*;
import processing.serial.*;

boolean bInit = true;
ControlP5 cp5;
Button btnSW1;
Serial port;
boolean blnRotate = true;
boolean blnSW1 = false;
int nOldValue = 0;
int beatCnt = 0;
String strMsg;
String strBuff;
String strCap1;
String strCap2;

void setup() {
  size(256, 180);

  println("Available serial ports:");
  // if using Processing 2.1 or later, use Serial.printArray()
  println(Serial.list());

  cp5 = new ControlP5(this);
  // create a new button
  btnSW1 = cp5.addButton("SW1")
     .setValue(0)
     .setPosition(128,20)
     .setSize(40,18)
     ;  

  strCap2 = "Beat count: 0";
  
  // Uses the first port in this list (number 0).  Change this to
  // select the port corresponding to your Arduino board.  The last
  // parameter (e.g. 9600) is the speed of the communication.  It
  // has to correspond to the value passed to Serial.begin() in your
  // Arduino sketch.
  port = new Serial(this, Serial.list()[0], 9600);

  // If you know the name of the port used by the Arduino board, you
  // can specify it directly like this.
  //port = new Serial(this, "COM1", 9600);
  
  bInit = false;
}

void draw() {
  // draw a gradient from black to white
  for (int i = 0; i < 256; i++) {
    stroke(i);
    line(i, 0, i, 180);
  }

  textSize(12);
  fill(0, 200, 50);

  pushMatrix();
  translate(width*0.05, height*0.08);
  if ( blnRotate )
    rotate(frameCount / -100.0);
  star(0, 0, 5, 10, 8); 
  popMatrix();

  // write the current X-position of the mouse to the serial port as
  // a single byte
  if ( blnRotate ) {
    nOldValue = mouseX;
  }
  port.write(nOldValue);

  // Read from Serial
  strMsg = null;
  String inBuffer = port.readString();   
  if (inBuffer != null) {
    print(inBuffer);
    strBuff += inBuffer;
    int crP = strBuff.indexOf("\n");
    if( crP >= 0 ) {
      strMsg = strBuff.substring(0, crP);
      strBuff = strBuff.substring(crP+1);
    }
  }

  // Show on canvas
  if( strMsg != null ) {
    // Warning
    int dat1P1;
    int dat1P2;
    int dat2P1;
    int dat2P2;
    dat1P1 = strMsg.indexOf("Humidity:");
    if( dat1P1 >= 0 ) { 
      dat1P2 = strMsg.indexOf("%", dat1P1);
      dat2P1 = strMsg.indexOf("Temperature:", dat1P2);
      dat2P2 = strMsg.indexOf("C", dat2P1);
      String strHumidity = strMsg.substring(dat1P1+10, dat1P2);
      String strTemperature = strMsg.substring(dat2P1+13, dat2P2);
      if( strHumidity != null ) {
          float nHumidity = float(strHumidity);
          if( nHumidity > 60 || nHumidity < 26 ) {
            fill(255, 0, 50);
          }
      }
      if( strTemperature != null ) {
          float nTemperature = float(strTemperature);
          if( nTemperature > 38 || nTemperature < 18 ) {
            fill(255, 0, 50);
          }
      }
      
      strCap1 = strMsg.substring(dat1P1);
    } else {
      dat1P1 = strMsg.indexOf("ACT: beat");
      if( dat1P1 >= 0 ) {
        beatCnt++;
        strCap2 = "Beat count:" + str(beatCnt);
      } else {
        dat1P1 = strMsg.indexOf("ACT: SW1ON");
        if( dat1P1 >= 0 ) {
          blnSW1 = true;
        } else {
          dat1P1 = strMsg.indexOf("ACT: SW1OFF");
          if( dat1P1 >= 0 ) {
            blnSW1 = false;
          }
        }
      }
    }
  }

  if( strCap1 != null )
    text(strCap1, 26, 16);
  
  if( strCap2 != null )
    text(strCap2, 26, 30);
    
  // Draw Switch Button
  if( blnSW1 ) {
    fill(0, 200, 50);
    btnSW1.setLabel("SW1 On");
  }
  else {
    fill(255, 50, 0);
    btnSW1.setLabel("SW1 Off");
  }
}

void keyPressed() {
  if ( key == ' ' ) {
    blnRotate = !blnRotate;
  }
}

void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

public void controlEvent(ControlEvent theEvent) {
  if( bInit )
    return;

  println(theEvent.getController().getName());
}

public void SW1(int theValue) {
  if( bInit )
    return;
    
  println("a button event from SW1: "+theValue);
  blnSW1 = !blnSW1;
 
  port.write(255);
  port.write(0);
  port.write((blnSW1 ? 1 : 0));
}