// Builds build/ from dev/. build/ is what the app serves: don't edit it by
// hand, change dev/ and run `npm run build` from dev/.
//
//   - JavaScript and templates: bundled with r.js into assets/js/roboboogie.min.js,
//     with the same settings as the original Grunt build
//   - Sass: compiled with Dart Sass into assets/css/main.css
//   - index.html: dev/index.html with its build comments applied, and each
//     asset's ?version taken from the asset's contents
//   - data, fonts, images and music: copied, along with the files Ace loads
//     at runtime from next to the page
//
// It builds into a temporary folder and then replaces build/ with it, so
// nothing stale is left behind.

import { createHash } from "node:crypto";
import { chmodSync, cpSync, mkdirSync, readdirSync, readFileSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import requirejs from "requirejs";
import * as sass from "sass";

const path = (relative) => fileURLToPath(new URL(relative, import.meta.url));
const DEV = path(".");
const BUILD = path("../build");
const TMP = path("../.build-tmp");

const COPIED = ["assets/data", "assets/font", "assets/img", "assets/music"];
const ACE_RUNTIME_FILES = ["mode-javascript.js", "theme-xcode.js", "worker-javascript.js"];

const RJS_CONFIG = {
  baseUrl: join(DEV, "assets/js"),
  name: "libs/almond",
  include: ["app"],
  insertRequire: ["app"],
  out: join(TMP, "assets/js/roboboogie.min.js"),
  optimize: "none", // the bundle has never been minified
  preserveLicenseComments: false,
  findNestedDependencies: true,
  logLevel: 2, // warnings and errors only
  paths: {
    ace: "libs/ace/src-min-noconflict/ace",
    backbone: "libs/backbone",
    fixtures: "libs/backbone-fixtures",
    jquery: "libs/jquery-1.8.3.min",
    keymaster: "libs/keymaster",
    Mustache: "libs/mustache",
    modernizr: "libs/modernizr-latest",
    Handlebars: "libs/handlebars",
    hbars: "libs/hbars",
    howler: "libs/howler",
    howl: "libs/howler",
    preload: "libs/preloadjs-NEXT.min",
    segment: "libs/segment",
    ball: "libs/ball",
    socialite: "libs/socialite",
    square: "libs/square",
    stache: "libs/stache",
    sketch: "libs/sketch",
    swiper: "libs/idangerous.swiper-2.2.min",
    transit: "libs/jquery.transit.min",
    text: "libs/text",
    underscore: "libs/underscore",
  },
  shim: {
    ace: { exports: "ace" },
    jQuery: { exports: "jQuery" },
    keymaster: { exports: "key" },
    modernizr: { exports: "Modernizr" },
    Handlebars: { exports: "Handlebars" },
    preload: { exports: "createjs.PreloadJS" },
    segment: { exports: "Segment" },
    swiper: { exports: "Swiper" },
    ball: { exports: "Ball" },
    socialite: { exports: "Socialite" },
    square: { exports: "Square" },
    sketch: { exports: "Sketch" },
    transit: { deps: ["jquery"] },
  },
};

function bundleJavaScript() {
  return new Promise((resolve, reject) => requirejs.optimize(RJS_CONFIG, resolve, reject));
}

function compileSass() {
  const { css } = sass.compile(join(DEV, "assets/sass/main.scss"), {
    style: "compressed",
    // The Sass dates from 2013 and uses features Dart Sass has deprecated.
    // They still work in Sass 1.x; moving off them is needed before Sass 3.
    silenceDeprecations: ["import", "global-builtin", "color-functions", "slash-div"],
  });
  write("assets/css/main.css", css + "\n");
}

function copyAssets() {
  const notHidden = (source) => !basename(source).startsWith(".");
  for (const dir of COPIED) {
    cpSync(join(DEV, dir), join(TMP, dir), { recursive: true, filter: notHidden });
  }
  for (const file of ACE_RUNTIME_FILES) {
    cpSync(join(DEV, "assets/js/libs/ace/src-min-noconflict", file), join(TMP, file));
  }
}

// Applies the build comments in dev/index.html, as grunt-processhtml did:
// <!-- build:remove --> blocks are dropped and <!-- build:template --> blocks
// are uncommented. Each ?@@timestamp becomes a version from the asset's
// contents, so browsers only fetch an asset again when it has changed.
function buildIndexHtml() {
  let html = readFileSync(join(DEV, "index.html"), "utf8");
  html = html.replace(/^[ \t]*<!-- build:remove -->\n[\s\S]*?<!-- \/build -->\n\n?/gm, "");
  html = html.replace(/^[ \t]*<!-- build:template\n([\s\S]*?)\n[ \t]*\/build -->\n/gm, "$1\n");
  html = html.replace(/"(assets\/[^"?]+)\?@@timestamp"/g, (_, asset) => `"${asset}?${version(asset)}"`);
  if (html.includes("build:") || html.includes("@@")) {
    throw new Error("dev/index.html has a build comment or @@ placeholder this script doesn't handle");
  }
  write("index.html", html);
}

// Many files in dev/ are marked executable, which served files shouldn't be.
function normalisePermissions() {
  for (const entry of readdirSync(TMP, { recursive: true, withFileTypes: true })) {
    chmodSync(join(entry.parentPath, entry.name), entry.isDirectory() ? 0o755 : 0o644);
  }
}

function version(asset) {
  return createHash("sha256").update(readFileSync(join(TMP, asset))).digest("hex").slice(0, 12);
}

function write(file, contents) {
  mkdirSync(dirname(join(TMP, file)), { recursive: true });
  writeFileSync(join(TMP, file), contents);
}

rmSync(TMP, { recursive: true, force: true });
try {
  await bundleJavaScript();
  compileSass();
  copyAssets();
  buildIndexHtml();
  normalisePermissions();
  rmSync(BUILD, { recursive: true, force: true });
  renameSync(TMP, BUILD);
} finally {
  rmSync(TMP, { recursive: true, force: true });
}

console.log("Built build/ from dev/");
