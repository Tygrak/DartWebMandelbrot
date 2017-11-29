import 'dart:html';
import 'dart:math';
import 'mathextensions.dart';

CanvasElement canvas;
CanvasRenderingContext2D ctx;
int colorMode = 1;
double r = -0.5;
double i = 0.0;
double zoom = 4.0;
bool autoIterations = true;
double autoIterationsAccuracy = 1.6;
int complexFunction = 1;
int iterationsAmount = 0;

void main() {
  canvas = querySelector("#canvas");
  canvas.onClick.listen(CanvasClicked);
  ctx = canvas.getContext("2d");
  if (Uri.base.queryParameters['c'] != "" && Uri.base.queryParameters['c'] != null){
    print("Colormode: ${Uri.base.queryParameters['c']}");
    colorMode = int.parse(Uri.base.queryParameters['c']);
  }
  if (Uri.base.queryParameters['f'] != "" && Uri.base.queryParameters['f'] != null){
    print("Function: ${Uri.base.queryParameters['f']}");
    complexFunction = int.parse(Uri.base.queryParameters['f']);
  }
  if (Uri.base.queryParameters['i'] != "" && Uri.base.queryParameters['i'] != null){
    print("Function: ${Uri.base.queryParameters['i']}");
    iterationsAmount = int.parse(Uri.base.queryParameters['i']);
  }
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

void DrawSet(double start_x, double start_y, double zoom){
  print("r: $r, i: $i, zoom: $zoom");
  double ratio = canvas.width/canvas.height;
  double step_x = zoom/(canvas.width as double)*ratio;
  double step_y = zoom/(canvas.height as double);

  int iterations;
  if (!autoIterations){
    iterations = iterationsAmount;
  } else{
    double d = sqrt(0.001+2.0 * zoom);
    iterations = (223.0/(d*autoIterationsAccuracy)).floor()+60;
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