## 🕵️ Motivation

This repository contains a plugin that enables the display of multiple side sheets on top of each
other with the ability to perform typical navigation actions like `push`, `replace`, `pop`
and `popUntil`.
We developed this plugin while building a web dashboard app and found that standard material
navigation drawers and existing plugins couldn't provide us with the features we needed.

Our plugin is designed to be simple and flexible, allowing you to customize the look of your side
sheets and transition animations without any limitations. With our plugin, you can create a seamless
user experience that meets your specific requirements.

## ⚙ Features

* Display multiple side sheets on top of each other
* Perform typical navigation actions like `push`, `replace`, `pop` and `popUntil`
* Customize the look and feel of your side sheets
* Create seamless transition animations

Check our [web app example](https://nested-side-sheet.web.app)

## 🔨 Installation

```yaml
dependencies:
  nested_side_sheet: ^1.1.1
```

## 🕹️ Usage

```dart
import 'package:nested_side_sheet/nested_side_sheet.dart';

...

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        // Side sheets will be placed above the NestedSideSheet child
        home: NestedSideSheet(
          child: HomePage(),
        ),
      );
}

...

// Call this anywhere in the app within the NestedSideSheet context
final result = await
NestedSideSheet.of
(
context).push(
Container(
color: Colors.white,
width: kSideSheetWidth,
),
transitionBuilder: leftSideSheetTransition,
position: SideSheetPosition.left,
);
```

For advanced usage see
our [example](https://github.com/Krootl/nested-side-sheet/tree/master/example).

## 🧑‍💻 Contributors

<a href="https://github.com/Krootl/nested-side-sheet/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Krootl/nested-side-sheet" />
</a>

We welcome contributions to our plugin! If you'd like to contribute, please fork this repository and
create a pull request with your changes. We'll review your changes and merge them into the main
branch if they meet our quality standards.

## License

Our plugin is open-source and licensed under the MIT License. Feel free to use it in your projects.