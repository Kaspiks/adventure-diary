import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor"]
  static values = {
    height: { type: Number, default: 400 }
  }

  connect() {
    this.loadTinyMCE()
  }

  disconnect() {
    if (typeof tinymce !== 'undefined') {
      this.editorTargets.forEach(target => {
        const editor = tinymce.get(target.id)
        if (editor) {
          editor.remove()
        }
      })
    }
  }

  loadTinyMCE() {
    if (typeof tinymce !== 'undefined') {
      this.initEditor()
      return
    }

    if (document.querySelector('script[src*="tinymce"]')) {
      this.waitForTinyMCE()
      return
    }

    const script = document.createElement('script')
    script.src = 'https://cdn.jsdelivr.net/npm/tinymce@6/tinymce.min.js'
    script.onload = () => this.initEditor()
    document.head.appendChild(script)
  }

  waitForTinyMCE() {
    const checkInterval = setInterval(() => {
      if (typeof tinymce !== 'undefined') {
        clearInterval(checkInterval)
        this.initEditor()
      }
    }, 50)

    setTimeout(() => clearInterval(checkInterval), 5000)
  }

  initEditor() {
    if (typeof tinymce === 'undefined') return

    this.editorTargets.forEach(target => {
      if (!target.id) {
        target.id = `tinymce-${Math.random().toString(36).substr(2, 9)}`
      }

      const existingEditor = tinymce.get(target.id)
      if (existingEditor) {
        existingEditor.remove()
      }

      tinymce.init({
        target: target,
        skin: 'oxide-dark',
        content_css: 'dark',
        height: this.heightValue,
        menubar: true,
        plugins: 'advlist autolink lists link image charmap preview anchor searchreplace visualblocks code fullscreen insertdatetime media table help wordcount',
        toolbar: 'undo redo | blocks | bold italic forecolor | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | removeformat | help',
        content_style: 'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; font-size: 14px; background: #1e293b; color: #e2e8f0; }',
        setup: (editor) => {
          editor.on('change', () => editor.save())
          editor.on('blur', () => editor.save())
        }
      })
    })
  }
}





