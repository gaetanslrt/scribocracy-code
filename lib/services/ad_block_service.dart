class AdBlockService {
  // Ce script crée une balise <style> qui force les éléments publicitaires à disparaître
  static const String blockerScript = """
    (function() {
      var style = document.createElement('style');
      style.innerHTML = `
        /* Liste des sélecteurs de publicités communs */
        .ad, .ads, .advertisement, .banner-ads, .sponsor, .partner,
        [id^="google_ads"], [id^="div-gpt-ad"], [class^="ad-"], [class*=" ad "],
        div[id^="taboola-"], div[id^="outbrain-"],
        .pub_300x250, .pub_728x90, .text-ad, .ad-container,
        iframe[src*="ads"], iframe[src*="doubleclick"],
        .cookie-banner, .gdpr-banner /* Optionnel : réduit aussi les bannières cookies */
        {
          display: none !important;
          visibility: hidden !important;
          height: 0 !important;
          opacity: 0 !important;
          pointer-events: none !important;
        }
      `;
      document.head.appendChild(style);
      console.log("Scribocracy Zen Shield: Activé");
    })();
  """;
}