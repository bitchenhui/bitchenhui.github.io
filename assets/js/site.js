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

  // 滚动监听：视口所在板块的锚点导航项点亮（aria-current 由 CSS 呈现）。
  var navLinks = Array.prototype.slice.call(document.querySelectorAll(".anchor-nav a[href^='#']"));
  var watchedSections = navLinks
    .map(function (link) { return document.querySelector(link.getAttribute("href")); })
    .filter(Boolean);

  if (navLinks.length && watchedSections.length && "IntersectionObserver" in window) {
    var visibility = {};
    var spy = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        visibility[entry.target.id] = entry.isIntersecting ? entry.intersectionRatio : 0;
      });
      var currentId = null;
      var bestRatio = 0;
      Object.keys(visibility).forEach(function (id) {
        if (visibility[id] > bestRatio) {
          bestRatio = visibility[id];
          currentId = id;
        }
      });
      navLinks.forEach(function (link) {
        var isActive = currentId !== null && link.getAttribute("href") === "#" + currentId;
        link.classList.toggle("is-active", isActive);
        if (isActive) {
          link.setAttribute("aria-current", "true");
        } else {
          link.removeAttribute("aria-current");
        }
      });
    }, { threshold: [0, 0.15, 0.4] });
    watchedSections.forEach(function (section) { spy.observe(section); });
  }

  // 微信号一键复制：按钮由后端渲染、默认 hidden，绑定成功后再显示。
  var wechatButton = document.querySelector("[data-copy-wechat]");
  var wechatStatus = document.querySelector(".contact-status");

  if (wechatButton) {
    wechatButton.addEventListener("click", function () {
      var value = wechatButton.getAttribute("data-copy-wechat");
      if (!value || !navigator.clipboard || !navigator.clipboard.writeText) return;
      navigator.clipboard.writeText(value).then(function () {
        if (wechatStatus) wechatStatus.textContent = "微信号已复制：" + value;
      }, function () { /* 复制失败时保持原样。 */ });
    });
    wechatButton.hidden = false;
  }

  // 解码入场：标题以大块马赛克逐帧收敛为清晰文字，模拟逐块解码。
  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var heroTitle = document.querySelector(".manual-hero h1");
  var decodeCanvas = document.querySelector(".hero-decode");

  function cssVariable(name) {
    return getComputedStyle(root).getPropertyValue(name).trim();
  }

  if (!reduceMotion && heroTitle && decodeCanvas && decodeCanvas.getContext) {
    (function () {
      var context = decodeCanvas.getContext("2d");
      var dpr = Math.min(window.devicePixelRatio || 1, 2);
      var width = heroTitle.offsetWidth;
      var height = heroTitle.offsetHeight;
      if (!width || !height) return;

      var style = window.getComputedStyle(heroTitle);
      var font = style.fontStyle + " " + style.fontWeight + " " + style.fontSize + " " + style.fontFamily;
      context.font = font;

      var lines = [];
      var current = "";
      var text = heroTitle.textContent.trim();
      for (var i = 0; i < text.length; i++) {
        var candidate = current + text[i];
        if (current && context.measureText(candidate).width > width) {
          lines.push(current);
          current = text[i];
        } else {
          current = candidate;
        }
      }
      if (current) lines.push(current);
      if (!lines.length) return;

      decodeCanvas.width = Math.round(width * dpr);
      decodeCanvas.height = Math.round(height * dpr);
      decodeCanvas.style.width = width + "px";
      decodeCanvas.style.height = height + "px";

      var lineHeight = parseFloat(style.lineHeight) || parseFloat(style.fontSize) * 1.3;
      var frameSizes = [24, 14, 8, 4, 2, 1];
      var frameIndex = 0;

      function drawFrame(blockSize) {
        var full = document.createElement("canvas");
        full.width = decodeCanvas.width;
        full.height = decodeCanvas.height;
        var fullContext = full.getContext("2d");
        fullContext.scale(dpr, dpr);
        fullContext.fillStyle = cssVariable("--canvas");
        fullContext.fillRect(0, 0, width, height);
        fullContext.fillStyle = cssVariable("--accent");
        fullContext.font = font;
        fullContext.textBaseline = "top";
        for (var index = 0; index < lines.length; index++) {
          fullContext.fillText(lines[index], 0, index * lineHeight);
        }

        var small = document.createElement("canvas");
        small.width = Math.max(1, Math.round(width / blockSize));
        small.height = Math.max(1, Math.round(height / blockSize));
        var smallContext = small.getContext("2d");
        smallContext.drawImage(full, 0, 0, small.width, small.height);

        context.imageSmoothingEnabled = false;
        context.clearRect(0, 0, decodeCanvas.width, decodeCanvas.height);
        context.drawImage(small, 0, 0, small.width, small.height, 0, 0, decodeCanvas.width, decodeCanvas.height);
      }

      decodeCanvas.hidden = false;

      function step() {
        drawFrame(frameSizes[frameIndex]);
        frameIndex += 1;
        if (frameIndex < frameSizes.length) {
          window.setTimeout(step, 100);
        } else {
          decodeCanvas.hidden = true;
        }
      }

      step();
    }());
  }
}());
