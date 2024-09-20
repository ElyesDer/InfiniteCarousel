# InfiniteCarousel

`InfiniteCarousel` is a SwiftUI view that provides a customizable, infinite carousel experience for displaying items. This library simplifies the creation of carousels in your iOS or macOS (via Mac Catalyst) applications by leveraging `SwiftUI`'s powerful declarative syntax and offering various configurations such as spacing, dynamic sizing, and scroll modes.

## Preview

<table class="tg"><thead>
  <tr>
    <td class="tg-0lax"><img src="https://github.com/ElyesDer/InfiniteCarousel/blob/main/Preview/structered_preview.gif" width="300"/></td>
  </tr></thead>
</table>

## Features

- **Infinite Scrolling**: The carousel continuously scrolls through items.
- **Auto-scrolling**: Configurable automatic scrolling with an adjustable time interval.
- **Gestures**: Support for scroll gestures with animation.
- **Flexible Item Display**: Allows customization of how each item is displayed in the carousel.
- **Customizable Layout**: Supports custom spacing and size configuration for the carousel items.
- **Cross-platform Support**: Works on iOS, tvOS and macOS (via Mac Catalyst).

## Requirements

- **iOS**: iOS 13.0+
- **Mac Catalyst**: macOS 10.15+

## Installation

You can install the `InfiniteCarousel` library via Swift Package Manager:

1. In Xcode, go to `File` > `Add Packages`.
2. Enter the URL of your package repository: 
    ```
    https://github.com/ElyesDer/InfiniteCarousel.git
    ```
3. Choose the package and follow the instructions to complete the installation.

## Usage

### Basic Example

Here is an example of how to use the `InfiniteCarousel`:

```swift
import SwiftUI
import InfiniteCarousel

struct ContentView: View {
    var body: some View {
        InfiniteCarousel(
            items: [
                UIColor.red,
                UIColor.blue,
                UIColor.brown,
                UIColor.cyan,
                UIColor.magenta
            ],
            spacing: 10,
            size: InfiniteCarousel.Size.init(
                width: .ratio(0.8),
                height: .pixel(200)
            ),
            scrollMode: .autoScroll(interval: 0.5),
            gesture: .scrollTo(animation: .default(duration: 1))
        ) { item in
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(uiColor: item))
        }
    }
}
```

### Parameters

- `items`: A collection of items conforming to `RandomAccessCollection`, which represent the data that will be displayed in the carousel.
- `spacing`: The spacing between items in the carousel.
- `size`: The size of the items in the carousel, which can be defined using width and height. You can choose between `.ratio` (relative to the parent view) or `.pixel` (absolute size in points).
- `scrollMode`: The scroll behavior of the carousel. Options include:
  - `.autoScroll(interval: TimeInterval)` for automatic scrolling.
  - `.manual` for manual scrolling.
- `gesture`: Configures the scrolling gestures. You can specify animations and durations for user-initiated scroll actions.

## How It Works

`InfiniteCarousel` uses a combination of `ScrollView` from SwiftUI and `InfiniteCarouselManager` to create an infinite scrolling effect. 
⚠️ The library uses `Introspect`, a third-party dependency, to extend `SwiftUI.ScrollView` using it's sub type UIKit one and fine tune it's behavior and ensure interactions and animations.

Key components:
- **InfiniteCarouselManager**: Handles the state of the carousel, such as the current scroll position and the automatic scrolling interval.
- **SwiftUI ScrollView**: The core view that manages the display of items.
- **Introspect**: A third-party library used to introspect and interact with UIKit components under the hood.

## Compatibility with Older iOS Versions

`InfiniteCarousel` is compatible with iOS 13.0 and later, allowing support for older iPhone and iPad devices. The library utilizes SwiftUI's `ScrollView`, which is available starting from iOS 13.0, and for older versions of macOS (via Mac Catalyst), the minimum requirement is macOS 10.15.

To ensure full compatibility with older systems, the following practices are used:
Conditional compilation (`#available`) to ensure that newer SwiftUI features are only used when running on a compatible platform.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contribution

Contributions are welcome! Feel free to submit a pull request or open an issue for any bugs or feature requests.
