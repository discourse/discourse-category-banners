import Category from "discourse/models/category";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { htmlSafe } from "@ember/template";

export default class DiscourseCategoryBanners extends Component {
  @service router;
  @service site;
  @tracked category = null;

  constructor() {
    super(...arguments);
    this.router.on("routeDidChange", this, this.getCategory);
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.router.off("routeDidChange", this, this.getCategory);
  }

  get shouldShow() {
    const router = this.router;
    const route = router.currentRoute;
    if (
      route &&
      route.params &&
      route.params.hasOwnProperty("category_slug_path_with_id")
    ) {
      const categories = {};

      settings.categories.split("|").forEach((item) => {
        item = item.split(":");

        if (item[0]) {
          categories[item[0]] = item[1] || "all";
        }
      });

      const isException = settings.exceptions
        .split("|")
        .filter(Boolean)
        .map((value) => value.toLowerCase())
        .includes(this.category.name.toLowerCase());

      const isTarget =
        Object.keys(categories).length === 0 ||
        categories[this.category.name] === "all" ||
        categories[this.category.name] === "no_sub" ||
        (this.category.parentCategory &&
          (categories[this.category.parentCategory.name] === "all" ||
            categories[this.category.parentCategory.name] === "only_sub"));

      const hideMobile = !settings.show_mobile && this.site.mobileView;
      const isSubCategory =
        !settings.show_subcategory && this.category.parentCategory;
      const hasNoCategoryDescription =
        settings.hide_if_no_description && !this.category.description_text;

      if (
        isTarget &&
        !isException &&
        !hasNoCategoryDescription &&
        !isSubCategory &&
        !hideMobile
      ) {
        document.body.classList.add("category-header");
      } else {
        document.body.classList.remove("category-header");
      }
    }
  }

  get safeStyle() {
    return htmlSafe(
      `background-color: #${this.category.color}; color: #${this.category.text_color};`
    );
  }

  @action
  getCategory() {
    const params = this.router.currentRoute.params;
    if (!params.category_slug_path_with_id) {
      return (this.category = null);
    }

    const category = Category.findBySlugPathWithID(
      params.category_slug_path_with_id
    );

    this.category = category ? category : null;

    if (this.category) {
      this.shouldShow;
    }
  }
}
