import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.updateCount()
  }

  toggleAll(event) {
    const checkbox = event.currentTarget
    const resource = checkbox.dataset.resource
    const isChecked = checkbox.checked

    const permissionCheckboxes = this.element.querySelectorAll(
      `input[type="checkbox"][data-resource="${resource}"]:not([data-action*="toggleAll"])`
    )

    permissionCheckboxes.forEach(cb => {
      cb.checked = isChecked
    })

    this.updateCount()
  }

  updateCount() {
    const allCheckboxes = this.element.querySelectorAll(
      'input[type="checkbox"][name="admin_roles_form[permission_ids][]"]'
    )
    const checkedCount = Array.from(allCheckboxes).filter(cb => cb.checked).length

    const countElement = this.element.querySelector('#permission-count')
    if (countElement) {
      countElement.textContent = checkedCount
    }

    this.updateSelectAllStates()
  }

  updateSelectAllStates() {
    const selectAllCheckboxes = this.element.querySelectorAll(
      'input[type="checkbox"][data-action*="toggleAll"]'
    )

    selectAllCheckboxes.forEach(selectAll => {
      const resource = selectAll.dataset.resource
      const resourceCheckboxes = this.element.querySelectorAll(
        `input[type="checkbox"][data-resource="${resource}"]:not([data-action*="toggleAll"])`
      )
      
      const allChecked = Array.from(resourceCheckboxes).every(cb => cb.checked)
      const someChecked = Array.from(resourceCheckboxes).some(cb => cb.checked)
      
      selectAll.checked = allChecked
      selectAll.indeterminate = someChecked && !allChecked
    })
  }
}
