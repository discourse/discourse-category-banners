import Category from "discourse/models/category";
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { getOwner } from "@ember/application";

export default class DiscourseCategoryBanners extends Component {
  @service router;
  @service site;
  @service categoryBannerPresence;
  @tracked category = null;
  @tracked keepDuringLoadingRoute = false;

  get hasIconComponent() {
    return getOwner(this).hasRegistration("component:category-icon");
  }

  get categorySlugPathWithID() {
    return this.router?.currentRoute?.params?.category_slug_path_with_id;
  }

  get shouldRender() {
    return (
      this.categorySlugPathWithID ||
      (this.keepDuringLoadingRoute &&
        this.router.currentRoute.name.includes("loading"))
    );
  }

  get isVisible() {
    if (this.categorySlugPathWithID) {
      return true;
    } else if (this.router.currentRoute.name.includes("loading")) {
      return this.keepDuringLoadingRoute;
    }
    return false;
  }

  get safeStyle() {
    return htmlSafe(
      `background-color: #${this.category.color}; color: #${this.category.text_color};`
    );
  }

  get consoleWarn() {
    // eslint-disable-next-line no-console
    return console.warn(
      "The category banners component is trying to use the category icons component, but it is not available. https://meta.discourse.org/t/category-icons/104683"
    );
  }

  get displayCategoryDescription() {
    return settings.show_description && this.category.description?.length > 0;
  }

  #parseCategories(categoriesStr) {
    const categories = {};
    categoriesStr.split("|").forEach((item) => {
      item = item.split(":");

      if (item[0]) {
        categories[item[0].toLowerCase()] = item[1]
          ? item[1].toLowerCase()
          : "all";
      }
    });
    return categories;
  }

  #parseExceptions(exceptionsStr) {
    return exceptionsStr
      .split("|")
      .filter(Boolean)
      .map((value) => value.toLowerCase());
  }

  #checkTargetCategory(categories) {
    const currentCategoryName = this.category?.name.toLowerCase();
    const parentCategoryName = this.category?.parentCategory
      ? this.category.parentCategory.name.toLowerCase()
      : null;

    return (
      Object.keys(categories).length === 0 ||
      categories[currentCategoryName] === "all" ||
      categories[currentCategoryName] === "no_sub" ||
      (this.category?.parentCategory &&
        (categories[parentCategoryName] === "all" ||
          categories[parentCategoryName] === "only_sub"))
    );
  }

  @action
  teardownComponent() {
    document.body.classList.remove("category-header");
    this.category = null;
    this.categoryBannerPresence.setTo(false);
  }

  @action
  getCategory() {
    if (!this.isVisible) {
      return;
    }

    if (this.categorySlugPathWithID) {
      this.category = Category.findBySlugPathWithID(
        this.categorySlugPathWithID
      );
      this.categoryBannerPresence.setTo(true);
      this.keepDuringLoadingRoute = true;
    } else {
      if (!this.router.currentRoute.name.includes("loading")) {
        return (this.keepDuringLoadingRoute = false);
      }
    }

    const categories = this.#parseCategories(settings.categories);
    const exceptions = this.#parseExceptions(settings.exceptions);
    const isException = exceptions.includes(this.category?.name.toLowerCase());
    const isTarget = this.#checkTargetCategory(categories);
    const hideMobile = this.site.mobileView && !settings.show_mobile;
    const hideSubCategory =
      this.category?.parentCategory && !settings.show_subcategory;
    const hasNoCategoryDescription =
      settings.hide_if_no_description && !this.category?.description_text;

    if (
      isTarget &&
      !isException &&
      !hasNoCategoryDescription &&
      !hideSubCategory &&
      !hideMobile
    ) {
      document.body.classList.add("category-header");
    } else {
      document.body.classList.remove("category-header");
      this.categoryBannerPresence.setTo(false);
    }
  }
}
