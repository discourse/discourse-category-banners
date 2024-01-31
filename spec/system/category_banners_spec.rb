# frozen_string_literal: true

require_relative "page_objects/components/category_banner"

RSpec.describe "Category Banners", type: :system do
  let!(:theme) { upload_theme_component }
  fab!(:category) { Fabricate(:category, description: "<p>this is some description</p>") }
  fab!(:category_subcategory) do
    Fabricate(:category, parent_category: category, description: "some description", uploaded_logo: Fabricate(:upload))
  end
  let(:category_banner) { PageObjects::Components::CategoryBanner.new(category) }
  let(:subcategory_banner) { PageObjects::Components::CategoryBanner.new(category_subcategory) }

  it "displays category banner correctly" do
    visit(category.url)

    expect(category_banner).to be_visible
    expect(category_banner).to have_title(category.name)
    expect(category_banner).to have_description("this is some description")
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
end
