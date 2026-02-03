class DarkModeService {
  static const String darkThemeScript = """
    (function() {
      // 1. On crée une balise style avec un ID unique
      if (document.getElementById('scribo-dark-mode')) return; // Déjà actif

      var style = document.createElement('style');
      style.id = 'scribo-dark-mode';
      style.innerHTML = `
        html {
          filter: invert(1) hue-rotate(180deg) !important;
          background-color: #111 !important; 
        }
        /* On protège les images, vidéos et iframes pour ne pas les inverser */
        img, video, iframe, canvas, :not(object):not(body) > embed, object, svg image, [style*="background-image"] {
          filter: invert(1) hue-rotate(180deg) !important;
        }
      `;
      document.head.appendChild(style);
    })();
  """;

  static const String removeDarkThemeScript = """
    (function() {
      var style = document.getElementById('scribo-dark-mode');
      if (style) style.remove();
    })();
  """;
}
