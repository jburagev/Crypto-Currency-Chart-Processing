import java.util.*; 
import java.text.SimpleDateFormat;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int dateMin, dateMax;

PFont plotFont; 

JSONArray response;

float volumeInterval;

int startTimestamp = 0;

String dateX;
int startIndex = 150;
int dataBandwidth = 151;

float lowYaxis = 0.0;
float highYaxis = 0.0;

boolean locked = false;

String currencyPair;

float textY;

void setup() {
  size(1000, 600);
  cursor(HAND);
  
  currencyPair = "BTC_ETH"; // you can choose different currency pairs. Couple of supported pairs: BTC_ETH, USDT_LTC, BTC_LTC, BTC_DASH. See poloniex api for more..
  
  response = loadJSONArray("https://poloniex.com/public?command=returnChartData&currencyPair=" + currencyPair + "&start=1435699200&end=9999999999&period=86400");
    
   // JSONObject testObj = response.getJSONObject(185);
   // println(testObj);
    
  println("Response size = " + response.size());
  startIndex = response.size() - dataBandwidth;
  
  dateMin =  response.getJSONObject(startIndex).getInt("date");
  dateMax = dateMin + 13046400;
 
  // Corners of the plotted time series
  plotX1 = 120; 
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

  smooth();
}


void draw() {
  background(224);
  strokeWeight(2);
  // Show the plot area as a white box  
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);
  // add left and right pointers
  
  dateMin =  response.getJSONObject(startIndex).getInt("date");
  dateMax = dateMin + 13046400;
   
  // add left and right pointers
  Navigate();
  
  drawTitle();
  drawAxisLabels();
  drawDateLabels();
  drawPriceLabels();

  stroke(#5679C1);
  strokeWeight(5);

  drawDataLines();
  noFill();
  strokeWeight(0.5);

  drawDataHighlight();
}


void drawTitle() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = "Currency pair - " + currencyPair;
  text(title, plotX1, plotY1 - 10);
  textAlign(CENTER);
  text("Crypto currency chart by Jovan Buragev", 1000/2, 25);
  textSize(12);
  text("Navigate with mouse left and right button", 1000 - 200, 55);
}


void drawAxisLabels() {
  fill(0);
  textSize(13);
  textLeading(15);
  
  textAlign(CENTER, CENTER);
  text("Price", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Date", (plotX1+plotX2)/2, labelY);
}


void drawDateLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER);
  
  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);
  
  lowYaxis = 0;
  highYaxis = 0;
  
  int count = startIndex;
  startTimestamp = dateMin;
  for (int i = startTimestamp; i < dateMax; i = i + 86400) {
    
   
    java.util.Date d = new java.util.Date(i*1000L);
    dateX = new SimpleDateFormat("dd-MM-yyyy").format(new Date(i * 1000L));

    if(lowYaxis < response.getJSONObject(count).getFloat("low")){ 
      lowYaxis = response.getJSONObject(count).getFloat("low");
    }
    
    if(highYaxis < response.getJSONObject(count).getFloat("high")){
      highYaxis = response.getJSONObject(count).getFloat("high");
    }
    
    if (d.getDate() == 1 || count == 0) {
      float x = map(float(i), startTimestamp, dateMax, plotX1, plotX2);
      text(dateX, x, plotY2 + textAscent() + 10);
      line(x, plotY1, x, plotY2);
    }
    count++;
  }
}


void drawPriceLabels() {
  fill(0);
  textSize(10);
  textAlign(RIGHT);
  
  stroke(128);
  strokeWeight(1);
  volumeInterval = (highYaxis * 10) / 100;
  for (float v = 0; v <= highYaxis + ((highYaxis * 10) / 100) ; v += (highYaxis * 15) / 100) {
      float y = map(v, 0, highYaxis + ((highYaxis * 10) / 100), plotY2, plotY1);  
        float textOffset = textAscent()/2;  // Center vertically
        if (v == 0) {
          textOffset = 0;                   // Align by the bottom
        } else if (v == highYaxis + ((highYaxis * 10) / 100)) {
          textOffset = textAscent();        // Align by the top
        }
        text(v, plotX1 - 10, y + textOffset);
        line(plotX1 - 4, y, plotX1, y);     // Draw major tick
        stroke(224);
        line(plotX1, y, plotX2, y);
  }
}


void drawDataLines() {
  int currentStartX = startIndex; 
  for (int i = startTimestamp; i < dateMax; i = i + 86400) {
      float valueHigh = response.getJSONObject(currentStartX).getFloat("high");
      float valueLow = response.getJSONObject(currentStartX).getFloat("low");
      float x1 = map(i,startTimestamp, dateMax, plotX1, plotX2);

      float y1 = map(valueLow, 0, highYaxis + ((highYaxis * 10) / 100), plotY2, plotY1);
      float x2 = map(i,startTimestamp, dateMax, plotX1, plotX2);
      float y2 = map(valueHigh, 0, highYaxis + ((highYaxis * 10) / 100), plotY2, plotY1);

      strokeWeight(4);
      if(response.getJSONObject(currentStartX - 1).getFloat("weightedAverage") > response.getJSONObject(currentStartX).getFloat("weightedAverage")){
        stroke(178,34,34);
      }else{
        stroke(46,139,87);
      }
      line(x1, y1, x2, y2);
    currentStartX++;
  }
}


void drawDataHighlight() {
   
  int currentStartX = startIndex; 
  for (int i = startTimestamp; i < dateMax; i = i + 86400) {

      float valueHigh = response.getJSONObject(currentStartX).getFloat("high");
      float valueLow = response.getJSONObject(currentStartX).getFloat("low");

      float x = map(i,startTimestamp, dateMax, plotX1, plotX2);
      float y = map(valueHigh, 0, highYaxis + ((highYaxis * 10) / 100), plotY2, plotY1);
      if (mouseX >= x - 1 && mouseX <= x + 1) {
         java.util.Date d = new java.util.Date(i*1000L);
         String currentDatePosition = new SimpleDateFormat("dd-MM-yyyy").format(new Date(i * 1000L));
    
        strokeWeight(2);
        point(x, y);
        fill(0);
        stroke(126);
        line(x, plotY1, x, plotY2);
        textSize(15);
        textAlign(CENTER);
        if(y < 160){
          textY = y + 300;
        }else{
          textY = y;
        }
        fill(255);
        rect(x + 100,textY -115, x - 100, textY - 30);
        fill(0);
        text("High: " + valueHigh, x, textY-100);
        text("Low: " + valueLow,x, textY-85);
        text("Average: " + response.getJSONObject(currentStartX).getFloat("weightedAverage"),x, textY-70);
        text("Volume: " + response.getJSONObject(currentStartX).getFloat("volume"),x, textY-55);
        text("Date: " + currentDatePosition,x, textY-40);
        //text("x: " + currentStartX,x, y-50);

      }
    currentStartX++;
  }
}

void mousePressed() {
  
 locked = true;
}

void mouseReleased() {
  locked = false;
}

void Navigate(){

  if(locked == true && mouseButton == LEFT && startIndex > 1){
  
    startIndex--;
  }
  
  if(locked == true && mouseButton == RIGHT && startIndex + dataBandwidth < response.size()){
  
    startIndex++;
  }

}