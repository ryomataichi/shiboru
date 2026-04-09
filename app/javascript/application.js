// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
document.addEventListener("turbo:load", () => {
  const icon = document.getElementById("search-icon");
  const form = document.getElementById("search-form");
  const btn = document.getElementById("qr-button");
  const modal = document.getElementById("qr-modal");

  if (icon && form) {
    icon.addEventListener("click", () => {
      const isHidden = form.classList.contains("hidden");

      form.classList.toggle("hidden");

      if (isHidden) {
        icon.innerHTML = '<i class="fa-solid fa-xmark"></i>';
      } else {
        icon.innerHTML = '<i class="fa-solid fa-magnifying-glass"></i>';
      }
    });
  }

  if (btn && modal) {
    btn.addEventListener("click", () => {
      modal.classList.toggle("hidden");
    });
  }
});