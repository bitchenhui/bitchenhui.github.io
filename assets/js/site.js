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
}());
