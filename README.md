# Metro Simulator

A city metro simulator built with Godot 4.

## Godot Node Hierarchy

Here is the graphical hierarchy of the nodes in the main scene:

```
Main (Node2D)
├── MapLayer (Node2D)
│   └── TextureRect (TextureRect)
├── Camera2D (Camera2D)
├── Tracks (Node2D)
│   └── RedLine (Path2D)
│       └── PathFollow2D (PathFollow2D)
│           └── Sprite2D (Sprite2D)
└── Stations (Node2D)
	├── Bulvar Rokossovskogo (Бульвар Рокоссовского) (station.tscn)
	├── Cherkizovskaya (Черкизовская) (station.tscn)
	├── Preobrazhenskaya Ploshchad (Преображенская площадь) (station.tscn)
	├── Sokolniki (Сокольники) (station.tscn)
	└── Krasnoselskaya (Красносельская) (station.tscn)
```
