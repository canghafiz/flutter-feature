class Effect {
  Effect({
    required this.img,
    required this.path,
  });

  final String img, path;

  // Data
  static final List<Effect> _effects = [
        Effect(img: "none", path: "none"),
        Effect(
          img: "assets/masks/img/aviators.png",
          path: "assets/masks/aviators",
        ),
        Effect(
          img: "assets/masks/img/beard.png",
          path: "assets/masks/beard",
        ),
        Effect(
          img: "assets/masks/img/bigmouth.png",
          path: "assets/masks/bigmouth",
        ),
        Effect(
          img: "assets/masks/img/dalmatian.png",
          path: "assets/masks/dalmatian",
        ),
        Effect(
          img: "assets/masks/img/fatify.png",
          path: "assets/masks/fatify",
        ),
        Effect(
          img: "assets/masks/img/flowers.png",
          path: "assets/masks/flowers",
        ),
        Effect(
          img: "assets/masks/img/grumpycat.png",
          path: "assets/masks/grumpycat",
        ),
        Effect(
          img: "assets/masks/img/koala.png",
          path: "assets/masks/koala",
        ),
        Effect(
          img: "assets/masks/img/lion.png",
          path: "assets/masks/lion",
        ),
        Effect(
          img: "assets/masks/img/mudmask.png",
          path: "assets/masks/mudmask",
        ),
        Effect(
          img: "assets/masks/img/obama.png",
          path: "assets/masks/obama",
        ),
        Effect(
          img: "assets/masks/img/pug.png",
          path: "assets/masks/pug",
        ),
        Effect(
          img: "assets/masks/img/sleepingmask.png",
          path: "assets/masks/sleepingmask",
        ),
        Effect(
          img: "assets/masks/img/smallface.png",
          path: "assets/masks/smallface",
        ),
        Effect(
          img: "assets/masks/img/teddycigar.png",
          path: "assets/masks/teddycigar",
        ),
        Effect(
          img: "assets/masks/img/tripleface.png",
          path: "assets/masks/tripleface",
        ),
        Effect(
          img: "assets/masks/img/twistedface.png",
          path: "assets/masks/twistedface",
        )
      ],
      _filters = [
        Effect(img: 'none', path: 'none'),
        Effect(
            img: 'assets/filters/img/bleachbypass.png',
            path: 'assets/filters/bleachbypass'),
        Effect(
            img: 'assets/filters/img/drawingmanga.png',
            path: 'assets/filters/drawingmanga'),
        Effect(
            img: 'assets/filters/img/filmcolorpefection.png',
            path: 'assets/filters/filmcolorperfection'),
        Effect(
            img: 'assets/filters/img/realvhs.png',
            path: 'assets/filters/realvhs'),
        Effect(
            img: 'assets/filters/img/sepia.png', path: 'assets/filters/sepia'),
        Effect(img: 'assets/filters/img/tv80.png', path: 'assets/filters/tv80'),
      ];

  // Getter Data
  static List<Effect> get effects => _effects;
  static List<Effect> get filters => _filters;
}
