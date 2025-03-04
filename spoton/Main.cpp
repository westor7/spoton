/* Play/Pause, Next, Previous

Copyright 2010 Marcus L�nnberg

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/* Announce and Creator

Copyright 2021 Turbosmurfen

Licensed under the Creative Commons License, version 4.0
https://creativecommons.org/licenses/by-nc/4.0/

*/


#include <cstdio>
#include <windows.h>
#include <string>
#include <vector>
#include <iostream>
#define WIN32_LEAN_AND_MEAN
#pragma comment(linker, "/EXPORT:song=_song@24")
#pragma comment(linker, "/EXPORT:creator=_creator@24")
#pragma comment(linker, "/EXPORT:status=_status@24")
#pragma comment(linker, "/EXPORT:play=_play@24")
#pragma comment(linker, "/EXPORT:pause=_pause@24")
#pragma comment(linker, "/EXPORT:next=_next@24")
#pragma comment(linker, "/EXPORT:prev=_prev@24")
using namespace std;

string title{""};
int status_{0};
HWND hWNd{};

void readData(string input, HWND hWnd) {

    if (!input.empty()) {

        if (input == "Advertisement" || title.find("-") == 0) {
            status_ = 2;
            hWNd = hWnd;
        }
        else if (input == "Spotify Premium" || input == "Spotify Free") {
            status_ = 1;
            hWNd = hWnd;
        }
        else {
            hWNd = hWnd;
            title = input;
            status_ = 3;
        }
    }
    else {
        status_ = 0;
    }
}

static BOOL CALLBACK enumWindowCallback(HWND hWnd, LPARAM lparam) {
    string wClass{};
    int length = GetWindowTextLength(hWnd);
    char* buffer = new char[length + 1];
    GetWindowTextA(hWnd, buffer, length + 1);
    string wTitle(buffer);
    char* buffer0 = new char[256];
    GetClassNameA(hWnd, buffer0, 256);
    wClass = buffer0;

    if (IsWindowVisible(hWnd) && length != 0 && wClass == "Chrome_WidgetWin_0") {
        readData(wTitle, hWnd);
    }

    return TRUE;
}



extern "C" int __stdcall song(HWND mWnd, HWND aWnd, CHAR * data, char* parms, BOOL show, BOOL nopause)
{
    EnumWindows(enumWindowCallback, NULL);
    if (status_ == 3) {
        char* cstr = new char[title.size() + 1];
        title.copy(cstr, title.size() + 1);
        cstr[title.size()] = '\0';
        strcpy_s(data, strlen(cstr) + 1, cstr);
    }
    return 3;
}
extern "C" int __stdcall creator(HWND mWnd, HWND aWnd, CHAR * data, char* parms, BOOL show, BOOL nopause)
{
    char cby[] = "Created By: Turbosmurfen";
    strcpy_s(data, strlen(cby) + 1, cby);
    return 3;
}

extern "C" int __stdcall status(HWND mWnd, HWND aWnd, CHAR * data, char* parms, BOOL show, BOOL nopause)
{
    EnumWindows(enumWindowCallback, NULL);
    string input = std::to_string(status_);
    char* cstr = new char[input.size() + 1];
    input.copy(cstr, input.size() + 1);
    cstr[input.size()] = '\0';
    strcpy_s(data, strlen(cstr) + 1, cstr);
    return 3;
}

// Here starts the commands for Spotify Media Player.

extern "C" int __stdcall pause(HWND mWnd, HWND aWnd, CHAR * data, char* parms, BOOL show, BOOL nopause)
{
    EnumWindows(enumWindowCallback, NULL);
    if (hWNd && status_ == 3) {
        SendMessage(hWNd, WM_APPCOMMAND, 0, APPCOMMAND_MEDIA_PLAY_PAUSE * 0x10000);
    }
    return 0;
}

extern "C" int __stdcall play(HWND mWnd, HWND aWnd, CHAR * data, char* parms, BOOL show, BOOL nopause)
{
    EnumWindows(enumWindowCallback, NULL);
    if (hWNd && status_ == 1) {
        SendMessage(hWNd, WM_APPCOMMAND, 0, APPCOMMAND_MEDIA_PLAY_PAUSE * 0x10000);
    }
    return 0;
}

extern "C" int __stdcall next(HWND mWnd, HWND aWnd, CHAR * data, char* parms, BOOL show, BOOL nopause)
{
    EnumWindows(enumWindowCallback, NULL);
    if (hWNd) SendMessage(hWNd, WM_APPCOMMAND, 0, APPCOMMAND_MEDIA_NEXTTRACK * 0x10000);
    return 0;
}

extern "C" int __stdcall prev(HWND mWnd, HWND aWnd, CHAR * data, char* parms, BOOL show, BOOL nopause)
{
    EnumWindows(enumWindowCallback, NULL);
    if (hWNd) SendMessage(hWNd, WM_APPCOMMAND, 0, APPCOMMAND_MEDIA_PREVIOUSTRACK * 0x10000);
    return 0;
}