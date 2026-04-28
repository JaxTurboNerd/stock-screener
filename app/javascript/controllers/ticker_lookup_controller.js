import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]
  static values  = { url: String }

  connect() {
    this._timer = null
    document.addEventListener("click", this._onOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this._onOutsideClick)
  }

  search() {
    clearTimeout(this._timer)
    const q = this.inputTarget.value.trim()
    if (q.length < 1) { this._clear(); return }
    this._timer = setTimeout(() => this._fetch(q), 300)
  }

  select(event) {
    const { symbol } = event.currentTarget.dataset
    this.inputTarget.value = symbol
    this._clear()
  }

  _fetch(q) {
    fetch(`${this.urlValue}?q=${encodeURIComponent(q)}`)
      .then(r => r.json())
      .then(results => this._render(results))
      .catch(() => this._clear())
  }

  _render(results) {
    if (!results.length) { this._clear(); return }
    this.dropdownTarget.innerHTML = results.map(r => `
      <button type="button"
        class="w-full text-left px-4 py-2 hover:bg-blue-50 dark:hover:bg-blue-900/30 text-sm text-gray-900 dark:text-white flex justify-between gap-4"
        data-action="click->ticker-lookup#select"
        data-symbol="${r.symbol}"
        data-name="${this._esc(r.name || '')}">
        <span class="font-semibold tracking-wide">${r.symbol}</span>
        <span class="text-gray-500 dark:text-gray-400 truncate">${this._esc(r.name || '')}</span>
      </button>`).join("")
    this.dropdownTarget.classList.remove("hidden")
  }

  _clear() {
    this.dropdownTarget.innerHTML = ""
    this.dropdownTarget.classList.add("hidden")
  }

  _esc(str) {
    return str.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")
  }

  _onOutsideClick = (e) => {
    if (!this.element.contains(e.target)) this._clear()
  }
}
