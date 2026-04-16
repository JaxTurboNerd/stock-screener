import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]

  submit() {
    if (!this.hasButtonTarget) return
    this.buttonTarget.disabled = true
    this.buttonTarget.value = "Analyzing\u2026"
    if (this.hasStatusTarget) this.statusTarget.classList.remove("hidden")
  }
}
