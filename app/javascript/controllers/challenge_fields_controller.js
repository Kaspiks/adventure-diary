import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "fieldType", "select", "template"]
  static values = {
    formPrefix: { type: String, default: "admin_challenges_form" },
    defaults: { type: Object, default: {} }
  }

  connect() {
    this.fieldIndex = this.containerTarget.querySelectorAll(".field-item").length
  }

  getDefaults(fieldType) {
    return this.defaultsValue[fieldType] || {}
  }

  addField(event) {
    const fieldType = event.target.value
    
    if (!fieldType) {
      return
    }

    event.target.value = ""

    const fieldIndex = this.fieldIndex++
    const fieldId = this.generateId()
    const fieldData = this.getFieldTemplate(fieldType, fieldIndex, fieldId)
    
    const tempDiv = document.createElement("div")
    tempDiv.innerHTML = fieldData
    const fieldElement = tempDiv.firstElementChild
    
    if (fieldElement) {
      this.containerTarget.appendChild(fieldElement)
      
      requestAnimationFrame(() => {
        fieldElement.style.opacity = "1"
        fieldElement.style.transform = "translateX(0)"
      })
      
      const labelInput = fieldElement.querySelector("input[name*='[label]']")
      if (labelInput) {
        setTimeout(() => labelInput.focus(), 50)
      }
    }
  }

  removeField(event) {
    const fieldItem = event.target.closest(".field-item")
    if (fieldItem) {
      fieldItem.style.opacity = "0"
      fieldItem.style.transform = "translateX(-20px)"
      fieldItem.style.transition = "opacity 0.2s, transform 0.2s"
      
      setTimeout(() => fieldItem.remove(), 200)
    }
  }

  generateId() {
    return 'field_' + Math.random().toString(36).substr(2, 9)
  }

  getFieldTemplate(fieldType, index, fieldId) {
    const prefix = this.formPrefixValue
    
    const baseFields = this.getBaseFieldsTemplate(prefix, index, fieldId, fieldType)
    
    const typeFields = this.getTypeSpecificFields(fieldType, prefix, index)
    
    const fieldTypes = {
      text_input: { label: "Text Input", icon: "text" },
      single_choice: { label: "Single Choice", icon: "radio" },
      multiple_choice: { label: "Multiple Choice", icon: "checkbox" },
      hidden_letter: { label: "Hidden Letter", icon: "eye" },
      photo_upload: { label: "Photo Upload", icon: "camera" }
    }

    const template = fieldTypes[fieldType] || { label: "Unknown Field", icon: "text" }
    const defaults = this.getDefaults(fieldType)
    const requiredChecked = defaults.required !== false ? "checked" : ""
    
    return `
      <div class="field-item rounded-lg border p-4 mb-4 bg-slate-700/50 border-slate-600" data-field-index="${index}" data-controller="field-config" style="opacity: 0; transform: translateX(-20px); transition: opacity 0.2s, transform 0.2s;">
        <div class="flex items-start justify-between mb-3">
          <div class="flex items-center gap-2">
            <h3 class="text-md font-medium text-white" data-field-config-target="label">${template.label}</h3>
          </div>
          <button type="button" class="text-red-400 hover:text-red-300" data-action="click->challenge-fields#removeField">
            <svg class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.519.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5z" clip-rule="evenodd"/>
            </svg>
          </button>
        </div>
        ${baseFields}
        ${typeFields}
        <div class="flex items-center gap-4 mt-4">
          <input type="checkbox" name="${prefix}[fields_config][${index}][required]" value="1" ${requiredChecked} class="w-5 h-5 rounded text-emerald-500 bg-slate-700 border-slate-600">
          <label class="text-sm font-medium text-slate-300">Required</label>
        </div>
      </div>
    `
  }

  getBaseFieldsTemplate(prefix, index, fieldId, fieldType) {
    const defaults = this.getDefaults(fieldType)
    const pointsDefault = defaults.points !== undefined ? defaults.points : 0
    
    return `
      <input type="hidden" name="${prefix}[fields_config][${index}][id]" value="${fieldId}">
      <input type="hidden" name="${prefix}[fields_config][${index}][type]" value="${fieldType}" id="field_type_${index}">
      <div class="grid grid-cols-2 gap-4">
        <div class="space-y-2">
          <label class="block text-sm font-medium text-slate-300">Field Label</label>
          <input type="text" name="${prefix}[fields_config][${index}][label]" 
                 class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
                 data-action="input->field-config#updateLabel">
        </div>
        <div class="space-y-2">
          <label class="block text-sm font-medium text-slate-300">Points</label>
          <input type="number" name="${prefix}[fields_config][${index}][points]" min="0" value="${pointsDefault}" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
        </div>
      </div>
      <div class="space-y-2 mt-4">
        <label class="block text-sm font-medium text-slate-300">Instructions</label>
        <textarea name="${prefix}[fields_config][${index}][instructions]" rows="2" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"></textarea>
      </div>
    `
  }

  getTypeSpecificFields(fieldType, prefix, index) {
    switch (fieldType) {
      case "text_input":
        return `
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Correct Answer</label>
            <input type="text" name="${prefix}[fields_config][${index}][correct_answer]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
          </div>
        `
      
      case "single_choice":
        return `
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Options</label>
            <div class="space-y-2" data-controller="dynamic-options" data-dynamic-options-index-value="${index}" data-dynamic-options-type-value="single">
              <div class="flex gap-2 mb-2" data-dynamic-options-target="row">
                <input type="text" name="${prefix}[fields_config][${index}][options][]" placeholder="Option 1" 
                       class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600"
                       data-action="input->dynamic-options#updateRadioValue"
                       data-dynamic-options-target="optionInput">
                <input type="radio" name="${prefix}[fields_config][${index}][correct_answer]" value="" class="mt-2" data-dynamic-options-target="correctRadio">
                <button type="button" class="text-red-400 hover:text-red-300 hidden" data-action="click->dynamic-options#removeOption" data-dynamic-options-target="removeBtn">
                  <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"/>
                  </svg>
                </button>
              </div>
              <div class="flex gap-2 mb-2" data-dynamic-options-target="row">
                <input type="text" name="${prefix}[fields_config][${index}][options][]" placeholder="Option 2" 
                       class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600"
                       data-action="input->dynamic-options#updateRadioValue"
                       data-dynamic-options-target="optionInput">
                <input type="radio" name="${prefix}[fields_config][${index}][correct_answer]" value="" class="mt-2" data-dynamic-options-target="correctRadio">
                <button type="button" class="text-red-400 hover:text-red-300" data-action="click->dynamic-options#removeOption" data-dynamic-options-target="removeBtn">
                  <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"/>
                  </svg>
                </button>
              </div>
              <button type="button" class="text-sm text-emerald-400 hover:text-emerald-300" data-action="click->dynamic-options#addOption">Add Option</button>
            </div>
          </div>
        `
      
      case "multiple_choice":
        return `
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Options</label>
            <div class="space-y-2" data-controller="dynamic-options" data-dynamic-options-index-value="${index}" data-dynamic-options-type-value="multiple">
              <div class="flex gap-2 mb-2" data-dynamic-options-target="row">
                <input type="text" name="${prefix}[fields_config][${index}][options][]" placeholder="Option 1" 
                       class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600"
                       data-action="input->dynamic-options#updateCheckboxValue"
                       data-dynamic-options-target="optionInput">
                <input type="checkbox" name="${prefix}[fields_config][${index}][correct_answers][]" value="" class="mt-2" data-dynamic-options-target="correctCheckbox">
                <button type="button" class="text-red-400 hover:text-red-300 hidden" data-action="click->dynamic-options#removeOption" data-dynamic-options-target="removeBtn">
                  <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"/>
                  </svg>
                </button>
              </div>
              <div class="flex gap-2 mb-2" data-dynamic-options-target="row">
                <input type="text" name="${prefix}[fields_config][${index}][options][]" placeholder="Option 2" 
                       class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600"
                       data-action="input->dynamic-options#updateCheckboxValue"
                       data-dynamic-options-target="optionInput">
                <input type="checkbox" name="${prefix}[fields_config][${index}][correct_answers][]" value="" class="mt-2" data-dynamic-options-target="correctCheckbox">
                <button type="button" class="text-red-400 hover:text-red-300" data-action="click->dynamic-options#removeOption" data-dynamic-options-target="removeBtn">
                  <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z"/>
                  </svg>
                </button>
              </div>
              <button type="button" class="text-sm text-emerald-400 hover:text-emerald-300" data-action="click->dynamic-options#addOption">Add Option</button>
            </div>
          </div>
        `
      
      case "hidden_letter":
        const hlDefaults = this.getDefaults("hidden_letter")
        const numBlanks = hlDefaults.number_of_blanks || 1
        const caseSensitive = hlDefaults.case_sensitive ? "checked" : ""
        
        return `
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Puzzle Image URL</label>
            <input type="url" name="${prefix}[fields_config][${index}][image_url]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
          </div>
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Display Text</label>
            <input type="text" name="${prefix}[fields_config][${index}][display_text]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
          </div>
          <div class="grid grid-cols-2 gap-4 mt-4">
            <div class="space-y-2">
              <label class="block text-sm font-medium text-slate-300">Number of Blanks</label>
              <input type="number" name="${prefix}[fields_config][${index}][number_of_blanks]" min="1" value="${numBlanks}" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
            </div>
            <div class="space-y-2">
              <label class="block text-sm font-medium text-slate-300">Expected Answer</label>
              <input type="text" name="${prefix}[fields_config][${index}][correct_answer]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
            </div>
          </div>
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Hint</label>
            <input type="text" name="${prefix}[fields_config][${index}][hint]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
          </div>
          <div class="flex items-center gap-4 mt-4">
            <input type="checkbox" name="${prefix}[fields_config][${index}][case_sensitive]" value="1" ${caseSensitive} class="w-5 h-5 rounded text-emerald-500 bg-slate-700 border-slate-600">
            <label class="text-sm font-medium text-slate-300">Case Sensitive</label>
          </div>
        `
      
      case "photo_upload":
        const puDefaults = this.getDefaults("photo_upload")
        const maxPhotos = puDefaults.max_photos || 1
        const requireCaption = puDefaults.require_caption ? "checked" : ""
        
        return `
          <div class="grid grid-cols-2 gap-4 mt-4">
            <div class="space-y-2">
              <label class="block text-sm font-medium text-slate-300">Max Photos</label>
              <input type="number" name="${prefix}[fields_config][${index}][max_photos]" min="1" value="${maxPhotos}" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
            </div>
            <div class="flex items-center gap-4 mt-6">
              <input type="checkbox" name="${prefix}[fields_config][${index}][require_caption]" value="1" ${requireCaption} class="w-5 h-5 rounded text-emerald-500 bg-slate-700 border-slate-600">
              <label class="text-sm font-medium text-slate-300">Require Caption</label>
            </div>
          </div>
        `
      
      default:
        return ""
    }
  }
}
