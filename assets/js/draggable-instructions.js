// assets/js/draggable-instructions.js
(function () {
  const el = document.getElementById("instructions-card");
  if (!el) return;

  const key = el.dataset.key || "playground-instructions-state";
  const handle = el.querySelector("[data-drag-handle]") || el;
  const body = el.querySelector(".card-body");
  const btnMin = document.getElementById("instr-minimise");
  const btnClose = document.getElementById("instr-close");

  // restore state
  try {
    const saved = JSON.parse(localStorage.getItem(key) || "{}");
    if (saved.left != null && saved.top != null) {
      el.style.left = saved.left + "px";
      el.style.top = saved.top + "px";
      el.style.right = "auto";
      el.style.bottom = "auto";
    }
    if (saved.minimised) body.style.display = "none";
    if (saved.closed) el.style.display = "none";
  } catch (e) { /* ignore parse errors */ }

  // drag state
  let dragging = false;
  let offsetX = 0;
  let offsetY = 0;

  const startDrag = (e) => {
    const rect = el.getBoundingClientRect();
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    offsetX = clientX - rect.left;
    offsetY = clientY - rect.top;
    dragging = true;
    document.addEventListener("mousemove", onMove);
    document.addEventListener("touchmove", onMove, { passive: false });
    document.addEventListener("mouseup", endDrag);
    document.addEventListener("touchend", endDrag);
    el.classList.add("dragging");
  };

  const onMove = (e) => {
    if (!dragging) return;
    e.preventDefault();
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const clientY = e.touches ? e.touches[0].clientY : e.clientY;
    const left = Math.max(8, clientX - offsetX);
    const top = Math.max(8, clientY - offsetY);
    el.style.left = left + "px";
    el.style.top = top + "px";
    el.style.right = "auto";
    el.style.bottom = "auto";
  };

  const endDrag = () => {
    if (!dragging) return;
    dragging = false;
    document.removeEventListener("mousemove", onMove);
    document.removeEventListener("touchmove", onMove);
    document.removeEventListener("mouseup", endDrag);
    document.removeEventListener("touchend", endDrag);
    el.classList.remove("dragging");
    persist();
  };

  const persist = () => {
    try {
      const rect = el.getBoundingClientRect();
      const saved = JSON.parse(localStorage.getItem(key) || "{}");
      saved.left = Math.round(rect.left);
      saved.top = Math.round(rect.top);
      saved.minimised = body.style.display === "none";
      saved.closed = el.style.display === "none";
      localStorage.setItem(key, JSON.stringify(saved));
    } catch (e) { /* ignore */ }
  };

  // minimise and close handlers
  if (btnMin) {
    btnMin.addEventListener("click", () => {
      body.style.display = body.style.display === "none" ? "" : "none";
      persist();
    });
  }

  if (btnClose) {
    btnClose.addEventListener("click", () => {
      el.style.display = "none";
      persist();
    });
  }

  // keyboard nudging for accessibility
  el.addEventListener("keydown", (ev) => {
    const step = ev.shiftKey ? 20 : 8;
    const rect = el.getBoundingClientRect();
    let left = rect.left;
    let top = rect.top;
    if (ev.key === "ArrowLeft") left = Math.max(8, left - step);
    if (ev.key === "ArrowRight") left = left + step;
    if (ev.key === "ArrowUp") top = Math.max(8, top - step);
    if (ev.key === "ArrowDown") top = top + step;
    el.style.left = left + "px";
    el.style.top = top + "px";
    persist();
  });

  // attach drag listeners
  handle.addEventListener("mousedown", startDrag);
  handle.addEventListener("touchstart", startDrag, { passive: true });

  // ensure focusable for keyboard users
  el.setAttribute("tabindex", "0");
})();