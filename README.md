# geohunter

Location based scavenger hunt game with a RPG questline which takes place in real life.

- Access the game anywhere that offers an internet connection, requiring no download or special plugins to play.
- Infinite random weapons and armor items, based on a few easy to modify base values.
- Dozens of already created item rarities, classes and weapon modifiers.
- Choose quest outcomes between the seemingly insignificant, and heavy weighted decisions.
- Pick between three factions: the mysterious Syndicate, the elusive Shadow Vanguard or the brave Paladins that start you off but don’t limit you in what you want to do.
- Join or create a guild with your friends to take down larger quests.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flutter installation corrupted

In the flutter installation directory run:
```
git clean -xfd
git stash save --keep-index
git stash drop
git pull
flutter doctor
```

In the project run:
```
flutter pub cache repair
```

## Upgrading flutter projects

[Upgrading-pre-1.12-Android-projects](https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects)