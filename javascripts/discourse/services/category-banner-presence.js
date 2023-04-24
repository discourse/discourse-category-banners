import Service from '@ember/service';
import { tracked } from "@glimmer/tracking";

export default class CategoryBannerPresence extends Service {
  @tracked isPresent = false;
}