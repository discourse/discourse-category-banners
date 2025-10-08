import { apiInitializer } from "discourse/lib/api";
import CategoryBanner from "../components/category-banner";

export default apiInitializer((api) => {
  api.renderInOutlet(settings.plugin_outlet, CategoryBanner);
});
