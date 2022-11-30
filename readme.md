## Shimp
### Short description
You have an instance of ```InputSystemContainer```. You add instances of 'button groups' to the system. You call ```system.setPos(coords)```, ```system.press()```, ```system.release()``` according to your source of pointing events. The system takes care of switching visual state of buttons, calling handlers and so on.

### Motivation

The library is a thin abstraction layer over pointing api. I wrote it to use within my UI lib to be independent on underlying engine (openfl/heaps/raw html/etc).
It allows forming interactive objects hierarchy to route input way down. The core concept based on ```isUnder(pos:T)``` method which user free to define as well as define coordinate system.
(One may want to write radial version to handle radial menus. This one may be me in some future).
The core system iterate over all the children to find one which reports ```isUnder()``` is true. Then system passes flow to these children. Straight and dumb iteration may look overhead, but the idea is to group children into separate systems on new hierarchy levels according to proximity (some kind of BVH) in performance-sensitive cases.

### Buttons

The lib includes ```ClickInputSystem``` which takes care on familiar button behavior (clicks and visual states like 'pressed' and 'pressed outside'). Of course the lib doesn't care about visual implementations, it just switches states provided by user.
I'd seen many mobile games (including successful ones) which didn't provide even game-level consistent behavior of buttons, so I decided that impl of very this logic is worth including in the lib.

### Other controls

The lib is not limited by buttons-only usage. I've implemented scrollbox controls ontop of shimp and plan to include it into the lib in the future.

### Usage

See [example](example/src/Sample.hx) for usage details.
