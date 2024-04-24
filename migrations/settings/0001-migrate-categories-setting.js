const VALID_TARGETS = ["all", "no_sub", "only_sub"];

export default function migrate(settings, helpers) {
  if (settings.has("categories")) {
    const categories = settings.get("categories");
    const newCategories = [];

    categories.split("|").forEach((item) => {
      const [categoryName, target] = item.split(":");
      const categoryId = helpers.getCategoryIdByName(categoryName);

      if (categoryId) {
        const category = {
          category_id: [categoryId],
        };

        if (VALID_TARGETS.includes(target)) {
          category.target = target;
        } else {
          category.target = "all";
        }

        newCategories.push(category);
      }
    });

    settings.set("categories", newCategories);
  }

  return settings;
}
