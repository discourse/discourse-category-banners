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

      private

      def category_banner_selector
        ".category-banner-#{@category.slug}"
      end
    end
  end
end
