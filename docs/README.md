# Haxe Grig

[![Join the chat at https://gitter.im/haxe-grig/Lobby](https://badges.gitter.im/haxe-grig/Lobby.svg)](https://gitter.im/haxe-grig/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

                     __             
          __   _ __ /\_\     __     
        /'_ `\/\`'__\/\ \  /'_ `\   
       /\ \ \ \ \ \/ \ \ \/\ \ \ \  
       \ \____ \ \_\  \ \_\ \____ \ 
        \/____\ \/_/   \/_/\/____\ \
          /\____/            /\____/
          \_/__/             \_/__/ 

Grig is a set of small audio packages for haxe (and by extension, the langauges haxe targets) to process and create music and audio.
Grig is designed to have as few dependencies and interdependencies as possible, so that you can use as much or as little of the functionality
you need withing bringing in a heavy framework.
 
    +----------+ +-----------+ +-----------+ +-----------+
    |grig.midi | |grig.synth | |grig.audio | |grig.pitch |
    +----------+ +-----------+ +-----------+ +-----------+
                    \             ^
                    ------------/

See the [api documentation](/grig/api).

Hardware Capabilities:

| Environment        | Midi IO             | Audio IO           |
| ------------------ | ------------------- | ------------------ |
| c++                | ✅                  | (rtaudio)          |
| hashlink           | (rtmidi)            | (rtaudio)          |
| c++/vst            |                     |                    |
| c++/au             |                     |                    |
| c++/lv2            |                     |                    |
| c++/fmod           | N/A                 |                    |
| js/html5           | ✅                  |                    |
| js/nodejs          | ✅                  |                    |
| java               |                     |                    |
| c#                 | ([managed midi](https://github.com/atsushieno/managed-midi))        |                    |
| c#/fmod            | N/A                 |                    |
| lua                | ([luamidi](https://github.com/luaforge/luamidi))                    |                    |
| python             | ✅                  |                    |

