#include <iostream>
using namespace std;

typedef double (*Arith)(double, double);

double Add(double, double);
double Sub(double, double);
double Mul(double, double);
double Div(double, double);
double Calculator(double, double, Arith);

int main(void)
{
    Arith calc = NULL;
    double num1 = 3, num2 = 4, result = 0;
    char oper = '*';

    switch (oper)
    {
    case '+':
        calc = Add;
        break;
    case '-':
        calc = Sub;
        break;
    case '*':
        calc = Mul;
        break;
    case '/':
        calc = Div;
        break;

    default:
        cout << "사칙연산(+,-,*,/)만을 지원합니다." << endl;
        break;
    }

    result = Calculator(num1, num2, calc);
    cout << "사칙 연산의 결과는 " << result << "입니다.";
    return 0;
}

double Add(double num1, double num2) { return num1 + num2; }
double Sub(double num1, double num2) { return num1 - num2; }
double Mul(double num1, double num2) { return num1 * num2; }
double Div(double num1, double num2) { return num1 / num2; }
double Calculator(double num1, double num2, Arith func) { return func(num1, num2); }