module.exports = {
  plugins: ["ember-template-lint-plugin-discourse"],
  extends: "discourse:recommended",
  rules: {
    "no-capital-arguments": false, // also false in Discourse, we use "args" a lot
  },
};
