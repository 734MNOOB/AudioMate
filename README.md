[![GitHub tag](https://img.shields.io/github/tag/The9Labs/AudioMate.svg)](https://github.com/The9Labs/AudioMate)
[![GitHub release](https://img.shields.io/github/release/The9Labs/AudioMate.svg)](https://github.com/The9Labs/AudioMate)

# Easy audio control for Mac.

Control all your audio devices from the status bar, receive system notifications when relevant events happen on your audio devices and more. For more information, please visit [AudioMate's website](http://audiomateapp.com).

<img src="https://github.com/tbrek/AudioMate/blob/develop/Artwork/AudioMate_v3_Screenshot.png" class="center">

<img src="https://github.com/tbrek/AudioMate/blob/develop/Artwork/AudioMate_v3_Screenshot2.png" class="center">

### Getting Started

(Make sure [Carthage](https://github.com/Carthage/Carthage) is installed)

```bash
$ git clone git@github.com:The9Labs/AudioMate.git
$ cd Audiomate
$ carthage checkout --use-submodules
```

### Build & Run

1. Open `AMCoreAudio.xcodeproj` in Xcode 8.2 (or later)
2. Hit `Run` (Cmd + R)

### Requirements

* Xcode 8.2 and Swift 3 (for development)
* OS X 10.11 or later

## Version 3 Roadmap

| Description       | Status|
| -------------:|:-------------
| Migration to AMCoreAudio v2.x| Completed|
| Implement audio device notifications| Completed|
| Implement new compact UI| In Progress|
| Implement preferences panel| In Progress|
| Implement audio device actions| Pending|
| Implement keyboard & scroll wheel control ([#18](https://github.com/The9Labs/AudioMate/issues/18))| Pending|

### Further Development & Patches

Do you want to contribute to the project? Please fork, patch, and then submit a pull request!

### Credits

App icon originally based on clipart by [rg1024](https://openclipart.org/detail/20507/robot-carrying-things-1).

### License

AudioMate was written by Ruben Nine ([@sonicbee9](https://twitter.com/sonicbee9)) in 2012-2016 (open-sourced in July 2014) and is licensed under the [MIT](http://opensource.org/licenses/MIT) license. See [LICENSE.md](LICENSE.md).
