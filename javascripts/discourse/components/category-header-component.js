import MountWidget from "discourse/components/mount-widget";
import { observes } from "discourse-common/utils/decorators";

export default MountWidget.extend({
  widget: "category-header-widget",

  buildArgs() {
    return {
      shouldRender: this.currentPath === "discovery.category",
    };
  },

  @observes("currentPath")
  currentPathChanged() {
    this.rerenderWidget();
  },
});
