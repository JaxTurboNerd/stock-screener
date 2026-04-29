import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

const COLORS = [
  "#3B82F6", "#10B981", "#F59E0B", "#EF4444", "#8B5CF6",
  "#06B6D4", "#F97316", "#84CC16", "#EC4899", "#6B7280", "#14B8A6"
]

export default class extends Controller {
  static values = { sectors: Array }

  connect() {
    const sectors = this.sectorsValue
    new Chart(this.element.getContext("2d"), {
      type: "doughnut",
      data: {
        labels: sectors.map(s => s.name),
        datasets: [{
          data: sectors.map(s => parseFloat(s.percentage)),
          backgroundColor: COLORS.slice(0, sectors.length),
          borderWidth: 2,
          borderColor: "#1F2937"
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: {
            position: "bottom",
            labels: { color: "#D1D5DB", padding: 14, font: { size: 12 }, boxWidth: 12 }
          },
          tooltip: {
            callbacks: {
              label: (ctx) => ` ${ctx.label}: ${parseFloat(ctx.raw).toFixed(1)}%`
            }
          }
        }
      }
    })
  }
}
