#include <iostream>
#include <functional>
#include <chrono>
#include <future>
#include <cstdio>
#include <thread>

using namespace std;

class callBackTimer //no idea how this works, got it from Stack Overflow thread
{

public:
    callBackTimer() : _execute(false)
    {
    }

    void start(int interval, std::function<void()> func)
    {
        _execute = true;
        std::thread t1(timing, interval, func);
        t1.detach();
    }

    void timing(int interval, std::function<void()> func)
    {
        while(_execute)
        {
            func();
            std::this_thread::sleep_for(
                std::chrono::milliseconds(interval));
        }
    }

    void stop()
    {
        _execute = false;
    }

private:
    bool _execute;
};

void timerExec()
{
    cout << "SNAFU" << endl;
}

int main(int argc, const char *argv[])
{
    callBackTimer timer;                        //declare the timer
    std::function<void(void)> exec = timerExec; //declare a pointer to timerExec
    timer.start(1000, std::bind(exec));         //start the timer

    return 0;
}