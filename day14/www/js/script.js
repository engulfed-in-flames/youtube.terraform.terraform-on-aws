// Simple client-side behavior for the S3 + CloudFront demo site.
(function () {
  "use strict";

  // ---------- Theme toggle (remembered per browser) ----------
  const THEME_KEY = "demo-theme";
  const themeBtn = document.getElementById("theme-toggle");

  function applyTheme(theme) {
    document.body.classList.toggle("dark", theme === "dark");
  }

  try {
    applyTheme(localStorage.getItem(THEME_KEY));
  } catch (e) {
    /* storage unavailable: ignore */
  }

  themeBtn.addEventListener("click", function () {
    const next = document.body.classList.contains("dark") ? "light" : "dark";
    applyTheme(next);
    try {
      localStorage.setItem(THEME_KEY, next);
    } catch (e) {
      /* ignore */
    }
  });

  // ---------- Live clock ----------
  const clockEl = document.getElementById("clock");
  function tick() {
    clockEl.textContent = new Date().toLocaleTimeString();
  }
  tick();
  setInterval(tick, 1000);

  // ---------- Click counter ----------
  let count = 0;
  const counterEl = document.getElementById("counter");
  document.getElementById("click-btn").addEventListener("click", function () {
    count += 1;
    counterEl.textContent = String(count);
  });

  // ---------- CloudFront header inspection ----------
  // Re-requests this page (same origin, so headers are readable) and shows
  // the headers CloudFront adds: X-Cache, X-Amz-Cf-Pop, Age, Via.
  const statusEl = document.getElementById("cf-status");
  const cacheEl = document.getElementById("cf-cache");
  const popEl = document.getElementById("cf-pop");
  const ageEl = document.getElementById("cf-age");

  function setStatus(text, cls) {
    statusEl.textContent = text;
    statusEl.className = cls || "";
  }

  async function checkHeaders() {
    setStatus("checking…");
    if (location.protocol === "file:") {
      setStatus("No (opened as a local file)", "warn");
      cacheEl.textContent = popEl.textContent = ageEl.textContent = "–";
      return;
    }
    try {
      // no-store skips the browser cache so the request reaches CloudFront
      const res = await fetch(location.pathname, { method: "HEAD", cache: "no-store" });
      const xCache = res.headers.get("x-cache");
      const pop = res.headers.get("x-amz-cf-pop");
      const age = res.headers.get("age");
      const via = res.headers.get("via") || "";

      const viaCloudFront = Boolean(pop) || /cloudfront/i.test(via) || /cloudfront/i.test(xCache || "");
      setStatus(viaCloudFront ? "Yes" : "No (direct / local server)", viaCloudFront ? "ok" : "warn");
      cacheEl.textContent = xCache || "–";
      cacheEl.className = /hit/i.test(xCache || "") ? "ok" : "";
      popEl.textContent = pop || "–";
      ageEl.textContent = age || "–";
    } catch (err) {
      setStatus("Could not read headers", "warn");
      console.error(err);
    }
  }

  document.getElementById("refresh-info").addEventListener("click", checkHeaders);
  checkHeaders();
})();
