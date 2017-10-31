import 'dart:html';
import 'dart:math';

CanvasElement canvas;
ButtonElement button;
CanvasRenderingContext2D ctx;
double x = 0.0;
double y = 0.0;
double zoom = 6.0;
double timeScale = 0.05;
num updateTimer = 40;
num lastTimeStamp = 0;
int pointSize = 2;
int drawLine = 0;
Random rand = new Random();
String backgroundColor = "173, 217, 230";
String pointsColor = "4, 4, 38";
double fadealpha = 0.05;

const double g = 9.81;
const double degtorad = 0.01745329;
double theta1 = 120.0*degtorad;
double theta2 = -10.0*degtorad;
double avelocity1 = 0.0;
double avelocity2 = 0.0;
double length1 = 1.0;
double length2 = 1.0;
double mass1 = 1.0;
double mass2 = 1.0;


void main(){
  canvas = querySelector("#canvas");
  ctx = canvas.getContext("2d");
  button = querySelector("#regeneratebutton");
  button.addEventListener("click", Regenerate);
  Regenerate("");
  Run();
}

void Move(){
  double dtheta1 = avelocity1;
  double dtheta2 = avelocity2;
  double angleDif = theta2-theta1;
  double den1 = (mass1 + mass2)*length1 - mass2*length1*cos(angleDif)*cos(angleDif);
  double davelocity1 = (mass2*length1*avelocity1*avelocity1*sin(angleDif)*cos(angleDif) +
               mass2*g*sin(theta2)*cos(angleDif) +
               mass2*length2*avelocity2*avelocity2*sin(angleDif) -
               (mass1 + mass2)*g*sin(theta1))/den1;
  double den2 = (length2/length1)*den1;
  double davelocity2 = (-mass2*length2*avelocity2*avelocity2*sin(angleDif)*cos(angleDif) +
               (mass1 + mass2)*g*sin(theta1)*cos(angleDif) -
               (mass1 + mass2)*length1*avelocity1*avelocity1*sin(angleDif) -
               (mass1 + mass2)*g*sin(theta2))/den2;
  theta1 += dtheta1*timeScale;
  theta2 += dtheta2*timeScale;
  avelocity1 += davelocity1*timeScale;
  avelocity2 += davelocity2*timeScale;
  avelocity1 *= 0.999;
  avelocity2 *= 0.999;
}

void Regenerate(e){
  InputElement element = querySelector("[name=angle1]");
  theta1 = double.parse(element.value)*degtorad;
  element = querySelector("[name=angle2]");
  theta2 = double.parse(element.value)*degtorad;
  element = querySelector("[name=mass1]");
  mass1 = double.parse(element.value);
  element = querySelector("[name=mass2]");
  mass2 = double.parse(element.value);
  element = querySelector("[name=length1]");
  length1 = double.parse(element.value);
  element = querySelector("[name=length2]");
  length2 = double.parse(element.value);
  element = querySelector("[name=timescale]");
  timeScale = double.parse(element.value);
  element = querySelector("[name=pointsize]");
  pointSize = int.parse(element.value);
  element = querySelector("[name=drawline]");
  drawLine = int.parse(element.value);
  element = querySelector("[name=fadealpha]");
  fadealpha = double.parse(element.value);
  element = querySelector("[name=backgroundcolor]");
  backgroundColor = element.value;
  element = querySelector("[name=pointscolor]");
  pointsColor = element.value;
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
    Move();
    double pointx = 0.0;
    double pointy = 0.0;
    int pX = Map(pointx, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
    int pY = Map(pointy, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    ctx.fillStyle = "rgb($pointsColor)";
    ctx.fillRect(pX-pointSize~/2, pY-pointSize~/2, pointSize, pointSize);
    ctx.beginPath();
    ctx.strokeStyle = "rgb($pointsColor)";
    ctx.lineWidth = pointSize;
    ctx.moveTo(pX, pY);
    pointx = (cos(theta1-4.712389)*length1);
    pointy = (sin(theta1-4.712389)*length1);
    pX = Map(pointx, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
    pY = Map(pointy, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    ctx.fillStyle = "rgb($pointsColor)";
    ctx.fillRect(pX-pointSize~/2, pY-pointSize~/2, pointSize, pointSize);
    ctx.lineTo(pX, pY);
    ctx.closePath();
    if (drawLine != 0) ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(pX, pY);
    pointx = pointx + (cos(theta2-4.712389)*length2);
    pointy = pointy + (sin(theta2-4.712389)*length2);
    pX = Map(pointx, x-zoom/2, x+zoom/2, 0.0, canvas.width as double).toInt();
    pY = Map(pointy, y-zoom/2, y+zoom/2, 0.0, canvas.height as double).toInt();
    ctx.fillStyle = "rgb($pointsColor)";
    ctx.fillRect(pX-pointSize~/2, pY-pointSize~/2, pointSize, pointSize);
    ctx.lineTo(pX, pY);
    ctx.closePath();
    if (drawLine != 0) ctx.stroke();
  }
  Run();
}

double Map(double value, double min1, double max1, double min2, double max2){
  if (max1-min1 != 0){
    value = (value-min1)/(max1-min1) * (max2-min2) + min2;
    return value;
  }
  throw new Exception("Map min1 and max1 are equal!");
}