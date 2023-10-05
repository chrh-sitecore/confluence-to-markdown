process.env.NODE_ENV = "test";

module.exports = {
  require: "coffeescript/register",
  extension: ["coffee"],
  watchExtensions: ["coffee"],
  spec: ["test/**/*.coffee"],
};
