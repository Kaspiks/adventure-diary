import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "optionInput", "correctRadio", "correctCheckbox", "removeBtn"]
  static values = {
    index: Number,
    type: { type: String, default: "single" } // "single" or "multiple"
  }

  connect() {
    this.updateRemoveButtons()
  }

  addOption(event) {
    event.preventDefault()
    
    const index = this.indexValue
    const isSingle = this.typeValue === "single"
    
    const newRow = document.createElement("div")
    newRow.className = "flex gap-2 mb-2"
    newRow.setAttribute("data-dynamic-options-target", "row")
    
    const inputName = `admin_challenges_form[fields_config][${index}][options][]`
    const correctName = isSingle 
      ? `admin_challenges_form[fields_config][${index}][correct_answer]`
      : `admin_challenges_form[fields_config][${index}][correct_answers][]`
    
    const inputType = isSingle ? "radio" : "checkbox"
    const inputAction = isSingle ? "input->dynamic-options#updateRadioValue" : "input->dynamic-options#updateCheckboxValue"
    const correctTarget = isSingle ? "correctRadio" : "correctCheckbox"
    
    newRow.innerHTML = `
      <input type="text" name="${inputName}" placeholder="Enter option..." 
             class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600"
             data-action="${inputAction}"
             data-dynamic-options-target="optionInput">
      <input type="${inputType}" name="${correctName}" value="" class="mt-2"
             data-dynamic-options-target="${correctTarget}">
      <button type="button" class="text-red-400 hover:text-red-300" 
              data-action="click->dynamic-options#removeOption"
              data-dynamic-options-target="removeBtn">
        <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
          <path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"/>
        </svg>
      </button>
    `
    
    // Insert before the "Add Option" button
    const addButton = event.target.closest("button")
    addButton.parentNode.insertBefore(newRow, addButton)
    
    this.updateRemoveButtons()
    
    // Focus the new input
    newRow.querySelector("input[type='text']").focus()
  }

  removeOption(event) {
    event.preventDefault()
    
    const row = event.target.closest("[data-dynamic-options-target='row']")
    if (row && this.rowTargets.length > 1) {
      row.remove()
      this.updateRemoveButtons()
    }
  }

  updateRadioValue(event) {
    const input = event.target
    const row = input.closest("[data-dynamic-options-target='row']")
    const radio = row.querySelector("[data-dynamic-options-target='correctRadio']")
    
    if (radio) {
      radio.value = input.value
    }
  }

  updateCheckboxValue(event) {
    const input = event.target
    const row = input.closest("[data-dynamic-options-target='row']")
    const checkbox = row.querySelector("[data-dynamic-options-target='correctCheckbox']")
    
    if (checkbox) {
      checkbox.value = input.value
    }
  }

  updateRemoveButtons() {
    const shouldShow = this.rowTargets.length > 1
    
    this.removeBtnTargets.forEach(btn => {
      btn.classList.toggle("hidden", !shouldShow)
    })
  }
}





