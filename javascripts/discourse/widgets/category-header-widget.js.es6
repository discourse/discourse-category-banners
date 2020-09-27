import { h } from "virtual-dom";
import { iconNode } from "discourse-common/lib/icon-library";
import { createWidget } from "discourse/widgets/widget";

function buildCategory(category) {
  const content = [];

  if (category.read_restricted) {
    content.push(iconNode("lock"));
  }

  content.push(h("h1.category-title", category.name));

  if (settings.show_description) {
    content.push(
      h(
        "div.category-title-description",
        h("div.cooked", { innerHTML: category.description })
      )
    );
  }

  return content;
}

export default createWidget("category-header-widget", {
  tagName: "span.discourse-category-banners",

  html() {
    const path = window.location.pathname;
    const category = this.register
      .lookup("controller:navigation/category")
      .get("category");

    if (!category) {
      return;
    }

    const isException = settings.exceptions
      .split("|")
      .filter(Boolean)
      .includes(category.name);

    if (/^\/c\//.test(path)) {
      const hideMobile = !settings.show_mobile && this.site.mobileView;
      const isSubCategory =
        !settings.show_subcategory && category.parentCategory;
      const hasNoCategoryDescription =
        settings.hide_if_no_description && !category.description_text;

      if (
        !isException &&
        !hasNoCategoryDescription &&
        !isSubCategory &&
        !hideMobile
      ) {
        document.body.classList.add("category-header");

        return h(
          `div.category-title-header.category-banner-${category.slug}`,
          {
            attributes: {
              style: `background-color: #${category.color}; color: #${category.text_color};`,
            },
          },
          h("div.category-title-contents", buildCategory(category))
        );
      }
    } else {
      document.body.classList.remove("category-header");
    }
  },
});
