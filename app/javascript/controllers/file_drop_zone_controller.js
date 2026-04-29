import { Controller } from "@hotwired/stimulus"

// Handles drag-and-drop and click-to-select for file upload zones.
// Connect to a wrapper that contains:
// - data-file-drop-zone-target="zone" (the drop area)
// - data-file-drop-zone-target="input" (hidden file input)
// - optional data-file-drop-zone-target="fileName" (element to show selected file name)
export default class extends Controller {
  static targets = ["zone", "input", "fileName"]

  connect() {
    this.zoneTarget.addEventListener("click", this.click.bind(this))
    this.zoneTarget.addEventListener("dragover", this.dragover.bind(this))
    this.zoneTarget.addEventListener("dragleave", this.dragleave.bind(this))
    this.zoneTarget.addEventListener("drop", this.drop.bind(this))
    this.inputTarget.addEventListener("change", this.change.bind(this))
  }

  disconnect() {
    this.zoneTarget.removeEventListener("click", this.click)
    this.zoneTarget.removeEventListener("dragover", this.dragover)
    this.zoneTarget.removeEventListener("dragleave", this.dragleave)
    this.zoneTarget.removeEventListener("drop", this.drop)
    this.inputTarget.removeEventListener("change", this.change)
  }

  click(e) {
    if (e.target === this.zoneTarget || e.target.closest("[data-click-browse]")) {
      e.preventDefault()
      this.inputTarget.click()
    }
  }

  dragover(e) {
    e.preventDefault()
    e.stopPropagation()
    this.zoneTarget.classList.add("border-yellow-400", "bg-yellow-50", "dark:bg-yellow-900/20")
  }

  dragleave(e) {
    e.preventDefault()
    e.stopPropagation()
    this.zoneTarget.classList.remove("border-yellow-400", "bg-yellow-50", "dark:bg-yellow-900/20")
  }

  drop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.zoneTarget.classList.remove("border-yellow-400", "bg-yellow-50", "dark:bg-yellow-900/20")
    const files = e.dataTransfer?.files
    if (files?.length) {
      this.inputTarget.files = files
      this.updateFileName(files[0])
    }
  }

  change() {
    const file = this.inputTarget.files?.[0]
    if (file) this.updateFileName(file)
  }

  updateFileName(file) {
    if (!this.hasFileNameTarget) return
    this.fileNameTarget.textContent = file.name
    this.fileNameTarget.classList.remove("hidden")
  }
}
