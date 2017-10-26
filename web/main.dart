import 'dart:html';
import 'dart:math';

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

class Complex {
  double _r,_i;
 
  Complex(this._r,this._i);
  double get r => _r;
  double get i => _i;
  String toString() => "($r,$i)";
 
  Complex operator +(Complex other) => new Complex(r+other.r,i+other.i);
  Complex operator *(Complex other) => new Complex(r*other.r-i*other.i,r*other.i+other.r*i);
  double abs() => r*r+i*i;
}

void main() {
  canvas = querySelector("#canvas");
  button = querySelector("#calculatebutton");
  redrawButton = querySelector("#redrawbutton");
  canvas.onClick.listen(CanvasClicked);
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
  Regenerate();
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

void RedrawButtonClicked(e){
  Regenerate();
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

void DrawSet(double start_x, double start_y, double zoom){
  print("r: $r, i: $i, zoom: $zoom");
  double step_x = zoom/(canvas.width as double);
  double step_y = zoom/(canvas.height as double);

  InputElement element = querySelector("[name=iterations]");
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
        z = z*(z)+c;
        if (z.abs()>4.2){
          break;
        }
      }
      if (colorMode == 1){
        if (i == iterations){
          ctx.fillStyle = "black";
        } else if (i > 1){
          int a = ((i/iterations)*255.0).toInt();
          ctx.fillStyle = "rgb(0, $a, 98)";
        } else{
          ctx.fillStyle = "rgb(0, 0, 98)";
        }
      } else if (colorMode == 2){
        if (i == iterations){
          ctx.fillStyle = "rgb(0, 10, 0)";
        } else if (i > 1){
          int a = ((i/iterations)*255.0).toInt();
          ctx.fillStyle = "rgb(${a~/2}, 10, $a)";
        } else{
          ctx.fillStyle = "rgb(0, 10, 0)";
        }
      } else if (colorMode == 3){
        if (i == iterations){
          ctx.fillStyle = "hsl(360, 0%, 5%)";
        } else{
          int a = (sin(i/(iterations/6))*360.0).toInt();
          int b = (cos(i/(iterations/4))*100.0).toInt();
          int c = (i/iterations*100.0).toInt();
          ctx.fillStyle = "hsl(${360-a}, $b%, ${25+c}%)";
        }
      } else if (colorMode == 4){
        if (i == iterations){
          ctx.fillStyle = "hsl(180, 10%, 5%)";
        } else{
          int a = (i/iterations*360.0).toInt();
          int b = 10+((i/iterations)*90.0).toInt();
          ctx.fillStyle = "hsl($a, $b%, ${25+b~/2}%)";
        }
      } else{
        if (i == iterations){
          ctx.fillStyle = "black";
        } else{
          int a = ((i/iterations)*200.0).toInt();
          ctx.fillStyle = "rgb(${55+a}, ${55+a}, ${55+a})";
        }
      }
      ctx.fillRect(x, y, 1, 1); //hsl(195, 53%, 79%)
    }
  }
}

double abs(double val) => val > 0 ? val : -val;