(function () {
  "use strict";

  var printButton = document.querySelector("[data-print-button]");

  if (printButton) {
    printButton.addEventListener("click", function () {
      window.print();
    });
    printButton.hidden = false;
  }

  // Highlight plain text nodes without replacing links or other inline markup.
  var metricPattern = /(\d[\d,.]*\s*(?:[%％]|ms|fps|万|亿|w|x)(?:\+)?|\d[\d,.]*\+)(?![\d%a-z])/gi;
  document.querySelectorAll(
    ".experience-item__body li, .experience-item__body > p, .project-card__highlights li, .project-card__content > p, " +
    ".resume__project p, .resume__project li, .resume-work > p, .resume-work__highlights li, #resume-honors-title + ul li, .profile-card__list li"
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

  // One scroll controller for the homepage and resume reading indexes.
  var navigation = Array.from(document.querySelectorAll(".anchor-nav, .resume-index nav")).map(function (nav) {
    var links = Array.from(nav.querySelectorAll('a[href^="#"]'));
    return {
      links: links,
      sections: links.map(function (link) { return document.getElementById(link.hash.slice(1)); }),
      current: -1
    };
  });
  var header = document.querySelector(".site-header");
  var scrollFrame = 0;

  function updateNavigation() {
    scrollFrame = 0;
    var readingLine = (header ? header.offsetHeight : 0) + Math.min(window.innerHeight * 0.2, 128);
    var atEnd = Math.ceil(window.scrollY + document.documentElement.clientHeight) >= document.documentElement.scrollHeight - 1;
    navigation.forEach(function (group) {
      var next = group.sections.reduce(function (index, section, i) {
        return section && section.getBoundingClientRect().top <= readingLine ? i : index;
      }, -1);
      if (atEnd) next = group.links.length - 1;
      if (next === group.current) return;
      if (group.links[group.current]) group.links[group.current].removeAttribute("aria-current");
      if (group.links[next]) group.links[next].setAttribute("aria-current", "location");
      group.current = next;
    });
  }

  function scheduleNavigation() {
    if (!scrollFrame) scrollFrame = window.requestAnimationFrame(updateNavigation);
  }

  if (navigation.length) {
    window.addEventListener("scroll", scheduleNavigation, { passive: true });
    window.addEventListener("resize", scheduleNavigation);
    window.addEventListener("pageshow", scheduleNavigation);
    scheduleNavigation();
  }

  var copy = document.querySelector("[data-copy-wechat]");
  var status = document.querySelector(".contact-status");
  if (copy && status && navigator.clipboard && navigator.clipboard.writeText) {
    copy.addEventListener("click", async function () {
      status.textContent = "";
      try {
        await navigator.clipboard.writeText(copy.dataset.copyWechat);
        status.textContent = "微信号已复制: " + copy.dataset.copyWechat;
      } catch (error) {
        status.textContent = "复制失败，请选中上方微信号手动复制。";
      }
    });
    copy.hidden = false;
  }

  // Native dialog supports Escape, keyboard focus containment, and a link fallback.
  var viewer = document.getElementById("image-viewer");
  if (viewer && typeof viewer.showModal === "function") {
    var image = viewer.querySelector("[data-full-image]");
    var caption = viewer.querySelector("#image-viewer-title");
    var original = viewer.querySelector("[data-original-image]");
    var trigger;
    document.querySelectorAll("[data-image-open]").forEach(function (link) {
      link.addEventListener("click", function (event) {
        if (event.button !== 0 || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
        trigger = link;
        caption.textContent = link.dataset.imageTitle || "作品图示";
        image.alt = caption.textContent;
        image.src = link.href;
        original.href = link.href;
        viewer.showModal();
        event.preventDefault();
      });
    });
    viewer.querySelector("[data-close-image]").addEventListener("click", function () { viewer.close(); });
    viewer.addEventListener("click", function (event) {
      if (event.target === viewer) viewer.close();
    });
    viewer.addEventListener("close", function () {
      if (trigger) trigger.focus({ preventScroll: true });
    });
  }
}());
