(function () {
  "use strict";

  var hero = document.querySelector(".manual-hero");
  var root = document.documentElement;
  var reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  // The title stays as real text. Only a decorative layer clears in macroblocks.
  var decode = hero.querySelector(".hero-decode");
  var decodeContext = reducedMotion.matches ? null : decode.getContext("2d");
  var decodeFrame = 0;

  function stopDecode() {
    window.cancelAnimationFrame(decodeFrame);
    decode.hidden = true;
  }

  if (decodeContext) {
    var blockSize = 16;
    var cols = Math.ceil(decode.parentElement.clientWidth / blockSize);
    var rows = Math.ceil(decode.parentElement.clientHeight / blockSize);
    decode.width = cols;
    decode.height = rows;
    decodeContext.fillStyle = getComputedStyle(root).getPropertyValue("--accent").trim();
    var start = performance.now();

    function reveal(now) {
      var progress = Math.min((now - start) / 380, 1);
      if (progress >= 1 || reducedMotion.matches) {
        stopDecode();
        return;
      }

      decode.hidden = false;
      decodeContext.clearRect(0, 0, cols, rows);
      decodeContext.globalAlpha = (1 - progress) * 0.2;
      for (var y = 0; y < rows; y++) {
        for (var x = 0; x < cols; x++) {
          if (seedFor(x, y) > progress) decodeContext.fillRect(x, y, 1, 1);
        }
      }
      decodeFrame = window.requestAnimationFrame(reveal);
    }

    decodeFrame = window.requestAnimationFrame(reveal);
  }

  // The static grid is CSS. Allocate and draw vectors only during pointer interaction.
  var motion = hero.querySelector(".hero-motion");
  var motionArea = hero.querySelector(".signal-frame");
  var context;
  var active = new Map();
  var frameId = 0;
  var size;

  function seedFor(x, y) {
    var value = (x * 73856093) ^ (y * 19349663);
    value = Math.imul(value ^ (value >> 13), 1274126177);
    return ((value ^ (value >> 16)) >>> 0) / 4294967295;
  }

  function stopVectors() {
    window.cancelAnimationFrame(frameId);
    frameId = 0;
    active.clear();
    motion.hidden = true;
  }

  function drawVectors(now) {
    frameId = 0;
    context.clearRect(0, 0, motionArea.clientWidth, motionArea.clientHeight);
    active.forEach(function (cell, key) {
      var age = now - cell.started;
      if (age >= 700) {
        active.delete(key);
        return;
      }
      var alpha = 1 - Math.max(0, age) / 700;
      var seed = seedFor(cell.x, cell.y);
      var angle = seed * Math.PI * 2;
      var length = 5 + seed * 9;
      var px = (cell.x + 0.5) * size;
      var py = (cell.y + 0.5) * size;
      var hx = px + Math.cos(angle) * length;
      var hy = py + Math.sin(angle) * length;

      context.globalAlpha = alpha * 0.14;
      context.fillRect(cell.x * size + 1, cell.y * size + 1, size - 2, size - 2);
      context.globalAlpha = alpha * 0.9;
      context.beginPath();
      context.moveTo(px, py);
      context.lineTo(hx, hy);
      context.stroke();
      context.beginPath();
      context.arc(hx, hy, 1.6, 0, Math.PI * 2);
      context.fill();
    });
    context.globalAlpha = 1;
    if (active.size) frameId = window.requestAnimationFrame(drawVectors);
    else motion.hidden = true;
  }

  motionArea.addEventListener("pointermove", function (event) {
    if (event.pointerType === "touch" || reducedMotion.matches) return;
    if (context === undefined) context = motion.getContext("2d");
    if (!context) return;

    if (!frameId) {
      var dpr = Math.min(window.devicePixelRatio || 1, 2);
      var width = Math.round(motionArea.clientWidth * dpr);
      var height = Math.round(motionArea.clientHeight * dpr);
      if (motion.width !== width) motion.width = width;
      if (motion.height !== height) motion.height = height;
      var style = getComputedStyle(hero);
      size = parseFloat(style.getPropertyValue("--hero-cell"));
      var accent = style.getPropertyValue("--accent").trim();
      context.setTransform(dpr, 0, 0, dpr, 0, 0);
      context.fillStyle = context.strokeStyle = accent;
      motion.hidden = false;
    }

    var rect = motionArea.getBoundingClientRect();
    var x = Math.floor((event.clientX - rect.left) / size);
    var y = Math.floor((event.clientY - rect.top) / size);
    active.set(x + "," + y, { x: x, y: y, started: performance.now() });
    if (!frameId) frameId = window.requestAnimationFrame(drawVectors);
  });

  function resetEffects() {
    stopDecode();
    stopVectors();
  }

  window.addEventListener("resize", resetEffects);
  document.addEventListener("qualitychange", resetEffects);
  document.addEventListener("palettechange", resetEffects);
  document.addEventListener("visibilitychange", function () {
    if (document.hidden) resetEffects();
  });
  if (reducedMotion.addEventListener) reducedMotion.addEventListener("change", resetEffects);

  // Follow the reading position, including tall sections and the last section at page end.
  var links = Array.from(hero.querySelectorAll(".anchor-nav a"));
  var sections = links.map(function (link) { return document.getElementById(link.hash.slice(1)); });
  var header = document.querySelector(".site-header");
  var current = -1;
  var scrollFrame = 0;

  function updateNavigation() {
    scrollFrame = 0;
    var readingLine = header.offsetHeight + Math.min(window.innerHeight * 0.2, 128);
    var next = sections.reduce(function (index, section, i) {
      return section && section.getBoundingClientRect().top <= readingLine ? i : index;
    }, -1);
    var viewport = document.documentElement;
    if (Math.ceil(window.scrollY + viewport.clientHeight) >= viewport.scrollHeight - 1) {
      next = links.length - 1;
    }
    if (next === current) return;
    if (links[current]) links[current].removeAttribute("aria-current");
    if (links[next]) links[next].setAttribute("aria-current", "location");
    current = next;
  }

  function scheduleNavigation() {
    if (!scrollFrame) scrollFrame = window.requestAnimationFrame(updateNavigation);
  }

  window.addEventListener("scroll", scheduleNavigation, { passive: true });
  window.addEventListener("resize", scheduleNavigation);
  window.addEventListener("pageshow", scheduleNavigation);
  scheduleNavigation();

  var copy = document.querySelector("[data-copy-wechat]");
  var status = document.querySelector(".contact-status");
  if (copy && status && navigator.clipboard && navigator.clipboard.writeText) {
    copy.addEventListener("click", async function () {
      status.textContent = "";
      try {
        await navigator.clipboard.writeText(copy.dataset.copyWechat);
        status.textContent = "已复制微信号。";
      } catch (error) {
        status.textContent = "复制失败，请选中上方微信号手动复制。";
      }
    });
    copy.hidden = false;
  }
}());
