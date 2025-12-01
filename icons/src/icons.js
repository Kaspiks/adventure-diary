// Import Feather icons matching FEATHER_ICON_REGEXP (defined in webpack.config.js)
const requireAll = (requireContext) => requireContext.keys().map(requireContext);

const featherContext = require.context(
  "feather-icons/dist/icons",
  false,
  FEATHER_ICON_REGEXP
);

requireAll(featherContext);
console.log(`Loaded ${featherContext.keys().length} Feather icons`);
