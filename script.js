(function () {
  "use strict";

  function highlightTerms() {
    var items = document.querySelectorAll("[data-term]");
    Array.prototype.forEach.call(items, function (el) {
      var card = el.closest(".card");
      if (!card) return;
      var term = el.getAttribute("data-term");
      var peers = card.querySelectorAll('[data-term="' + term + '"]');
      function set(on) {
        Array.prototype.forEach.call(peers, function (p) {
          p.classList.toggle("is-active", on);
        });
      }
      el.addEventListener("mouseenter", function () { set(true); });
      el.addEventListener("mouseleave", function () { set(false); });
      if (!el.classList.contains("term")) return;
      // Text terms only: a focus listener on an SVG node makes it a tab stop in Chromium.
      el.addEventListener("focus", function () { set(true); });
      el.addEventListener("blur", function () { set(false); });
      if (!el.hasAttribute("tabindex")) el.setAttribute("tabindex", "0");
    });
  }

  function trackSections() {
    var links = document.querySelectorAll('.site-nav a[href^="#"]');
    var sections = document.querySelectorAll("section[id]");
    if (!("IntersectionObserver" in window) || !links.length) return;
    var byId = {};
    Array.prototype.forEach.call(links, function (a) {
      byId[a.getAttribute("href").slice(1)] = a;
    });
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        Array.prototype.forEach.call(links, function (a) {
          a.removeAttribute("aria-current");
        });
        var link = byId[entry.target.id];
        if (link) link.setAttribute("aria-current", "true");
      });
    }, { rootMargin: "-40% 0px -55% 0px" });
    Array.prototype.forEach.call(sections, function (s) { observer.observe(s); });
  }

  function revealCards() {
    var cards = document.querySelectorAll(".card");
    if (!("IntersectionObserver" in window)) {
      Array.prototype.forEach.call(cards, function (c) { c.classList.add("is-visible"); });
      return;
    }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 });
    Array.prototype.forEach.call(cards, function (c) { observer.observe(c); });
  }

  function themeToggle() {
    var button = document.getElementById("theme-toggle");
    if (!button) return;
    var root = document.documentElement;
    function stored() {
      try { return localStorage.getItem("theme"); } catch (e) { return null; }
    }
    function current() {
      var s = stored();
      if (s === "dark" || s === "light") return s;
      return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
    }
    function apply(theme) {
      root.setAttribute("data-theme", theme);
      button.textContent = theme === "dark" ? "Light" : "Dark";
    }
    apply(current());
    button.addEventListener("click", function () {
      var next = root.getAttribute("data-theme") === "dark" ? "light" : "dark";
      try { localStorage.setItem("theme", next); } catch (e) { /* private window */ }
      apply(next);
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    highlightTerms();
    trackSections();
    revealCards();
    themeToggle();
  });
})();
