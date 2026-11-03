(function () {
  "use strict";

  var root = document.documentElement;
  var themeToggle = document.getElementById("theme-toggle");
  var printButton = document.querySelector("[data-print-button]");

  if (printButton) {
    printButton.addEventListener("click", function () {
      window.print();
    });
  }

  function updateThemeControl(theme) {
    if (!themeToggle) return;
    var isDark = theme === "dark";
    themeToggle.textContent = isDark ? "浅色" : "深色";
    themeToggle.setAttribute("aria-pressed", String(isDark));
    themeToggle.setAttribute("aria-label", isDark ? "切换为浅色模式" : "切换为深色模式");
  }

  function storeTheme(theme) {
    try { window.localStorage.setItem("site-theme", theme); } catch (error) { /* Theme still works for this page view. */ }
  }

  var initialTheme = root.dataset.theme;

  if (themeToggle) {
    updateThemeControl(initialTheme);
    themeToggle.addEventListener("click", function () {
      var nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
      root.dataset.theme = nextTheme;
      storeTheme(nextTheme);
      updateThemeControl(nextTheme);
    });
    themeToggle.hidden = false;
  }

  // 码率模拟开关：与主题开关同款约定，先绑定再显示，偏好写入 localStorage。
  var qualityToggle = document.getElementById("quality-toggle");
  var isLowQuality = root.dataset.quality === "low";

  function updateQualityControl() {
    if (!qualityToggle) return;
    qualityToggle.textContent = isLowQuality ? "240p" : "HiFi";
    qualityToggle.setAttribute("aria-pressed", String(isLowQuality));
    qualityToggle.setAttribute("aria-label", isLowQuality ? "切回高画质模式" : "模拟 240p 低码率画质");
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

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function cssVariable(name) {
    return getComputedStyle(root).getPropertyValue(name).trim();
  }

  // 解码入场：标题以大块马赛克逐步收敛为清晰文字，模拟逐块解码。
  var heroTitle = document.querySelector(".manual-hero h1");
  var decodeCanvas = document.querySelector(".hero-decode");
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
      var frameDelay = 100;

      // 先按真实尺寸绘制，再降采样、最近邻放大：块越大越「糊」，模拟低码率宏块。
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

      decodeCanvas.classList.add("is-active");

      function step() {
        drawFrame(frameSizes[frameIndex]);
        frameIndex += 1;
        if (frameIndex < frameSizes.length) {
          window.setTimeout(step, frameDelay);
        } else {
          decodeCanvas.classList.add("is-done");
        }
      }

      step();
    }());
  }

  // 宏块网格：Hero 背景的静态网格；指针经过时该宏块点亮并画出随机运动矢量。
  var heroSection = document.querySelector(".manual-hero");
  var motionCanvas = document.querySelector(".hero-motion");
  if (heroSection && motionCanvas && motionCanvas.getContext) {
    (function () {
      var context = motionCanvas.getContext("2d");
      var dpr = Math.min(window.devicePixelRatio || 1, 2);
      var raf = null;
      var active = {};

      function cellSize() {
        return (isLowQuality ? 56 : 28);
      }

      function resize() {
        motionCanvas.width = Math.round(heroSection.offsetWidth * dpr);
        motionCanvas.height = Math.round(heroSection.offsetHeight * dpr);
        motionCanvas.style.width = heroSection.offsetWidth + "px";
        motionCanvas.style.height = heroSection.offsetHeight + "px";
      }

      function drawGrid() {
        var size = cellSize() * dpr;
        context.clearRect(0, 0, motionCanvas.width, motionCanvas.height);
        context.strokeStyle = cssVariable("--grid-line");
        context.lineWidth = 1;
        context.beginPath();
        for (var x = size; x < motionCanvas.width; x += size) {
          context.moveTo(x, 0);
          context.lineTo(x, motionCanvas.height);
        }
        for (var y = size; y < motionCanvas.height; y += size) {
          context.moveTo(0, y);
          context.lineTo(motionCanvas.width, y);
        }
        context.stroke();
      }

      // 同一宏块的矢量方向由坐标决定：每次划过结果一致，像真实的估计输出。
      function seedFor(cx, cy) {
        var value = (cx * 73856093) ^ (cy * 19349663);
        value = Math.imul(value ^ (value >> 13), 1274126177);
        return ((value ^ (value >> 16)) >>> 0) / 4294967295;
      }

      function drawVectors(now) {
        var size = cellSize() * dpr;
        var accent = cssVariable("--accent");
        context.lineWidth = Math.max(1, dpr);
        for (var key in active) {
          var age = now - active[key];
          if (age > 700) {
            delete active[key];
            continue;
          }
          var parts = key.split(",");
          var cx = parseInt(parts[0], 10);
          var cy = parseInt(parts[1], 10);
          var alpha = 1 - age / 700;
          var seed = seedFor(cx, cy);
          var angle = seed * Math.PI * 2;
          var length = (5 + seed * 9) * dpr;
          var px = (cx + 0.5) * size;
          var py = (cy + 0.5) * size;
          var hx = px + Math.cos(angle) * length;
          var hy = py + Math.sin(angle) * length;
          context.fillStyle = accent;
          context.strokeStyle = accent;
          context.globalAlpha = alpha * 0.14;
          context.fillRect(cx * size + 1, cy * size + 1, size - 2, size - 2);
          context.globalAlpha = alpha * 0.9;
          context.beginPath();
          context.moveTo(px, py);
          context.lineTo(hx, hy);
          context.stroke();
          context.beginPath();
          context.arc(hx, hy, 1.6 * dpr, 0, Math.PI * 2);
          context.fill();
        }
        context.globalAlpha = 1;
      }

      function frame(now) {
        drawGrid();
        if (!reduceMotion) drawVectors(now);
        if (Object.keys(active).length === 0) {
          raf = null;
          return;
        }
        raf = window.requestAnimationFrame(frame);
      }

      function ensureLoop() {
        if (!raf) raf = window.requestAnimationFrame(frame);
      }

      resize();
      window.addEventListener("resize", function () {
        resize();
        ensureLoop();
      });
      document.addEventListener("qualitychange", ensureLoop);

      if (reduceMotion) {
        drawGrid();
      } else {
        heroSection.addEventListener("pointermove", function (event) {
          var rect = motionCanvas.getBoundingClientRect();
          var size = cellSize();
          var cx = Math.floor((event.clientX - rect.left) / size);
          var cy = Math.floor((event.clientY - rect.top) / size);
          active[cx + "," + cy] = performance.now();
          ensureLoop();
        });
        drawGrid();
      }
    }());
  }

  // 滚动监听：视口所在板块的锚点导航项高亮。
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

  // 量化成果高亮：把指标数字包上强调样式（先转义再包 span，纯文本安全）。
  var metricPattern = /(\d[\d,.]*\s*(?:%|％|ms|fps|万|亿|x)(?:\+)?|\d[\d,.]*\+)(?![\d%])/g;
  function escapeHtml(text) {
    return text.replace(/[&<>]/g, function (ch) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;" }[ch];
    });
  }
  function accentMetrics(element) {
    element.innerHTML = escapeHtml(element.textContent).replace(metricPattern, '<span class="num-accent">$1</span>');
  }
  Array.prototype.forEach.call(
    document.querySelectorAll(
      ".experience-item__body li, .experience-item__body > p, .project-card__highlights li, .resume li, .resume__project > p"
    ),
    accentMetrics
  );

  // 微信号点击复制。
  Array.prototype.forEach.call(document.querySelectorAll("[data-copy-wechat]"), function (button) {
    button.addEventListener("click", function () {
      var value = button.getAttribute("data-copy-wechat");
      if (!value || !navigator.clipboard || !navigator.clipboard.writeText) return;
      navigator.clipboard.writeText(value).then(function () {
        button.classList.add("is-copied");
        window.setTimeout(function () { button.classList.remove("is-copied"); }, 1600);
      }, function () { /* 复制失败时保持原样。 */ });
    });
  });
}());
