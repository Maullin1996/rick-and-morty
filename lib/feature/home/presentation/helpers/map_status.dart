String? mapStatus(int index) {
  return switch (index) {
    0 => null,
    1 => 'alive',
    2 => 'dead',
    3 => 'unknown',
    _ => null,
  };
}
