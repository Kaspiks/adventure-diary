import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = ["label"]

  connect() {
    // Initialize field configuration
  }

  updateLabel(event) {
    const newLabel = event.target.value || "New Field"
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = newLabel
    }
  }
}





