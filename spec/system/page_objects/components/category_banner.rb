# frozen_string_literal: true

module PageObjects
  module Components
    class CategoryBanner < PageObjects::Components::Base
      def initialize(category)
        @category = category
      end

      def visible?
        has_css?(category_banner_selector)
      end

      def not_visible?
        has_no_css?(category_banner_selector)
      end

      def has_title?(title)
        has_css?("#{category_banner_selector} .category-title", text: title)
      end

      def has_description?(description)
        has_css?(
          "#{category_banner_selector} .category-title-description .cooked",
          text: description,
        )
      end

      def has_no_description?
        has_no_css?("#{category_banner_selector} .category-title-description")
      end

      def has_logo?
        has_css?("#{category_banner_selector} .category-logo img[src]")
      end

      def has_no_logo?
        has_no_css?("#{category_banner_selector} .category-logo img[src]")
      end

      def has_icon?(name)
        has_css?("#{category_banner_selector} .badge-category.--style-icon .d-icon-#{name}")
      end

      def has_no_icon?
        has_no_css?("#{category_banner_selector} .badge-category.--style-icon .d-icon")
      end

      def has_emoji?(name)
        has_css?("#{category_banner_selector} .badge-category .emoji[alt='#{name}']")
      end

      def has_no_emoji?
        has_no_css?("#{category_banner_selector} .badge-category.--style-emoji .emoji")
      end

      def description_link_selector(href)
        "#{category_banner_selector} .category-title-description .cooked a[href='#{href}']"
      end

      def dispatch_description_link_click(href, modifiers: [])
        # Dispatches a synthetic click that bubbles to the component's listener
        # without triggering native navigation (synthetic events are not trusted).
        page.execute_script(<<~JS, description_link_selector(href), modifiers.map(&:to_s))
          const [selector, modifiers] = arguments;
          const link = document.querySelector(selector);
          if (!link) {
            throw new Error("Link not found: " + selector);
          }
          const event = new MouseEvent("click", {
            bubbles: true,
            cancelable: true,
            shiftKey: modifiers.includes("shift"),
            metaKey: modifiers.includes("meta"),
            ctrlKey: modifiers.includes("ctrl"),
            button: 0,
          });
          link.dispatchEvent(event);
        JS
      end

      private

      def category_banner_selector
        ".category-banner-#{@category.slug}"
      end
    end
  end
end
