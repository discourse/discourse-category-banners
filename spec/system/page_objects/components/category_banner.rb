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

      private

      def category_banner_selector
        ".category-banner-#{@category.slug}"
      end
    end
  end
end
