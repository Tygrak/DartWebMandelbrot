import 'dart:html';
import 'dart:math';
import 'mathextensions.dart';

CanvasElement canvas;
ButtonElement button;
ButtonElement redrawButton;
CanvasRenderingContext2D ctx;
int colorMode = 1;
double r = -0.5;
double i = 0.0;
double zoom = 4.0;
bool autoIterations = true;
double autoIterationsAccuracy = 1.6;
int complexFunction = 1;

void main() {
  canvas = querySelector("#canvas");
  button = querySelector("#calculatebutton");
  redrawButton = querySelector("#redrawbutton");
  canvas.onClick.listen(CanvasClicked);
  canvas.onContextMenu.listen(CanvasRightClicked);
  button.addEventListener("click", ButtonClicked);
  redrawButton.addEventListener("click", RedrawButtonClicked);
  ctx = canvas.getContext("2d");
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

void CanvasClicked(e){
  int x = e.client.x - ctx.canvas.getBoundingClientRect().left;
  int y = e.client.y - ctx.canvas.getBoundingClientRect().top;
  r = r-zoom/2+(zoom/canvas.width)*x;
  i = i-zoom/2+(zoom/canvas.height)*y;
  InputElement element = querySelector("[name=x]");
  element.value = r.toString();
  element = querySelector("[name=y]");
  element.value = i.toString();
  zoom = zoom*0.75;
  element = querySelector("[name=zoom]");
  element.value = zoom.toString();
  Regenerate();
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

bool CanvasRightClicked(e){
  e.preventDefault();
  int x = e.client.x - ctx.canvas.getBoundingClientRect().left;
  int y = e.client.y - ctx.canvas.getBoundingClientRect().top;
  r = r-zoom/2+(zoom/canvas.width)*x;
  i = i-zoom/2+(zoom/canvas.height)*y;
  InputElement element = querySelector("[name=x]");
  element.value = r.toString();
  element = querySelector("[name=y]");
  element.value = i.toString();
  zoom = zoom*1.75;
  element = querySelector("[name=zoom]");
  element.value = zoom.toString();
  Regenerate();
  DrawSet(r-zoom/2, i-zoom/2, zoom);
  return false;
}

void Regenerate(){
  SelectElement selectElement = querySelector("[name=colorscheme]");
  if (selectElement.value == "grayscale"){
    colorMode = 0;
  } else if (selectElement.value == "color1"){
    colorMode = 1;
  } else if (selectElement.value == "color2"){
    colorMode = 2;
  } else if (selectElement.value == "color3"){
    colorMode = 3;
  } else if (selectElement.value == "color4"){
    colorMode = 4;
  } else if (selectElement.value == "color5"){
    colorMode = 5;
  } else if (selectElement.value == "color6"){
    colorMode = 6;
  }
  InputElement element = querySelector("[name=autoIterations]");
  autoIterations = element.checked;
  element = querySelector("[name=autoIterationsGrowth]");
  autoIterationsAccuracy = double.parse(element.value);
}

void ButtonClicked(e){
  InputElement element = querySelector("[name=x]");
  r = double.parse(element.value);
  element = querySelector("[name=y]");
  i = double.parse(element.value);
  element = querySelector("[name=zoom]");
  zoom = double.parse(element.value);
  SelectElement selectElement = querySelector("[name=complexfunction]");
  if (selectElement.value == "func1"){
    complexFunction = 1;
  } else if (selectElement.value == "func2"){
    complexFunction = 2;
  } else if (selectElement.value == "func3"){
    complexFunction = 3;
  } else if (selectElement.value == "func4"){
    complexFunction = 4;
  } else if (selectElement.value == "func5"){
    complexFunction = 5;
  } else if (selectElement.value == "func6"){
    complexFunction = 6;
  } else if (selectElement.value == "func7"){
    complexFunction = 7;
  } else if (selectElement.value == "func8"){
    complexFunction = 8;
  } else if (selectElement.value == "func9"){
    complexFunction = 9;
  }
  Regenerate();
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

void RedrawButtonClicked(e){
  Regenerate();
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

void DrawSet(double start_x, double start_y, double zoom){
  InputElement element = querySelector("[name=iterations]");
  print("r: $r, i: $i, zoom: $zoom");
  print("${Uri.base.origin}${Uri.base.path}?r=${r}&i=${i}&iter=${element.value}&c=${colorMode}&f=${complexFunction}");

  double step_x = zoom/(canvas.width as double);
  double step_y = zoom/(canvas.height as double);

  int iterations;
  if (!autoIterations){
    iterations = int.parse(element.value);
  } else{
    double d = sqrt(0.001+2.0 * zoom);
    iterations = (223.0/(d*autoIterationsAccuracy)).floor()+60;
    element.value = iterations.toString();
  }

  for (var x = 0; x < canvas.width; x++){
    for (var y = 0; y < canvas.height; y++){
      Complex c = new Complex(start_x+step_x*x,start_y+step_y*y);
      Complex z = new Complex(0.0, 0.0);
      int i = 0;
      for (i = 0; i < iterations; i++){
        if (complexFunction == 1){
          z = (z*z+c);
        } else if (complexFunction == 2){
          z = (z*z*z+c);
        } else if (complexFunction == 3){
          z = (z*z*z*z+c);
        } else if (complexFunction == 4){
          z = (z*z*z*z*z+c);
        } else if (complexFunction == 5){
          Complex zAbs = new Complex(z.r.abs(), z.i.abs());
          z = (zAbs*zAbs+c);
        } else if (complexFunction == 6){
          Complex zAbs = new Complex(z.r.abs(), z.i.abs());
          z = (zAbs*zAbs*zAbs+c);
        } else if (complexFunction == 7){
          Complex zAbs = new Complex(z.r.abs(), z.i.abs());
          z = (zAbs*zAbs*zAbs*zAbs+c);
        } else if (complexFunction == 8){
          Complex zAbs = new Complex(z.r.abs(), z.i.abs());
          z = (zAbs*zAbs*z+c);
        } else if (complexFunction == 9){
          z = (z*z+z+c);
        }
        if (z.abs()>4.2){
          break;
        }
      }
      if (colorMode == 1){
        if (i == iterations){
          ctx.fillStyle = "black";
        } else if (i > 1){
          int a = ((i/iterations)*255.0).round();
          ctx.fillStyle = "rgb(0, $a, 98)";
        } else{
          ctx.fillStyle = "rgb(0, 0, 98)";
        }
      } else if (colorMode == 2){
        if (i == iterations){
          ctx.fillStyle = "rgb(0, 10, 0)";
        } else if (i > 1){
          int a = ((i/iterations)*255.0).round();
          ctx.fillStyle = "rgb(${a~/2}, 10, $a)";
        } else{
          ctx.fillStyle = "rgb(0, 10, 0)";
        }
      } else if (colorMode == 3){
        if (i == iterations){
          ctx.fillStyle = "hsl(360, 0%, 5%)";
        } else{
          int a = (sin(i/(iterations/6))*360.0).round();
          int b = (cos(i/(iterations/4))*100.0).round();
          int c = (i/iterations*40.0).round();
          ctx.fillStyle = "hsl(${360-a}, $b%, ${25+c}%)";
        }
      } else if (colorMode == 4){
        if (i == iterations){
          ctx.fillStyle = "hsl(180, 10%, 5%)";
        } else{
          int a = (i/iterations*360.0).round();
          int b = 10+((i/iterations)*90.0).round();
          ctx.fillStyle = "hsl($a, $b%, ${25+b~/2}%)";
        }
      } else if (colorMode == 5){
        if (i == iterations){
          ctx.fillStyle = "rgb(0, 0, 0)";
        } else if (i > 1){
          int a = ((i/iterations)*255.0).round();
          ctx.fillStyle = "rgb(${a*0.85}, ${a+5}, ${a*2+30})";
        } else{
          ctx.fillStyle = "rgb(0, 5, 30)";
        }
      } else if (colorMode == 6){
        if (i == iterations){
          ctx.fillStyle = "rgb(0, 0, 0)";
        } else if (i > 1){
          int a = ((i/iterations)*255.0).round();
          a = ((pow(i, 1.15)/1019)*585).round();
          ctx.fillStyle = "rgb(${a*0.85}, ${a+5}, ${a*2+30})";
        } else{
          ctx.fillStyle = "rgb(0, 5, 30)";
        }
      } else{
        if (i == iterations){
          ctx.fillStyle = "black";
        } else{
          int a = ((i/iterations)*200.0).round();
          ctx.fillStyle = "rgb(${55+a}, ${55+a}, ${55+a})";
        }
      }
      ctx.fillRect(x, y, 1, 1); //hsl(195, 53%, 79%)
    }
  }
}