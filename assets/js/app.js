// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Chart from 'chart.js/auto';
import { jsPDF } from "jspdf";
import "./draggable-instructions";

let Hooks = {};
let chartInstance;

Hooks.ItemsChart = {
  mounted() {
    this.renderChart();
  },

  updated() {
    this.renderChart();
  },

  renderChart() {
    const labels = JSON.parse(this.el.dataset.labels)
    const values = JSON.parse(this.el.dataset.values).map(Number)
    const colors = JSON.parse(this.el.dataset.colors)
    const ctx = this.el.getContext("2d");
     const type = this.el.dataset.chartType;
    console.log("LABELS RAW:", this.el.dataset.labels)
    console.log("VALUES RAW:", this.el.dataset.values)
    console.log("COLORS RAW:", this.el.dataset.colors)
     
    if (chartInstance) {
      chartInstance.destroy();
    }

    chartInstance = new Chart(ctx, {
      type: type,
      data: {
        labels: labels,
        datasets: [{
          label: "Submitted Items",
          data: values,
          backgroundColor: colors,
          borderColor: "#333",
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        ...(type === "bar" && {
          scales: {
            y: {
              beginAtZero: true
            }
          }
        })
      }
    });
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks 
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(144, 11, 11, 0.3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())
window.addEventListener("phx:download_json", (e) => {
  const blob = new Blob([e.detail.json], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "qb_elixir_notes.json";
  a.click();
  URL.revokeObjectURL(url);
});

Hooks.JsonLoader = {
  mounted() {
     console.log("JsonLoader mounted");
    this.el.addEventListener("change", async (e) => {
      const file = e.target.files[0];
      if (!file) return;

    try {
        const text = await file.text();
        console.log("Raw file content:", text);

        const data = JSON.parse(text);
        console.log("Parsed JSON:", data);

        this.pushEvent("load_json", { notes: data });
        console.log("pushEvent sent");
      } catch (err) {
        console.error("Error parsing JSON:", err);
      }

    });
  }
};

Hooks.ExportPDF = {
  mounted() {
    this.handleEvent("export_pdf", ({ notes }) => {
      const canvas = document.getElementById("items-chart")
      if (!canvas) return

      // High‑resolution export
      const scale = 2
      const tempCanvas = document.createElement("canvas")
      tempCanvas.width = canvas.width * scale
      tempCanvas.height = canvas.height * scale

      const ctx = tempCanvas.getContext("2d")
      ctx.scale(scale, scale)
      ctx.drawImage(canvas, 0, 0)

      const imgData = tempCanvas.toDataURL("image/png")

      const pdf = new jsPDF({
        orientation: "portrait",
        unit: "px",
        format: "a4"
      })

      // Chart image
      pdf.addImage(imgData, "PNG", 10, 10, 400, 200)

      // Title
      pdf.setFontSize(16)
      pdf.text("Items & Quantities", 10, 230)

      // Notes list
      pdf.setFontSize(12)
      let y = 250

      notes.forEach(n => {
        pdf.text(`• ${n.content}: ${n.value}`, 10, y)
        y += 16
      })

      pdf.save("chart.pdf")
    })
  }
}

export default Hooks;


// connect if there are any LiveViews on the page
liveSocket.connect()

window.liveSocket = liveSocket

