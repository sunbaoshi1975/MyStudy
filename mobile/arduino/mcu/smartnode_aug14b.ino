// the pin that the LED is attached to
const int ledpin = 11;
const int leddim = 9;
const int redpin = 3;
const int greenpin = 5;
const int bluepin = 6;
const int btnPin = 8;
const int colorPin = 12;  // Multi-color LED
const int boardLedPin = 13;  // 自带LED的引脚

const int potpin = 0;   // analog: the pin for photoresistor
const int DHpin = 7;    // Temperature and humidity
const int beatPin = 4;  // 敲击传感器

byte bColorR = 255;
byte bColorG = 128;
byte bColorB = 0;

byte bGlobalTimer = 0;
byte bBeatOnTimer = 0;
byte bGlobalErr;
byte dht_dat[5];
byte btnPrev = HIGH;
boolean bBtnSt = false;

byte bytPre0 = 0;
byte bytPre1 = 0;
byte bytPre2 = 0;

void InitDHT() {
  pinMode(DHpin, OUTPUT);
  digitalWrite(DHpin, HIGH);
}

byte read_dht_dat() {
  byte data = 0;
  int timeout;

  for ( int i = 0; i < 8; i++ ) {
    if ( digitalRead(DHpin) == LOW ) {  // Detect start-signal
      // wait start-signal end (at most 200us though)
      timeout = 20;
      while ( digitalRead(DHpin) == LOW && timeout > 0 ) {
        delayMicroseconds(10);
        timeout--;
      }
      if ( timeout <= 0 ) // Timeout
        break;

      delayMicroseconds(30);  // < 30us -> bitset: 0
      if ( digitalRead(DHpin) == HIGH ) {
        // > 30us -> bitset: 1
        //data |= (1 << (7 - i));
        bitSet(data, 7 - i);
      }

      timeout = 20;
      // Wait for next bit (at most 200us though)
      while ( digitalRead(DHpin) == HIGH && timeout > 0 ) {
        delayMicroseconds(10);
        timeout--;
      }
    }
  }

  return data;
}

/*
byte read_dht_dat() {
  byte i = 0;
  byte result = 0;
  for (i = 0; i < 8; i++) {
    while (digitalRead(DHpin) == LOW);
    delayMicroseconds(30);
    if (digitalRead(DHpin) == HIGH)
      result |= (1 << (7 - i));
    while (digitalRead(DHpin) == HIGH);
  }
  return result;
}
*/

void ReadDHT() {
  bGlobalErr = 0;
  byte dht_in;
  byte i;

  pinMode(DHpin, OUTPUT);
  digitalWrite(DHpin, LOW);
  delay(20);    // must larger than 18ms

  digitalWrite(DHpin, HIGH);
  delayMicroseconds(40);  // Wait DHT11 Response

  pinMode(DHpin, INPUT);    // Ready to receive data
  //delayMicroseconds(40);
  dht_in = digitalRead(DHpin);
  if ( dht_in ) {
    bGlobalErr = 1;
    return;
  }

  delayMicroseconds(80);
  dht_in = digitalRead(DHpin);

  if ( !dht_in ) {
    bGlobalErr = 2;
    return;
  }

  delayMicroseconds(80);
  for ( i = 0; i < 5; i++ )
    dht_dat[i] = read_dht_dat();

  pinMode(DHpin, OUTPUT);
  digitalWrite(DHpin, HIGH);
  byte dht_check_sum = dht_dat[0] + dht_dat[1] + dht_dat[2] + dht_dat[3];
  if ( dht_dat[4] != dht_check_sum ) {
    bGlobalErr = 3;
  }
}

void setup() {
  // initialize the ledPin as an output:
  pinMode(ledpin, OUTPUT);
  pinMode(leddim, OUTPUT);
  pinMode(redpin, OUTPUT);
  pinMode(greenpin, OUTPUT);
  pinMode(bluepin, OUTPUT);
  pinMode(colorPin, OUTPUT);
  pinMode(boardLedPin, OUTPUT);
  pinMode(btnPin, INPUT);
  pinMode(beatPin, INPUT);
  
  // initialize DHT Temperature and humidity
  InitDHT();

  // initialize the serial communication:
  Serial.begin(9600);

  delay(500);
}

void loop() {
  int val;
  int degree;
  byte brightness;
  bool beatH;

  beatH = (digitalRead(beatPin) == LOW);
  
  // 1: photoresistor control LED
  // read the photoresistor voltage:
  val = analogRead(potpin);

  // map voltage to brightness level
  degree = map(val, 0, 400, 0, 10);
  if ( degree <= 2 )
    degree = 0;

  // for debug
  //Serial.println(degree);

  // set LED brightness according to the photoresistor
  analogWrite(ledpin, degree * 25);

  // 2. Dimmer with mouse
  // check if data has been sent from the computer:
  if (Serial.available()) {
    // read the most recent byte (which will be from 0 to 255):
    brightness = Serial.read();
    // set the brightness of the LED:
    analogWrite(leddim, brightness);

    bytPre0 = bytPre1;
    bytPre1 = bytPre2;
    bytPre2 = brightness;
  }

  // 3. Tri-color led: change color once a time
  analogWrite(redpin, bColorR);
  analogWrite(greenpin, bColorG);
  analogWrite(bluepin, bColorB);
  //Serial.println(bRGB);
  if ( bColorB-- == 0 )
    if ( bColorR-- == 0 )
      bColorG--;

  // 4. Get temperature and humidity, print to serial
  if ( bGlobalTimer % 100 == 0 ) {
    ReadDHT();
    switch ( bGlobalErr ) {
      case 0:     // Correct
        // "{'DAT': {}}“
        Serial.print("DAT: Humidity: ");
        Serial.print(dht_dat[0], DEC);
        Serial.print(".");
        Serial.print(dht_dat[1], DEC);
        Serial.print("% Temperature: ");
        Serial.print(dht_dat[2], DEC);
        Serial.print(".");
        Serial.print(dht_dat[3], DEC);
        Serial.println("C ");
        break;
      case 1:
        // "{'ERR': {'code':'1', 'type':'DHT', 'level':'4', 'msg':'DHT start condition 1 not met'}}"
        Serial.println("ERR 1: DHT start condition 1 not met");
        break;
      case 2:
        // "{'ERR': {'code':'2', 'type':'DHT', 'level':'4', 'msg':'DHT start condition 2 not met'}}"
        Serial.println("ERR 2: DHT start condition 2 not met");
        break;
      case 3:
        // "{'ERR': {'code':'3', 'type':'DHT', 'level':'3', 'msg':'DHT checksum error'}}"
        Serial.println("ERR 3: DHT checksum error");
        break;
      default:
        // "{'ERR': {'code':'unknown', 'type':'DHT', 'level':'5', 'msg':'unknown error'}}"
        Serial.println("ERR: unknown error");
        break;
    }

    if ( bGlobalErr != 0 )
      InitDHT();
  }

  // 5. Change multi-color LED
  /// Soft switch
  if( bytPre0 == 255 && bytPre1 == 0 ) {
    bBtnSt = !bBtnSt;
    if( bBtnSt ) {
      digitalWrite(colorPin, HIGH);
    }
    else {
      digitalWrite(colorPin, LOW);
    }    
  }
  /// Hard switch
  byte btnCurSt = digitalRead(btnPin);
  if( btnCurSt == LOW && btnPrev == HIGH )
  {
    bBtnSt = !bBtnSt;
    if( bBtnSt ) {
      digitalWrite(colorPin, HIGH);
      Serial.println("ACT: SW1ON");
    }
    else {
      digitalWrite(colorPin, LOW);
      Serial.println("ACT: SW1OFF");
    }    
  }
  btnPrev = btnCurSt;

  // 6. Beat sensor reflects on boardLed
  if( !beatH ) {
    beatH = (digitalRead(beatPin) == LOW);
  }
  delay(5);
  if( !beatH ) {
    beatH = (digitalRead(beatPin) == LOW);
  }
  
  if( beatH ) {
    digitalWrite(boardLedPin, HIGH);   // Light on
    Serial.println("ACT: beat");
    bBeatOnTimer = 50;    
  } else if( bBeatOnTimer == 0 ) {
    digitalWrite(boardLedPin, LOW);   // Light off
  } else {
    bBeatOnTimer--;
  }

  bGlobalTimer++;
  delay(5);
}
