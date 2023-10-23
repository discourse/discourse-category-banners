import { apiInitializer } from "discourse/lib/api";
import CategoryBanner from "../components/category-banner";

export default apiInitializer("1.15.0", (api) => {
  api.renderInOutlet(settings.plugin_outlet, CategoryBanner);
});
