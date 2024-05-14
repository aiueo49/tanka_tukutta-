import { Controller } from "stimulus"
import Autocomplete from "stimulus-autocomplete"

export default class extends Controller {
  static targets = [ "input", "hidden", "results" ]

  connect() {
    Autocomplete(this.inputTarget, this.getAutocompleteOptions())
  }

  getAutocompleteOptions() {
    return {
      url: '/search',
      getValue: item => item.name,
      onConfirm: item => {
        this.hiddenTarget.value = item.id
      }
    }
  }
}