(function () {
  "use strict";
  document.addEventListener("click", function (e) {
    var btn = e.target.closest(".copy-btn");
    if (!btn) return;
    var wrap = btn.closest(".code-block");
    var code = wrap && wrap.querySelector("code, pre");
    if (!code) return;
    var text = code.innerText.replace(/\n$/, "");
    var done = function () {
      var label = btn.textContent;
      btn.textContent = "Copied";
      setTimeout(function () { btn.textContent = label; }, 1600);
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done).catch(function () {});
    }
  });
})();
