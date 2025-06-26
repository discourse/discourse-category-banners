import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat } from "@ember/helper";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import CategoryLogo from "discourse/components/category-logo";
import PluginOutlet from "discourse/components/plugin-outlet";
import { categoryLinkHTML } from "discourse/helpers/category-link";
import icon from "discourse/helpers/d-icon";
import lazyHash from "discourse/helpers/lazy-hash";
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
      `--category-banner-background: #${this.category.color}; --category-banner-color: #${this.category.text_color};`
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

  <template>
    {{#if this.shouldRender}}
      <div
        {{didInsert this.getCategory}}
        {{didUpdate this.getCategory this.isVisible}}
        {{willDestroy this.teardownComponent}}
        class="category-title-header
          {{if this.category (concat 'category-banner-' this.category.slug)}}"
        style={{if this.category this.safeStyle}}
      >
        {{#if this.category}}
          <div class="category-title-contents">
            {{#if settings.show_category_logo}}
              <CategoryLogo @category={{this.category}} />
            {{/if}}
            <h1 class="category-title">
              {{#if this.showCategoryIcon}}
                {{this.categoryNameBadge}}
              {{else}}
                {{#if this.category.read_restricted}}
                  {{icon "lock"}}
                {{/if}}
                {{this.category.name}}
              {{/if}}

              <PluginOutlet
                @name="category-banners-after-title"
                @outletArgs={{lazyHash category=this.category}}
              />
            </h1>

            {{#if this.displayCategoryDescription}}
              <div class="category-title-description">
                <div class="cooked">
                  {{htmlSafe this.category.description}}
                  <PluginOutlet
                    @name="category-banners-after-description"
                    @outletArgs={{lazyHash category=this.category}}
                  />
                </div>
              </div>
            {{/if}}
          </div>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
