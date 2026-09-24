enum StrokeStyle {
  solid,
  dashed,
  dotted,
}

enum FillStyle {
  none,
  semi,
  solid,
  hatch,
}

enum DrawStyle {
  clean,
  sketch,
}

enum StrokeWidthPreset {
  thin(1.5, 'Thin'),
  medium(2.5, 'Medium'),
  bold(4.5, 'Bold'),
  heavy(8.0, 'Heavy');

  const StrokeWidthPreset(this.width, this.label);
  final double width;
  final String label;
}

enum FontSizePreset {
  small(16.0, 'S'),
  medium(22.0, 'M'),
  large(32.0, 'L'),
  xlarge(48.0, 'XL');

  const FontSizePreset(this.size, this.label);
  final double size;
  final String label;
}
