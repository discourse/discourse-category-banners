import { getOwner } from "discourse-common/lib/get-owner";
import { h } from "virtual-dom";
import { iconNode } from "discourse-common/lib/icon-library";
import { createWidget } from "discourse/widgets/widget";
import Category from "discourse/models/category";

export default createWidget("category-header-widget", {
  tagName: "span.discourse-category-banners",

  html() {
    const router = getOwner(this).lookup("router:main");
    const route = router.currentRoute;
    if (
      route &&
      route.params &&
      route.params.hasOwnProperty("category_slug_path_with_id")
    ) {
      const categories = settings.categories
        .split("|")
        .reduce((categories, item) => {
          item = item.split(":");
          if (item[0]) {
            categories[item[0]] = item[1] || "all";
          }
          return categories;
        }, {});

      const category = Category.findBySlugPathWithID(
        route.params.category_slug_path_with_id
      );

      const isException = settings.exceptions
        .split("|")
        .filter(Boolean)
        .includes(category.name);
      const isTarget =
        Object.keys(categories).length === 0 ||
        categories[category.name] === "all" ||
        categories[category.name] === "no_sub" ||
        (category.parentCategory &&
          (categories[category.parentCategory.name] === "all" ||
            categories[category.parentCategory.name] === "only_sub"));
      const hideMobile = !settings.show_mobile && this.site.mobileView;
      const isSubCategory =
        !settings.show_subcategory && category.parentCategory;

      if (isTarget && !isException && !isSubCategory && !hideMobile) {
        return h(
          `div.category-title-header.category-banner-${category.slug}`,
          {
            attributes: {
              style: `--category-background-color: #${category.color}; --category-text-color: #${category.text_color};`
            }
          },
          this.buildCategory(category)
        );
      }
    }
  },

  bannerLogo(category) {
    if (settings.show_category_logo && category.uploaded_logo) {
      const logo = h("img.banner-category-logo", {
        src: category.uploaded_logo.url,
        height: 150
      });

      return h("div.category-banner-logo-wrapper", logo);
    }
  },

  bannerText(category) {
    const textContent = [];

    if (category.read_restricted) {
      textContent.push(iconNode("lock"));
    }

    if (settings.show_category_icon) {
      try {
        textContent.push(this.attach("category-icon", { category }));
      } catch {
        // Discourse category icons component is not installed
      }
    }

    textContent.push(h("h1.category-title", category.name));

    if (settings.show_description) {
      textContent.push(
        h(
          "div.category-title-description",
          h("div.cooked", { innerHTML: category.description })
        )
      );
    }

    return h("div.category-text-logo-wrapper", textContent);
  },

  buildCategory(category) {
    return h(
      "div.wrap",
      h("div.category-title-contents", [
        this.bannerLogo(category),
        this.bannerText(category)
      ])
    );
  }
});
