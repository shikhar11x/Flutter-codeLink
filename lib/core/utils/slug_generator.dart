class SlugGenerator {
  SlugGenerator._();

  static const _adjectives = [
    'swift', 'bright', 'cool', 'dark', 'fast',
    'wild', 'calm', 'bold', 'clean', 'sharp',
    'quick', 'silent', 'neon', 'cyber', 'alpha',
  ];

  static const _nouns = [
    'river', 'storm', 'pixel', 'forge', 'spark',
    'cloud', 'blade', 'wave', 'node', 'byte',
    'pulse', 'drift', 'echo', 'flux', 'core',
  ];

  static String generate() {
    final now = DateTime.now();
    final adj  = _adjectives[now.millisecond % _adjectives.length];
    final noun = _nouns[now.second % _nouns.length];
    final num  = now.millisecondsSinceEpoch % 9000 + 1000;
    return '$adj-$noun-$num';
  }
}