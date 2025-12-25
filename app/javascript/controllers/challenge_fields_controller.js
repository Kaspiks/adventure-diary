import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "fieldType", "select"]

  connect() {
    // Count existing fields to get next index
    this.fieldIndex = this.containerTarget.children.length
  }

  addField(event) {
    const fieldType = event.target.value
    console.log('addField called with type:', fieldType)
    
    if (!fieldType) {
      console.log('No field type selected')
      return
    }

    // Reset select
    event.target.value = ""

    const fieldIndex = this.fieldIndex++
    console.log('Adding field at index:', fieldIndex)
    
    const fieldData = this.getFieldTemplate(fieldType, fieldIndex)
    
    const tempDiv = document.createElement("div")
    tempDiv.innerHTML = fieldData
    const fieldElement = tempDiv.firstElementChild
    
    if (fieldElement) {
      this.containerTarget.appendChild(fieldElement)
      console.log('Field added successfully')
    } else {
      console.error('Failed to create field element')
    }
  }

  removeField(event) {
    event.target.closest(".field-item")?.remove()
  }

  generateId() {
    return 'field_' + Math.random().toString(36).substr(2, 9)
  }

  getFieldTemplate(fieldType, index) {
    const fieldId = this.generateId()
    const baseFields = `
      <input type="hidden" name="admin_challenges_form[fields_config][${index}][id]" value="${fieldId}">
      <input type="hidden" name="admin_challenges_form[fields_config][${index}][type]" value="${fieldType}" id="field_type_${index}">
      <div class="grid grid-cols-2 gap-4">
        <div class="space-y-2">
          <label class="block text-sm font-medium text-slate-300">Field Label</label>
          <input type="text" name="admin_challenges_form[fields_config][${index}][label]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
        </div>
        <div class="space-y-2">
          <label class="block text-sm font-medium text-slate-300">Points</label>
          <input type="number" name="admin_challenges_form[fields_config][${index}][points]" min="0" value="0" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
        </div>
      </div>
      <div class="space-y-2 mt-4">
        <label class="block text-sm font-medium text-slate-300">Instructions</label>
        <textarea name="admin_challenges_form[fields_config][${index}][instructions]" rows="2" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"></textarea>
      </div>
    `

    const fieldTypes = {
      text_input: {
        label: "Text Input",
        fields: baseFields + `
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Correct Answer</label>
            <input type="text" name="admin_challenges_form[fields_config][${index}][correct_answer]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
          </div>
        `
      },
      single_choice: {
        label: "Single Choice",
        fields: baseFields + `
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Options</label>
            <div class="space-y-2" data-controller="dynamic-options">
              <div class="flex gap-2 mb-2">
                <input type="text" name="admin_challenges_form[fields_config][${index}][options][]" placeholder="Option 1" class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600">
                <input type="radio" name="admin_challenges_form[fields_config][${index}][correct_answer]" value="" class="mt-2">
              </div>
              <div class="flex gap-2 mb-2">
                <input type="text" name="admin_challenges_form[fields_config][${index}][options][]" placeholder="Option 2" class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600">
                <input type="radio" name="admin_challenges_form[fields_config][${index}][correct_answer]" value="" class="mt-2">
              </div>
              <button type="button" class="text-sm text-emerald-400 hover:text-emerald-300" data-action="click->dynamic-options#addOption">Add Option</button>
            </div>
          </div>
        `
      },
      multiple_choice: {
        label: "Multiple Choice",
        fields: baseFields + `
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Options</label>
            <div class="space-y-2" data-controller="dynamic-options">
              <div class="flex gap-2 mb-2">
                <input type="text" name="admin_challenges_form[fields_config][${index}][options][]" placeholder="Option 1" class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600">
                <input type="checkbox" name="admin_challenges_form[fields_config][${index}][correct_answers][]" value="" class="mt-2">
              </div>
              <div class="flex gap-2 mb-2">
                <input type="text" name="admin_challenges_form[fields_config][${index}][options][]" placeholder="Option 2" class="flex-1 px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600">
                <input type="checkbox" name="admin_challenges_form[fields_config][${index}][correct_answers][]" value="" class="mt-2">
              </div>
              <button type="button" class="text-sm text-emerald-400 hover:text-emerald-300" data-action="click->dynamic-options#addOption">Add Option</button>
            </div>
          </div>
        `
      },
      hidden_letter: {
        label: "Hidden Letter",
        fields: baseFields + `
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Puzzle Image URL</label>
            <input type="url" name="admin_challenges_form[fields_config][${index}][image_url]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
          </div>
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Display Text</label>
            <input type="text" name="admin_challenges_form[fields_config][${index}][display_text]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
          </div>
          <div class="grid grid-cols-2 gap-4 mt-4">
            <div class="space-y-2">
              <label class="block text-sm font-medium text-slate-300">Number of Blanks</label>
              <input type="number" name="admin_challenges_form[fields_config][${index}][number_of_blanks]" min="1" value="1" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
            </div>
            <div class="space-y-2">
              <label class="block text-sm font-medium text-slate-300">Expected Answer</label>
              <input type="text" name="admin_challenges_form[fields_config][${index}][correct_answer]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
            </div>
          </div>
          <div class="space-y-2 mt-4">
            <label class="block text-sm font-medium text-slate-300">Hint</label>
            <input type="text" name="admin_challenges_form[fields_config][${index}][hint]" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
          </div>
          <div class="flex items-center gap-4 mt-4">
            <input type="checkbox" name="admin_challenges_form[fields_config][${index}][case_sensitive]" value="1" class="w-5 h-5 rounded text-emerald-500 bg-slate-700 border-slate-600">
            <label class="text-sm font-medium text-slate-300">Case Sensitive</label>
          </div>
        `
      },
      photo_upload: {
        label: "Photo Upload",
        fields: baseFields + `
          <div class="grid grid-cols-2 gap-4 mt-4">
            <div class="space-y-2">
              <label class="block text-sm font-medium text-slate-300">Max Photos</label>
              <input type="number" name="admin_challenges_form[fields_config][${index}][max_photos]" min="1" value="1" class="w-full px-3 py-2 rounded-lg text-white bg-slate-700 border border-slate-600 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500">
            </div>
            <div class="flex items-center gap-4 mt-6">
              <input type="checkbox" name="admin_challenges_form[fields_config][${index}][require_caption]" value="1" class="w-5 h-5 rounded text-emerald-500 bg-slate-700 border-slate-600">
              <label class="text-sm font-medium text-slate-300">Require Caption</label>
            </div>
          </div>
        `
      }
    }

    const template = fieldTypes[fieldType] || fieldTypes.text_input
    
    return `
      <div class="field-item rounded-lg border p-4 mb-4 bg-slate-700/50 border-slate-600" data-field-index="${index}">
        <div class="flex items-start justify-between mb-3">
          <h3 class="text-md font-medium text-white">${template.label}</h3>
          <button type="button" class="text-red-400 hover:text-red-300" data-action="click->challenge-fields#removeField">
            <svg class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M8.75 1A2.75 2.75 0 006 3.75v.443c-.795.077-1.584.176-2.365.298a.75.75 0 10.23 1.482l.149-.022.841 10.518A2.75 2.75 0 007.596 19h4.807a2.75 2.75 0 002.742-2.53l.841-10.519.149.023a.75.75 0 00.23-1.482A41.03 41.03 0 0014 4.193V3.75A2.75 2.75 0 0011.25 1h-2.5z" clip-rule="evenodd"/>
            </svg>
          </button>
        </div>
        ${template.fields}
        <div class="flex items-center gap-4 mt-4">
          <input type="checkbox" name="admin_challenges_form[fields_config][${index}][required]" value="1" checked class="w-5 h-5 rounded text-emerald-500 bg-slate-700 border-slate-600">
          <label class="text-sm font-medium text-slate-300">Required</label>
        </div>
      </div>
    `
  }
}

