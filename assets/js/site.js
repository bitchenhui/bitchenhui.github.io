(function () {
  "use strict";

  var root = document.documentElement;
  var themeToggle = document.getElementById("theme-toggle");
  var menuButton = document.getElementById("mobile-menu-button");
  var navigation = document.getElementById("primary-navigation");

  function updateThemeControl(theme) {
    if (!themeToggle) return;

    var isDark = theme === "dark";
    themeToggle.textContent = isDark ? "浅色" : "深色";
    themeToggle.setAttribute("aria-pressed", String(isDark));
    themeToggle.setAttribute("aria-label", isDark ? "切换为浅色模式" : "切换为深色模式");
  }

  var storedTheme = window.localStorage.getItem("site-theme");
  var initialTheme = storedTheme || (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");

  root.dataset.theme = initialTheme;
  updateThemeControl(initialTheme);

  if (themeToggle) {
    themeToggle.addEventListener("click", function () {
      var nextTheme = root.dataset.theme === "dark" ? "light" : "dark";
      root.dataset.theme = nextTheme;
      window.localStorage.setItem("site-theme", nextTheme);
      updateThemeControl(nextTheme);
    });
  }

  if (menuButton && navigation) {
    menuButton.addEventListener("click", function () {
      var isOpen = menuButton.getAttribute("aria-expanded") === "true";
      menuButton.setAttribute("aria-expanded", String(!isOpen));
      navigation.classList.toggle("is-open", !isOpen);
    });
  }
}());
