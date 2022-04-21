## Tramontana iOS app Repo

### Introdution


Usually we interact with one digital device at a time in the same space, this being a phone, a smarttv or a computer.

This changes when we look at other interactive systems like connected devices or interactive spaces. 

This is what tramontana allows to do, prototytiping an interactive system with different interaction touchpoints. tramontana is designed for creating rich interactive experiences with *few lines of code*.

### Lifecycle

For the user of tramontana the idea is simple:
breaking the old paradigm, now you can write one single application that runs on multiple devices. 


When the tramontana app (**node**) starts it creates a websocket server, so then you can connect with your **sketch**. If you have multiple **nodes** you should start all of them and then start the **sketch**.

Conceptually the app is a bridge between the sketch and the sensors and actuators that are inside the device.

The app is thought to have managers that keep track of specific features. Most of the managers are referenced in the main ViewController.

In fact [TViewController](https://github.com/tramontanaixd/ios-app/blob/master/iOSNode/TViewController.h) keeps reference of: 
1. [SensorManager](https://github.com/tramontanaixd/ios-app/blob/master/iOSNode/SensorManager.h)
2. [ActuatorManager](https://github.com/tramontanaixd/ios-app/blob/master/iOSNode/ActuatorManager.h)
3. [ConsoleManager](https://github.com/tramontanaixd/ios-app/blob/master/iOSNode/ConsoleManager.h)

The [NetworkManager](https://github.com/tramontanaixd/ios-app/blob/master/iOSNode/NetworkManager.h) (or the WebSocketManager) and [OSCManager](https://github.com/tramontanaixd/ios-app/blob/master/iOSNode/OscManager.h) are singletons and keep track of network events. 

#### SensorManager 
The SensorManager is responsible to keeping track of a list of active sensors and related clients that are interested in events. This is done via the `-(void) registerSensor:(int)sensor withWebsocket:(PSWebSocket*)webSocket ` method.

The method `-(void) releaseSensor:(int)sensor withWebsocket:(PSWebSocket*)webSocket` releases the client to listening to a certain sensor, if there are no more listeners the device stops to track the specific sensor. 
E.g. [link](https://github.com/tramontanaixd/ios-app/blob/master/iOSNode/SensorManager.m#L239)

```objc
 if([_arrayDistance count]==0)
 {
    [UIDevice currentDevice].proximityMonitoringEnabled=NO;
 }
```

#### Actuator Manager

The actuator manager is responsible to play respond to actuator commands that are not related to showing media (audio, video, images) on screen (we are using GPMediaView for that).

These methods are:
· setBrightness
· makeVibrate
· setLED
· pulseLEDwith


#### Console Manager
The console manager is used just for debug at the beginning of tramontana. The panel at the beginning is dismissed as soon as we send a command that changes the appearance of the screen. 


#### Dropbox Manager
When invoking tramontana to take a picture, the image is saved to Dropbox if the account was linked. This resulted particularly interesting when extending the event with iFTTT.


 

### Contribution

If you want to contribute to tramontana, welcome!
 
When you develop tramotana make sure that the app compiles on iPhone, iPad and TvOS.

After each accepted pull request  the main contributors will compile and sign the app, and send it for approval to the App Store.

The pull request should state the updated version of the app. The current version now is **1.2.3**.
 
### Lisence
GNU AFFERO GENERAL PUBLIC LICENSE Version 3
AGPL-3.0-only
