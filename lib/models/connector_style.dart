enum ConnectorStyle {
  straight('Straight', 'Direct point-to-point line'),
  orthogonal('Elbow', 'Right-angle orthogonal steps with rounded corners'),
  curved('Curved', 'Smooth Bézier curve');

  const ConnectorStyle(this.label, this.description);
  final String label;
  final String description;
}
