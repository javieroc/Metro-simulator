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
│       └── Train_01 (train.tscn)
└── Stations (Node2D)
    ├── Bulvar Rokossovskogo (Бульвар Рокоссовского) (station.tscn)
    ├── Cherkizovskaya (Черкизовская) (station.tscn)
    ├── Preobrazhenskaya Ploshchad (Преображенская площадь) (station.tscn)
    ├── Sokolniki (Сокольники) (station.tscn)
    ├── Krasnoselskaya (Красносельская) (station.tscn)
    ├── Komsomolskaya (Комсомольская) (station.tscn)
    ├── Krasnye Vorota (Красные Ворота) (station.tscn)
    ├── Chistye Prudy (Чистые пруды) (station.tscn)
    ├── Lubyanka (Лубянка) (station.tscn)
    ├── Okhotny Ryad (Охотный ряд) (station.tscn)
    ├── Biblioteka Imeni Lenina (Библиотека имени Ленина) (station.tscn)
    ├── Kropotkinskaya (Кропоткинская) (station.tscn)
    ├── Park Kultury (Парк культуры) (station.tscn)
    ├── Frunzenskaya (Фрунзенская) (station.tscn)
    ├── Sportivnaya (Спортивная) (station.tscn)
    ├── Vorobyovy Gory (Воробьёвы горы) (station.tscn)
    ├── Universitet (Университет) (station.tscn)
    ├── Prospekt Vernadskogo (Проспект Вернадского) (station.tscn)
    ├── Yugo-Zapadnaya (Юго-Западная) (station.tscn)
    ├── Troparyovo (Тропарёво) (station.tscn)
    ├── Rumyantsevo (Румянцево) (station.tscn)
    └── Salaryevo (Саларьево) (station.tscn)
```
