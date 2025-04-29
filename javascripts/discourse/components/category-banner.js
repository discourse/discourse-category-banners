import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { categoryLinkHTML } from "discourse/helpers/category-link";
import Category from "discourse/models/category";

export default class DiscourseCategoryBanners extends Component {
  @service router;
  @service site;
  @service categoryBannerPresence;

  @tracked category = null;
  @tracked keepDuringLoadingRoute = false;

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

  get displayCategoryDescription() {
    return settings.show_description && this.category.description?.length > 0;
  }

  get showCategoryIcon() {
    const hasIcon = this.category.style_type === "icon" && this.category.icon;
    const hasEmoji =
      this.category.style_type === "emoji" && this.category.emoji;

    if (settings.show_category_icon && (hasIcon || hasEmoji)) {
      return true;
    } else {
      return false;
    }
  }

  get categoryNameBadge() {
    return categoryLinkHTML(this.category, {
      allowUncategorized: true,
      link: false,
    });
  }

  #parseExceptions(exceptionsStr) {
    return exceptionsStr
      .split("|")
      .filter(Boolean)
      .map((value) => value.toLowerCase());
  }

  #checkTargetCategory() {
    if (settings.categories.length === 0) {
      return true;
    }

    const currentCategoryId = this.category?.id;

    const activeCategory = settings.categories.find((category) => {
      return category.category_id[0] === currentCategoryId;
    });

    if (
      activeCategory &&
      (activeCategory.target === "all" || activeCategory.target === "no_sub")
    ) {
      return true;
    }

    const parentCategoryId = this.category?.parentCategory?.id;

    if (parentCategoryId) {
      const activeParentCategory = settings.categories.find((category) => {
        return category.category_id[0] === parentCategoryId;
      });

      if (
        activeParentCategory &&
        (activeParentCategory.target === "all" ||
          activeParentCategory.target === "only_sub")
      ) {
        return true;
      }
    }

    return false;
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

    const exceptions = this.#parseExceptions(settings.exceptions);
    const isException = exceptions.includes(this.category?.name.toLowerCase());
    const isTarget = this.#checkTargetCategory();
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
