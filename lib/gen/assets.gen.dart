/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// ignore_for_file: directives_ordering,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/A_0_2.jpeg
  AssetGenImage get a02 => const AssetGenImage('assets/images/A_0_2.jpeg');

  /// File path: assets/images/A_0_3.jpeg
  AssetGenImage get a03 => const AssetGenImage('assets/images/A_0_3.jpeg');

  /// File path: assets/images/A_1_0.jpeg
  AssetGenImage get a10 => const AssetGenImage('assets/images/A_1_0.jpeg');

  /// File path: assets/images/A_1_1.jpeg
  AssetGenImage get a11 => const AssetGenImage('assets/images/A_1_1.jpeg');

  /// File path: assets/images/B_0_2.jpeg
  AssetGenImage get b02 => const AssetGenImage('assets/images/B_0_2.jpeg');

  /// File path: assets/images/B_0_3.jpeg
  AssetGenImage get b03 => const AssetGenImage('assets/images/B_0_3.jpeg');

  /// File path: assets/images/B_1_0.jpeg
  AssetGenImage get b10 => const AssetGenImage('assets/images/B_1_0.jpeg');

  /// File path: assets/images/B_1_1.jpeg
  AssetGenImage get b11 => const AssetGenImage('assets/images/B_1_1.jpeg');

  /// File path: assets/images/C_0_2.jpeg
  AssetGenImage get c02 => const AssetGenImage('assets/images/C_0_2.jpeg');

  /// File path: assets/images/C_0_3.jpeg
  AssetGenImage get c03 => const AssetGenImage('assets/images/C_0_3.jpeg');

  /// File path: assets/images/C_1_0.jpeg
  AssetGenImage get c10 => const AssetGenImage('assets/images/C_1_0.jpeg');

  /// File path: assets/images/C_1_1.jpeg
  AssetGenImage get c11 => const AssetGenImage('assets/images/C_1_1.jpeg');
}

class $AssetsJsonGen {
  const $AssetsJsonGen();

  /// File path: assets/json/settings.json
  String get settings => 'assets/json/settings.json';
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
}

class AssetGenImage extends AssetImage {
  const AssetGenImage(String assetName) : super(assetName);

  Image image({
    Key? key,
    ImageFrameBuilder? frameBuilder,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image(
      key: key,
      image: this,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }

  String get path => assetName;
}
