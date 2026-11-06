(function () {
  "use strict";

  var counter = document.querySelector("[data-visitor-counter]");
  if (!counter) return;

  // Never mix local previews with the published site's visitor count.
  var site;
  try { site = new URL(counter.dataset.siteUrl); } catch (error) { return; }
  var host = window.location.hostname;
  if (host === "localhost" || host.endsWith(".localhost") || /^127\./.test(host) || host === "[::1]" || host === "::1") return;
  if (window.location.origin !== site.origin) return;

  var value = counter.querySelector("#busuanzi_value_site_uv");
  var container = counter.querySelector("#busuanzi_container_site_uv");
  var placeholder = counter.querySelector("[data-visitor-placeholder]");
  var script = document.createElement("script");
  var timeout;
  var observer = new MutationObserver(showCount);

  function showCount() {
    if (!/^[0-9]+$/.test(value.textContent.trim())) {
      container.style.display = "none";
      return;
    }
    window.clearTimeout(timeout);
    observer.disconnect();
    placeholder.hidden = true;
    container.style.display = "inline";
  }

  function unavailable() {
    container.style.display = "none";
    placeholder.hidden = false;
    placeholder.textContent = "访客统计暂不可用";
  }

  observer.observe(value, { childList: true, subtree: true, characterData: true });
  timeout = window.setTimeout(unavailable, 8000);
  script.src = "https://busuanzi.ibruce.info/busuanzi/2.3/busuanzi.pure.mini.js";
  script.async = true;
  script.addEventListener("error", function () {
    observer.disconnect();
    window.clearTimeout(timeout);
    unavailable();
  }, { once: true });
  document.head.appendChild(script);
}());
