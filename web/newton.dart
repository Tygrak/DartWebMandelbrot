import 'dart:html';
import 'dart:math';
import 'dart:collection';

CanvasElement canvas;
ButtonElement button;
ButtonElement redrawButton;
CanvasRenderingContext2D ctx;
int colorMode = 1;
int newtonFunction = 1;
double r = 0.0;
double i = 0.0;
double zoom = 4.0;
double a = 1.0;
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
  Complex sin (){
    return (Pow(E, new Complex(0.0, 1.0)*this)-Pow(E, new Complex(0.0, -1.0)*this))/(new Complex(0.0, 1.0).timesConst(2));
  }
  Complex cos (){
    return (Pow(E, new Complex(0.0, 1.0)*this)+Pow(E, new Complex(0.0, -1.0)*this))/(new Complex(1.0, 0.0).timesConst(2));
  }
  double abs() => r*r+i*i;
}

Complex Pow(double n, Complex toPow){
  //12^(3 + 2 I) = 1728 cos(2 log(12)) + 1728 i sin(2 log(12))
  return new Complex(cos(toPow.i * log(n)), sin(toPow.i * log(n))).timesConst(pow(n, toPow.r));
}

/*Complex Pow(double n, Complex toPow){
  Complex rotated = new Complex(cos(toPow.i)*n, sin(toPow.i)*n);
  rotated = rotated.pow(toPow.r.toInt());
  return rotated;
}*/

void main() {
  canvas = querySelector("#canvas");
  button = querySelector("#calculatebutton");
  redrawButton = querySelector("#redrawbutton");
  canvas.onClick.listen(CanvasClicked);
  button.addEventListener("click", ButtonClicked);
  redrawButton.addEventListener("click", RedrawButtonClicked);
  ctx = canvas.getContext("2d");
  print("e**(pi*i) = ${Pow(E, new Complex(0.0, PI))}");
  print("sin(2+i) = ${new Complex(2.0, 1.0).sin()}");
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
  selectElement = querySelector("[name=newtonfunction]");
  if (selectElement.value == "func1"){
    newtonFunction = 1;
  } else if (selectElement.value == "func2"){
    newtonFunction = 2;
  } else if (selectElement.value == "func3"){
    newtonFunction = 3;
  } else if (selectElement.value == "func4"){
    newtonFunction = 4;
  } else if (selectElement.value == "func5"){
    newtonFunction = 5;
  } else if (selectElement.value == "func6"){
    newtonFunction = 6;
  } else if (selectElement.value == "func7"){
    newtonFunction = 7;
  } else if (selectElement.value == "func8"){
    newtonFunction = 8;
  } else if (selectElement.value == "func9"){
    newtonFunction = 9;
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
      try {
      Complex z = new Complex(start_x+step_x*x, start_y+step_y*y);
      int i = 0;
      if (newtonFunction == 1){
        for (i = 0; i < iterations; i++){
          z = z-(((z*z*z)-new Complex(1.0, 0.0))/(z*z*new Complex(3.0, 0.0))).timesConst(a);
        }
      } else if (newtonFunction == 2){
        for (i = 0; i < iterations; i++){
          z = z-(((z*z*z*z)-new Complex(1.0, 0.0))/(z*z*z*new Complex(4.0, 0.0))).timesConst(a);
        }
      }  else if (newtonFunction == 3){
        for (i = 0; i < iterations; i++){
          z = z-(((z*z*z*z*z)-new Complex(1.0, 0.0))/(z*z*z*z*new Complex(5.0, 0.0))).timesConst(a);
        }
      } else if (newtonFunction == 4){
        for (i = 0; i < iterations; i++){
          z = z-(((z*z*z*z*z*z)-new Complex(1.0, 0.0))/(z*z*z*z*z*new Complex(6.0, 0.0))).timesConst(a);
        }
      } else if (newtonFunction == 5){
        for (i = 0; i < iterations; i++){
          z = z-(((z*z*z*z)-(z*z).timesConst(4)-new Complex(1.0, 0.0))/((z*z*z).timesConst(4)-(z).timesConst(8))).timesConst(a);
        }
      } else if (newtonFunction == 6){
        for (i = 0; i < iterations; i++){
          z = z-(((z*z*z*z*z)-(z*z*z).timesConst(2)-(z*z).timesConst(4)-new Complex(1.0, 0.0))/((z*z*z*z).timesConst(5)-(z*z).timesConst(6)-(z).timesConst(8))).timesConst(a);
        }
      } else if (newtonFunction == 7){
        for (i = 0; i < iterations; i++){
          z = z-(((z*z*z).timesConst(3)-(z*z).timesConst(6)-new Complex(1.0, 0.0))/((z*z).timesConst(9)-(z).timesConst(12))).timesConst(a);
        }
      } else if (newtonFunction == 8){
        for (i = 0; i < iterations; i++){
          z = z-((z.sin())/(z.cos()));
        }
      } else if (newtonFunction == 9){
        for (i = 0; i < iterations; i++){
          z = z-((z.cos())/(z.sin().timesConst(-1)));
        }
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
      } catch (e){
      }
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