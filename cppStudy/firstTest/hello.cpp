#include <iostream>

using namespace std;

class myclass
{
	public:
		int a;
		int b;

		void aFunc()
		{
			cout << "a Func" << endl;
		}
};

int main(){
    cout << "Hello" << endl;
    cout << "Hi" << endl;

	myclass a;
	a.b = 5;
	a.aFunc();

    return 0;
}

void firstFunc()
{
	cout << "hihi" << endl;
}
