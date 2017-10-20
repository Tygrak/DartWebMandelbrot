import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'package:image/image.dart';

const DEG2RAD = PI/180;

CanvasElement canvas;
ButtonElement button;
CanvasRenderingContext2D ctx;
Image image;
List<Point> points = [new Point(0.1, 0.1)];
int pointSize = 2;
Random rand = new Random();
Map<String, String> rules = new Map<String, String>();
Map<String, String> constants = new Map<String, String>();
int iterations = 5;
int x = 300;
int y = 590;
num startrot = 270; 
String axiom = "a";
String bgColor = "173, 217, 230";
String fgColor = "4, 4, 38";
int drawColor;

void main(){
  canvas = querySelector("#canvas");
  ctx = canvas.context2D;
  button = querySelector("#regeneratebutton");
  button.addEventListener("click", Regenerate);
  Regenerate("");
}

void Regenerate(e){
  rules.clear();
  InputElement element = querySelector("[name=axiom]");
  axiom = element.value;
  element = querySelector("[name=iterations]");
  iterations = int.parse(element.value);
  element = querySelector("[name=startx]");
  x = int.parse(element.value);
  element = querySelector("[name=starty]");
  y = int.parse(element.value);
  element = querySelector("[name=startrot]");
  startrot = num.parse(element.value);
  element = querySelector("[name=rule1]");
  if (element.value != "") AddRule(element.value);
  element = querySelector("[name=rule2]");
  if (element.value != "") AddRule(element.value);
  element = querySelector("[name=rule3]");
  if (element.value != "") AddRule(element.value);
  element = querySelector("[name=rule4]");
  if (element.value != "") AddRule(element.value);
  element = querySelector("[name=const1]");
  if (element.value != "") AddConstant(element.value);
  element = querySelector("[name=const2]");
  if (element.value != "") AddConstant(element.value);
  element = querySelector("[name=backgroundcolor]");
  bgColor = element.value;
  element = querySelector("[name=foregroundcolor]");
  fgColor = element.value;
  image = new Image(canvas.width, canvas.height);
  int index1 = bgColor.indexOf(",");
  int index2 = bgColor.indexOf(",", index1+1);
  drawColor = Color.fromRgb(int.parse(bgColor.substring(0, index1)), 
                            int.parse(bgColor.substring(index1+2, index2)), 
                            int.parse(bgColor.substring(index2+2)));
  image.fill(drawColor);
  index1 = fgColor.indexOf(",");
  index2 = fgColor.indexOf(",", index1+1);
  drawColor = Color.fromRgb(int.parse(fgColor.substring(0, index1)), 
                            int.parse(fgColor.substring(index1+2, index2)), 
                            int.parse(fgColor.substring(index2+2)));
  DrawSystem(GenerateString());
}

void AddRule(String rule){
  String key = rule.substring(0, rule.indexOf(" "));
  String value = rule.substring(rule.indexOf("=")+2);
  rules[key] = value;
}

void AddConstant(String constant){
  String key = constant.substring(0, constant.indexOf(" "));
  String value = constant.substring(constant.indexOf("=")+2);
  constants[key] = value;
}

List<String> GenerateString(){
  List<String> out = axiom.split(" ");
  List<String> newOut;
  int breaker = 0;
  print(out.join(" "));
  for (var i = 0; i < iterations; i++){
    newOut = new List<String>();
    for (var j = 0; j < out.length; j++) {
      breaker++;
      if (rules.containsKey(out[j])){
        String toAdd = rules[out[j]];
        newOut.addAll(toAdd.split(" "));
      } else{
        newOut.add(out[j]);
      }
      if (breaker > 1000000){
        print("error max iterations limit reached");
        return out;
      }
    }
    out = newOut;
    print(out.join(" "));
  }
  newOut = new List<String>();
  for (var j = 0; j < out.length; j++) {
    if (constants.containsKey(out[j])){
      String toAdd = constants[out[j]];
      newOut.addAll(toAdd.split(" "));
    } else{
      newOut.add(out[j]);
    }
  }
  out = newOut;
  print("Finished: " + out.join(" "));
  return out;
}

void DrawSystem(List<String> generated){
  print("Drawing");
  Queue<Point> positions = new Queue<Point>();
  int xPos = x;
  int yPos = y;
  num rotation = startrot;
  for (var j = 0; j < generated.length; j++) {
    if (generated[j].startsWith("F")){
      int distance = int.parse(generated[j].substring(1));
      int nxPos = xPos + (cos(rotation*DEG2RAD)*distance).round();
      int nyPos = yPos + (sin(rotation*DEG2RAD)*distance).round();
      drawLine(image, xPos, yPos, nxPos, nyPos, drawColor);
      xPos = nxPos;
      yPos = nyPos;
    } else if (generated[j].startsWith("T")){
      rotation += num.parse(generated[j].substring(1));
      if (rotation >= 360 || rotation < 0){
        rotation = rotation % 360;
      }
    } else if (generated[j] == "["){
      positions.add(new Point(new Point(xPos, yPos), rotation));
    } else if (generated[j] == "]"){
      Point p = positions.removeFirst();
      print(p);
      xPos = p.x.x;
      yPos = p.x.y;
      rotation = p.y;
    }
  }
  var imageData = ctx.createImageData(image.width, image.height);
  imageData.data.setRange(0, imageData.data.length, image.getBytes());
  ctx.putImageData(imageData, 0, 0);
}