// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
document.addEventListener("turbo:load", () => {
  const icon = document.getElementById("search-icon");
  const form = document.getElementById("search-form");
  const openQrBtn = document.getElementById("open-qr-button");
  const closeQrBtn = document.getElementById("close-qr-button");
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

  if (openQrBtn && modal) {
    openQrBtn.addEventListener("click", () => {
      modal.classList.remove("hidden");
    });
  }

  if (closeQrBtn && modal) {
    closeQrBtn.addEventListener("click", () => {
      modal.classList.add("hidden");
    });
  }
});

document.addEventListener("turbo:load", () => {
const containers = document.querySelectorAll(".edit-image-container, .show-scroll");

containers.forEach((container) => { if (!container) return;

  let items = Array.from(container.querySelectorAll(".image_item"));
  if (items.length === 0) return;

  let snapTimer = null;
  let autoScrollTimer = null;
  let isAutoScrolling = false;

  function refreshItems() {
    items = Array.from(container.querySelectorAll(".image_item"));
  }

  function getMaxScrollLeft() {
    return Math.max(container.scrollWidth - container.clientWidth, 0);
  }

  function clampScrollLeft(value) {
    return Math.max(0, Math.min(value, getMaxScrollLeft()));
  }

  function updateSidePadding() {
    refreshItems();
    if (items.length === 0) return;

    const firstItem = items[0];
    const lastItem = items[items.length - 1];

    const leftPadding = Math.max((container.clientWidth - firstItem.offsetWidth) / 2, 0);
    const rightPadding = Math.max((container.clientWidth - lastItem.offsetWidth) / 2, 0);

    container.style.paddingLeft = `${leftPadding}px`;
    container.style.paddingRight = `${rightPadding}px`;
  }

  function getContainerCenterX() {
    const rect = container.getBoundingClientRect();
    return rect.left + rect.width / 2;
  }

  function getItemCenterX(item) {
    const rect = item.getBoundingClientRect();
    return rect.left + rect.width / 2;
  }

  function findClosestItem() {
    const containerCenterX = getContainerCenterX();

    let closestItem = null;
    let minDistance = Infinity;

    items.forEach((item) => {
      const distance = Math.abs(getItemCenterX(item) - containerCenterX);
      if (distance < minDistance) {
        minDistance = distance;
        closestItem = item;
      }
    });

    return closestItem;
  }

  function getTargetScrollLeft(item) {
    const containerRect = container.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();

    const itemCenterInViewport = itemRect.left + itemRect.width / 2;
    const containerCenterInViewport = containerRect.left + containerRect.width / 2;
    const delta = itemCenterInViewport - containerCenterInViewport;

    return clampScrollLeft(container.scrollLeft + delta);
  }

  function scrollItemToCenter(item) {
    if (!item) return;

    const targetScrollLeft = getTargetScrollLeft(item);

    // ほぼ同じ位置なら無駄に動かさない
    if (Math.abs(container.scrollLeft - targetScrollLeft) < 1) return;

    isAutoScrolling = true;

    container.scrollTo({
      left: targetScrollLeft,
      behavior: "smooth"
    });

    clearTimeout(autoScrollTimer);
    autoScrollTimer = setTimeout(() => {
      isAutoScrolling = false;
    }, 500);
  }

  function snapToClosest() {
    if (isAutoScrolling) return;
    scrollItemToCenter(findClosestItem());
  }

  function initializeSlider() {
    updateSidePadding();
    snapToClosest();
  }

  container.addEventListener("scroll", () => {
    if (isAutoScrolling) return;

    clearTimeout(snapTimer);
    snapTimer = setTimeout(() => {
      snapToClosest();
    }, 180);
  });

  window.addEventListener("resize", () => {
    clearTimeout(snapTimer);
    snapTimer = setTimeout(() => {
      updateSidePadding();
      snapToClosest();
    }, 180);
  });

  const images = container.querySelectorAll("img");
  let loadedCount = 0;

  if (images.length === 0) {
    requestAnimationFrame(() => {
      initializeSlider();
    });
  } else {
    images.forEach((img) => {
      if (img.complete) {
        loadedCount += 1;
      } else {
        img.addEventListener(
          "load",
          () => {
            loadedCount += 1;
            if (loadedCount === images.length) {
              updateSidePadding();
              snapToClosest();
            }
          },
          { once: true }
        );
      }
    });

    if (loadedCount === images.length) {
      requestAnimationFrame(() => {
        initializeSlider();
      });
    }
  }
});
});