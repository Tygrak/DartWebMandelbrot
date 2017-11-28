import 'dart:html';
import 'dart:math';
import 'mathextensions.dart';

CanvasElement canvas;
ButtonElement button;
ButtonElement buttonRemake;
CanvasRenderingContext2D ctx;
double x = 0.0;
double y = 0.0;
double zoom = 100.0;
double timeScale = 0.01;
num updateTimer = 40;
num lastTimeStamp = 0;
int pointSize = 2;
Random rand = new Random();
String backgroundColor = "173, 217, 230";
String pointsColor = "4, 4, 38";
double fadealpha = 0.05;
num drawLine = 1;
int dimensions = 1;

double ro = 28.0;
double omega = 10.0;
double beta = 2.66666666;
double px = 0.1;
double py = 0.1;
double pz = 0.1;

void main(){
  canvas = querySelector("#canvas");
  ctx = canvas.getContext("2d");
  button = querySelector("#regeneratebutton");
  button.addEventListener("click", Regenerate);
  buttonRemake = querySelector("#restartbutton");
  buttonRemake.addEventListener("click", Remake);
  Regenerate("");
  Run();
}

void Move(){
  double xMove = omega*(py-px);
  double yMove = px*(ro-pz)-py;
  double zMove = px*py-beta*pz;
  px = px + xMove*timeScale;
  py = py + yMove*timeScale;
  pz = pz + zMove*timeScale;
  //print("x: $px, y: $py, z: $pz");
}

void Regenerate(e){
  SelectElement selectElement = querySelector("[name=dimensions]");
  if (selectElement.value == "xy"){
    dimensions = 1;
  } else if (selectElement.value == "xz"){
    dimensions = 2;
  } else if (selectElement.value == "yz"){
    dimensions = 3;
  }
  InputElement element = querySelector("[name=zoom]");
  zoom = double.parse(element.value);
  element = querySelector("[name=timescale]");
  timeScale = double.parse(element.value);
  element = querySelector("[name=pointsize]");
  pointSize = int.parse(element.value);
  element = querySelector("[name=drawline]");
  drawLine = num.parse(element.value);
  element = querySelector("[name=fadealpha]");
  fadealpha = double.parse(element.value);
  element = querySelector("[name=backgroundcolor]");
  backgroundColor = element.value;
  element = querySelector("[name=pointscolor]");
  pointsColor = element.value;
  ctx.fillStyle = "rgb($backgroundColor)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

void Remake(e){
  InputElement element = querySelector("[name=ro]");
  ro = double.parse(element.value);
  element = querySelector("[name=omega]");
  omega = double.parse(element.value);
  element = querySelector("[name=beta]");
  beta = double.parse(element.value);
  element = querySelector("[name=startx]");
  px = double.parse(element.value);
  element = querySelector("[name=starty]");
  py = double.parse(element.value);
  element = querySelector("[name=startz]");
  pz = double.parse(element.value);
  Regenerate("e");
  ctx.fillStyle = "rgb($backgroundColor)";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
}

void Run(){
  window.animationFrame.then(Update);
}

void Update(num time){
  num delta = time - lastTimeStamp;
  if (delta > updateTimer){
    lastTimeStamp = time;
    ctx.fillStyle = "rgba($backgroundColor, $fadealpha)";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.beginPath();
    int pX;
    int pY;
    if (dimensions == 1){
      pX = MapToRange(px, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
      pY = MapToRange(py, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    } else if (dimensions == 2){
      pX = MapToRange(px, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
      pY = MapToRange(pz, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    } else if (dimensions == 3){
      pX = MapToRange(py, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
      pY = MapToRange(pz, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    }
    ctx.moveTo(pX, pY);
    Move();
    if (dimensions == 1){
      pX = MapToRange(px, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
      pY = MapToRange(py, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    } else if (dimensions == 2){
      pX = MapToRange(px, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
      pY = MapToRange(pz, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    } else if (dimensions == 3){
      pX = MapToRange(py, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
      pY = MapToRange(pz, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    }
    ctx.fillStyle = "rgb($pointsColor)";
    ctx.strokeStyle = "rgb($pointsColor)";
    ctx.lineWidth = pointSize * drawLine;
    ctx.fillRect(pX-pointSize~/2, pY-pointSize~/2, pointSize, pointSize);
    ctx.lineTo(pX, pY);
    ctx.closePath();
    if (drawLine != 0) ctx.stroke();
  }
  Run();
}