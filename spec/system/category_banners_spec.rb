# frozen_string_literal: true

require_relative "page_objects/components/category_banner"

RSpec.describe "Category Banners", type: :system do
  let!(:theme) { upload_theme_component }
  fab!(:category) { Fabricate(:category, description: "<p>this is some description</p>") }
  fab!(:category_subcategory) do
    Fabricate(
      :category,
      parent_category: category,
      description: "some description",
      uploaded_logo: Fabricate(:upload),
    )
  end
  let(:category_banner) { PageObjects::Components::CategoryBanner.new(category) }
  let(:subcategory_banner) { PageObjects::Components::CategoryBanner.new(category_subcategory) }

  it "displays category banner correctly" do
    visit(category.url)

    expect(category_banner).to be_visible
    expect(category_banner).to have_title(category.name)
    expect(category_banner).to have_description("this is some description")
  end

  context "when `categories` setting has been set" do
    it "displays category banner for category and its subcategory when target is set to `all`" do
      theme.update_setting(:categories, [{ category_id: [category.id], target: "all" }])
      theme.save!

      visit(category.url)

      expect(category_banner).to be_visible

      visit(category_subcategory.url)

      expect(subcategory_banner).to be_visible
    end

    it "displays category banner only for root category when target is set to `no_sub`" do
      theme.update_setting(:categories, [{ category_id: [category.id], target: "no_sub" }])
      theme.save!

      visit(category.url)

      expect(category_banner).to be_visible

      visit(category_subcategory.url)

      expect(subcategory_banner).to be_not_visible
    end

    it "displays category banner only for sub categories when target is set to `only_sub`" do
      theme.update_setting(:categories, [{ category_id: [category.id], target: "only_sub" }])
      theme.save!

      visit(category.url)

      expect(category_banner).to be_not_visible

      visit(category_subcategory.url)

      expect(subcategory_banner).to be_visible
    end
  end

  it "does not display the category description when `show_description` setting is false" do
    theme.update_setting(:show_description, false)
    theme.save!

    visit(category.url)

    expect(category_banner).to be_visible
    expect(category_banner).to have_title(category.name)
    expect(category_banner).to have_no_description
  end

  it "should not display category banner on mobile when `show_mobile` settting is false",
     mobile: true do
    theme.update_setting(:show_mobile, false)
    theme.save!

    visit(category.url)

    expect(category_banner).to be_not_visible
  end

  it "should not display category banner on subcategories when `show_subcategory` setting is false" do
    theme.update_setting(:show_subcategory, false)
    theme.save!

    visit(category_subcategory.url)

    expect(subcategory_banner).to be_not_visible
  end

  it "should not display category banner for category when `hide_if_no_description` setting is true and category has no description" do
    category.update!(description: "")
    theme.update_setting(:hide_if_no_description, true)
    theme.save!

    visit(category.url)

    expect(category_banner).to be_not_visible
  end

  it "should not display category banners for categories that have been listed in `exceptions` setting" do
    theme.update_setting(:exceptions, "#{category.name}|#{category_subcategory.name}")
    theme.save!

    visit(category.url)

    expect(category_banner).to be_not_visible

    visit(category_subcategory.url)
  end

  it "displays a category logo when show_category_logo is true" do
    theme.update_setting(:show_category_logo, true)
    theme.save!

    visit(category_subcategory.url)

    expect(subcategory_banner).to have_logo
  end

  it "does not display a category logo when show_category_logo is false" do
    theme.update_setting(:show_category_logo, false)
    theme.save!

    visit(category_subcategory.url)

    expect(subcategory_banner).to have_no_logo
  end

  describe "with show_category_icon" do
    before do
      category.update!(style_type: "icon", icon: "envelope")
      category_subcategory.update!(style_type: "emoji", emoji: "rocket")
    end

    context "when true" do
      before do
        theme.update_setting(:show_category_icon, true)
        theme.save!
      end

      it "displays the icons and emojis" do
        visit(category.url)
        expect(category_banner).to have_icon(category.icon)

        visit(category_subcategory.url)
        expect(subcategory_banner).to have_emoji(category_subcategory.emoji)
      end
    end

    context "when false" do
      before do
        theme.update_setting(:show_category_icon, false)
        theme.save!
      end

      it "does not display the category icon" do
        visit(category.url)
        expect(category_banner).to have_no_icon

        visit(category_subcategory.url)
        expect(subcategory_banner).to have_no_emoji
      end
    end
  end
end
