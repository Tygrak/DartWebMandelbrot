import 'dart:html';
import 'dart:math';
import 'dart:collection';

CanvasElement canvas;
ButtonElement button;
ButtonElement redrawButton;
CanvasRenderingContext2D ctx;
int colorMode = 1;
double r = 0.0;
double i = 0.0;
double zoom = 4.0;
double a = 1.0;
String newtonFunction = "z pow3 1 -";
String newtonDerivate = "z pow2 3 *";
List<Complex> roots = new List<Complex>();

int lX = 0;
num lastTimeStamp = 0;
num updateTimer = 5;

class Complex {
  double _r,_i;
 
  Complex(this._r,this._i);
  double get r => _r;
  double get i => _i;
  int get hashCode => ((17 * r) * 31 + i).floor();
  String toString() => "($r,$i)";
 
  Complex operator +(Complex other) => new Complex(r+other.r,i+other.i);
  Complex operator -(Complex other) => new Complex(r-other.r,i-other.i);
  Complex operator *(Complex other) => new Complex(r*other.r-i*other.i,r*other.i+other.r*i);
  Complex operator /(Complex other) => _Divide(other);
  bool operator ==(Complex other) => (r == other.r) && (i == other.i);
  Complex _Divide (Complex other){
    double temp = other.r*other.r + other.i*other.i;
    if (temp == 0){
      return new Complex(0.0, 0.0);
      //throw new Exception("Complex division leads to division by zero.");
    }
    return new Complex((r*other.r + i*other.i)/temp, (i*other.r - r*other.i)/temp);
  }
  Complex pow (int toPow){
    Complex val = this;
    for (var i = 0; i < toPow; i++) {
      val = val * this;
    }
    return val;
  }
  Complex timesConst (num constant){
    return new Complex(r*constant, i*constant);
  }
    
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
  Run();
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
  Run();
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
  lX = 0;
}

void ButtonClicked(e){
  InputElement element = querySelector("[name=x]");
  r = double.parse(element.value);
  element = querySelector("[name=y]");
  i = double.parse(element.value);
  element = querySelector("[name=zoom]");
  zoom = double.parse(element.value);
  element = querySelector("[name=a]");
  a = double.parse(element.value);
  element = querySelector("[name=newton]");
  newtonFunction = element.value;
  element = querySelector("[name=newtonderivate]");
  newtonDerivate = element.value;
  roots = new List<Complex>();
  RedrawButtonClicked("e");
}

void RedrawButtonClicked(e){
  Regenerate();
  Run();
}

void Run(){
  window.animationFrame.then(UpdateSet);
}

void UpdateSet(num time){
  num delta = time - lastTimeStamp;
  if (delta > updateTimer){
    lastTimeStamp = time;
    DrawSet(r-zoom/2, i-zoom/2, zoom);
  }
  if (lX != canvas.width){
    Run();
  }
}

void DrawSet(double start_x, double start_y, double zoom){
  print("r: $r, i: $i, zoom: $zoom");
  double step_x = zoom/(canvas.width as double);
  double step_y = zoom/(canvas.height as double);

  InputElement element = querySelector("[name=iterations]");
  int iterations = int.parse(element.value);
  for (var x = lX; x < canvas.width; x++){
    for (var y = 0; y < canvas.height; y++){
      Complex z = new Complex(start_x+step_x*x, start_y+step_y*y);
      int i = 0;
      for (i = 0; i < iterations; i++){
        z = z-(((z*z*z*z*z*z)-new Complex(1.0, 0.0))/(z*z*z*z*z*new Complex(5.0, 0.0))).timesConst(a);
        //z = z-((GetEquationValue(z, newtonFunction))/(GetEquationValue(z, newtonDerivate))).timesConst(a);
      }
      z = new Complex((z.r*100).floor()/100, (z.i*100).floor()/100);
      if (z.r == 0 && z.i == 0){
        ctx.fillStyle = "rgb(0, 0, 0)";
      } else{ 
        if (roots.firstWhere((Complex v) => v == z, orElse: () => null) == null){
          print(z);
          roots.add(z);
        }
        int index = roots.indexOf(roots.firstWhere((Complex v) => v == z, orElse: () => null));
        if (colorMode == 1){
          ctx.fillStyle = "rgb(${(255~/3)*(index%3)}, ${(255~/51)*index}, 150)";
        } else if (colorMode == 2){
          ctx.fillStyle = "rgb(${((255~/17)*index)~/2}, 10, ${(255~/3)*(index%3)})";
        } else if (colorMode == 3){
          ctx.fillStyle = "hsl(${(360~/12)*index}, 30%, 20%)";
        } else if (colorMode == 4){
          ctx.fillStyle = "hsl(${(360~/12)*(12-index)}, 50%, 30%)";
        } else{
          ctx.fillStyle = "rgb(${(255~/17)*(index)}, ${(255~/17)*(index)}, ${(255~/17)*(index)})";
        }
      }
      ctx.fillRect(x, y, 1, 1); //hsl(195, 53%, 79%)
    }
    if (lX < x-1){
      lX = x;
      return;
    }
  }
  lX = canvas.width;
}

Complex GetEquationValue(Complex z, String equation){
  Queue<Complex> stack = new Queue<Complex>();
  List<String> values = equation.split(" ");
  for (var i = 0; i < values.length; i++){
    num value;
    try{
      value = num.parse(values[i]);
      stack.add(new Complex(value, 0.0));
    } catch (e){
      try{
        value = num.parse(values[i].substring(0, values[i].length-2));
        stack.add(new Complex(0.0, value));
      } catch (e){
      }
    }
    if (values[i] == "z"){
      stack.add(z);
    } else if (values[i] == "-z"){
      stack.add(new Complex(-z.r, -z.i));
    } else if (values[i] == "+"){
      Complex last = stack.removeLast();
      stack.add(stack.removeLast()+last);
    } else if (values[i] == "-"){
      Complex last = stack.removeLast();
      stack.add(stack.removeLast()-last);
    } else if (values[i] == "*"){
      Complex last = stack.removeLast();
      stack.add(stack.removeLast()*last);
    } else if (values[i] == "/"){
      Complex last = stack.removeLast();
      stack.add(stack.removeLast()/last);
    } else if (values[i].startsWith("pow")){
      Complex last = stack.removeLast();
      stack.add(last.pow(int.parse(values[i].substring(3))));
    }
    //print(stack);
  }
  return stack.removeLast();
}

double abs(double val) => val > 0 ? val : -val;