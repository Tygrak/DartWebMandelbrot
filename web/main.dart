import 'dart:html';

CanvasElement canvas;
ButtonElement button;
CanvasRenderingContext2D ctx;
double r = -0.5;
double i = 0.0;
double zoom = 2.0;

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
  canvas.onClick.listen(CanvasClicked);
  button.addEventListener("click", ButtonClicked);
  ctx = canvas.getContext("2d");
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

void CanvasClicked(e){
  int x = e.client.x - ctx.canvas.getBoundingClientRect().left;
  int y = e.client.y - ctx.canvas.getBoundingClientRect().top;
  r = r-zoom/2+(zoom/canvas.width)*x;
  i = i-zoom/2+(zoom/canvas.height)*y;
  zoom = zoom*0.75;
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

void ButtonClicked(e){
  InputElement element = querySelector("[name=x]");
  r = double.parse(element.value);
  element = querySelector("[name=y]");
  i = double.parse(element.value);
  element = querySelector("[name=zoom]");
  zoom = double.parse(element.value);
  DrawSet(r-zoom/2, i-zoom/2, zoom);
}

void DrawSet(double start_x, double start_y, double zoom){
  print("r: $r, i: $i, zoom: $zoom");
  double step_x = zoom/(canvas.width as double);
  double step_y = zoom/(canvas.height as double);

  InputElement element = querySelector("[name=iterations]");
  int iterations = int.parse(element.value);

  for (var x = 0; x < canvas.width; x++){
    for (var y = 0; y < canvas.height; y++){
      Complex c = new Complex(start_x+step_x*x,start_y+step_y*y);
      Complex z = new Complex(0.0, 0.0);
      int i = 0;
      for (i = 0; i < iterations; i++){
        z = z*(z)+c;
        if (z.abs()>2){
          break;
        }
      }
      if (i == iterations){
        ctx.fillStyle = "black";
      } else if(i > 1){
        int a = ((i/iterations)*255.0).toInt();
        ctx.fillStyle = "rgb(0, $a, 98)";
      } else{
        ctx.fillStyle = "rgb(0, 0, 98)";
      }
      ctx.fillRect(x, y, 1, 1);
    }
  }
}