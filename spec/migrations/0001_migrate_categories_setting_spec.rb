# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass
RSpec.describe "0001-migrate-categories-setting migration" do
  let!(:theme) { upload_theme_component }

  fab!(:category_1, :category)
  fab!(:category_2, :category)
  fab!(:category_3, :category)
  fab!(:category_4, :category)

  it "sets target to `all` if previous target property is not one of `all`, `no_sub` or  `only_sub`" do
    theme.theme_settings.create!(
      name: "categories",
      theme:,
      data_type: ThemeSetting.types[:string],
      value: "#{category_1.name}:something|#{category_2.name}:something_else",
    )

    run_theme_migration(theme, "0001-migrate-categories-setting")

    expect(theme.settings[:categories].value).to eq(
      [
        { "category_id" => [category_1.id], "target" => "all" },
        { "category_id" => [category_2.id], "target" => "all" },
      ],
    )
  end

  it "should not migrate settings where a relevant category is not found for the given category names in the database" do
    theme.theme_settings.create!(
      name: "categories",
      theme:,
      data_type: ThemeSetting.types[:string],
      value: "non_existent_category:something",
    )

    run_theme_migration(theme, "0001-migrate-categories-setting")

    expect(theme.settings[:categories].value).to eq([])
  end

  it "should migrate settings where a relevant category is found for the given category names in the database" do
    theme.theme_settings.create!(
      name: "categories",
      theme:,
      data_type: ThemeSetting.types[:string],
      value:
        "#{category_1.name}:no_sub|#{category_2.name}:only_sub|invalid:something_else|#{category_3.name}:all|#{category_4.name}",
    )

    run_theme_migration(theme, "0001-migrate-categories-setting")

    expect(theme.settings[:categories].value).to eq(
      [
        { "category_id" => [category_1.id], "target" => "no_sub" },
        { "category_id" => [category_2.id], "target" => "only_sub" },
        { "category_id" => [category_3.id], "target" => "all" },
        { "category_id" => [category_4.id], "target" => "all" },
      ],
    )
  end
end
