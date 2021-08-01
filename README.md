# weather.koplugin
## About 

Did you say weather? Did you say e-reader? Did you say now? Say "welcome" to your new best friend, KOWeather, the lo-fidelity weather app that delivers weather conditions and forecasts to your favorite e-ink device. 

With weather information provided by [WeatherAPI](https://weatherapi.com), this plugin is sure to give you great guidance on the best times to sit under a tree and read, or when to run home so you can avoid that pesky rain. 

### Customization

Have it your way. This plugin lets you set the forecast location by postal code. Whoa!

### Screenshots

![Today's Weather](https://user-images.githubusercontent.com/82218266/127771212-9e2a4a17-8029-4c5b-842f-86d030fd23b5.png)
![Hourly Forecast](https://user-images.githubusercontent.com/82218266/127771213-c7be7b35-9f27-48db-ac5d-eef3392477d5.png)

### Compatibility

Tested with the Kobo Libra H2O. Other devices unknown. Feel encouraged to try this plugin on your device. If it does or doesn't work, our elves would love to know.

## Installation

Easy as pie. Download the latest release and unzip it to your computer.

### Drag and Drop

TODO

### SSH/SCP

TODO

## Development

I know what you're thinking: "how the heck do I get in on this?" Honestly, it's easier than you think. Lua is a fun and foregiving language with [good learning resources](https://www.lua.org/pil/). Seriously, load up your e-reader with a [Lua language ePub](https://store.feistyduck.com/products/programming-in-lua-fourth-edition-ebook) and soak in the brilliance of this humble language. Then follow the steps below to hack away and help out this aspiring bit of coding history...

Here's how my project directory looks:

```
$ ls /home/me/Development/KOReader/
koreader
weather.koplugin
```

### Download KOReader, install dependencies 

TODO

### Clone repository, create soft link between this plugin folder and KOReader's plugins folder 

```sh
ln -s weather.koplugin koreader/plugins/weather.koplugin
```

### Write code, check code, run emulator

Check the code with Luacheck
```sh
cd weather.koplugin
luacheck *
```

Run the emulator
```sh
cd koreader
./kodev run
```

### Deploy to Kobo using SSH/SCP 

Enable the wifi connection on KOReader. Then, launch KOReader's SSH daemon (Settings > Network > SSH server). Set the port to 22 and "login without password".
```sh
scp -r weather.koplugin/ root@192.168.2.16:/mnt/onboard/.adds/koreader/plugins/weather.koplugin/
```

TODO: Create a script that doesn't transfer the git repo.