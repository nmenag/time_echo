import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { locale: String };

  async connect() {
    const { default: flatpickr } = await import("flatpickr");
    const locale =
      this.localeValue === "es"
        ? (await import("flatpickr_l10n_es")).Spanish
        : undefined;

    this.picker = flatpickr(this.element, {
      dateFormat: "Y-m-d",
      allowInput: true,
      locale,
      minDate: this.element.getAttribute("min") || "today",
      onChange: () =>
        this.element.dispatchEvent(new Event("change", { bubbles: true })),
    });
  }

  disconnect() {
    this.picker?.destroy();
  }
}
