const fs = require('fs');
const path = require('path');

// List of Feather icons to include in the sprite
const includedIcons = [
  "activity", "alert-circle", "alert-octagon", "alert-triangle", "archive",
  "arrow-down", "arrow-left", "arrow-right", "arrow-up",
  "bar-chart-2", "book", "book-open", "calendar", "camera",
  "check", "check-circle", "chevron-down", "chevron-left", "chevron-right", "chevron-up",
  "chevrons-left", "chevrons-right", "clipboard", "clock", "columns", "copy",
  "corner-right-down", "corner-up-right", "download",
  "edit", "edit-2", "edit-3", "external-link", "eye", "eye-off",
  "file", "file-text", "filter", "folder", "git-pull-request", "globe", "grid", "hash",
  "heart", "help-circle", "home", "image", "info", "layers", "link", "list", "loader",
  "lock", "log-in", "log-out", "mail", "map", "map-pin", "maximize", "menu",
  "message-circle", "minimize", "minus", "more-horizontal", "more-vertical",
  "navigation", "pen-tool", "pie-chart", "play", "plus", "plus-circle",
  "refresh-cw", "save", "search", "settings", "share", "share-2", "sliders",
  "star", "sun", "moon", "tag", "tool", "trash", "trash-2", "trending-up",
  "unlock", "upload", "user", "user-check", "user-plus", "users",
  "x", "x-circle", "x-octagon", "zap"
];

const featherIconsPath = path.join(__dirname, 'node_modules', 'feather-icons', 'dist', 'icons');
const outputPath = path.join(__dirname, '..', 'vendor', 'assets', 'images', 'icons.svg');

const outputDir = path.dirname(outputPath);
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

let spriteContent = '<svg xmlns="http://www.w3.org/2000/svg" style="display: none;" class="iconset">\n';

let iconsAdded = 0;

includedIcons.forEach(iconName => {
  const iconPath = path.join(featherIconsPath, `${iconName}.svg`);
  
  if (fs.existsSync(iconPath)) {
    let iconContent = fs.readFileSync(iconPath, 'utf8');
    
    iconContent = iconContent.replace(/<svg[^>]*>/, '').replace(/<\/svg>/, '');
    
    iconContent = iconContent.replace(/\s+fill="[^"]*"/g, '');
    iconContent = iconContent.replace(/\s+stroke="[^"]*"/g, '');
    iconContent = iconContent.replace(/\s+stroke-width="[^"]*"/g, '');
    iconContent = iconContent.replace(/\s+stroke-linecap="[^"]*"/g, '');
    iconContent = iconContent.replace(/\s+stroke-linejoin="[^"]*"/g, '');
    
    spriteContent += `  <symbol id="${iconName}" viewBox="0 0 24 24">${iconContent}</symbol>\n`;
    iconsAdded++;
  } else {
    console.warn(`Warning: Icon ${iconName}.svg not found`);
  }
});

spriteContent += '</svg>';

fs.writeFileSync(outputPath, spriteContent, 'utf8');
console.log(`✓ Built icon sprite with ${iconsAdded} icons at ${outputPath}`);
