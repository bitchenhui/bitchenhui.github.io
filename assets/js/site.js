(function () {
  "use strict";

  var root = document.documentElement;
  var paletteSelect = document.getElementById("palette-select");
  var printButton = document.querySelector("[data-print-button]");

  if (printButton) {
    printButton.addEventListener("click", function () {
      window.print();
    });
    printButton.hidden = false;
  }

  if (paletteSelect) {
    paletteSelect.value = root.dataset.palette || "electric";
    paletteSelect.addEventListener("change", function () {
      var palette = paletteSelect.value;
      root.dataset.palette = palette;
      try { window.localStorage.setItem("site-palette", palette); } catch (error) { /* Apply the palette for this page view. */ }
      document.dispatchEvent(new CustomEvent("palettechange"));
    });
    paletteSelect.parentElement.hidden = false;
  }

  // 先绑定，再显示开关；在浏览器中保存画质偏好。
  var qualityToggle = document.getElementById("quality-toggle");
  var isLowQuality = root.dataset.quality === "low";

  function updateQualityControl() {
    if (!qualityToggle) return;
    qualityToggle.setAttribute("aria-pressed", String(isLowQuality));
  }

  function storeQuality() {
    try { window.localStorage.setItem("site-quality", isLowQuality ? "low" : "high"); } catch (error) { /* 画质偏好仍对本次浏览生效。 */ }
  }

  if (qualityToggle) {
    updateQualityControl();
    qualityToggle.addEventListener("click", function () {
      isLowQuality = !isLowQuality;
      root.dataset.quality = isLowQuality ? "low" : "high";
      storeQuality();
      updateQualityControl();
      document.dispatchEvent(new CustomEvent("qualitychange"));
    });
    qualityToggle.hidden = false;
  }

  // Highlight plain text nodes without replacing links or other inline markup.
  var metricPattern = /(\d[\d,.]*\s*(?:[%％]|ms|fps|万|亿|x)(?:\+)?|\d[\d,.]*\+)(?![\d%a-z])/gi;
  document.querySelectorAll(
    ".experience-item__body li, .experience-item__body > p, .project-card__highlights li, " +
    ".resume__project p, .resume__project li, #resume-honors-title + ul li, .profile-card__list li"
  ).forEach(function (element) {
    Array.from(element.childNodes).forEach(function (node) {
      if (node.nodeType !== Node.TEXT_NODE) return;
      var cursor = 0;
      var result = document.createDocumentFragment();
      node.data.replace(metricPattern, function (match, metric, index) {
        result.append(node.data.slice(cursor, index));
        var accent = document.createElement("span");
        accent.className = "num-accent";
        accent.textContent = metric;
        result.append(accent);
        cursor = index + match.length;
        return match;
      });
      if (cursor) {
        result.append(node.data.slice(cursor));
        node.replaceWith(result);
      }
    });
  });
}());
