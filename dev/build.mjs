// Builds the frontend's JavaScript: bundles dev/assets/js (scripts and
// templates) into build/assets/js/roboboogie.min.js with r.js, using the same
// settings as the original Grunt build, then points build/index.html at the
// new bundle. Run it with `npm run build` from dev/.

import { createHash } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import requirejs from "requirejs";

const path = (relative) => fileURLToPath(new URL(relative, import.meta.url));
const BUNDLE = path("../build/assets/js/roboboogie.min.js");
const INDEX = path("../build/index.html");

const config = {
  baseUrl: path("assets/js/"),
  name: "libs/almond",
  include: ["app"],
  insertRequire: ["app"],
  out: BUNDLE,
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

await new Promise((resolve, reject) => requirejs.optimize(config, resolve, reject));

// Static files are cached for a day, so index.html asks for the bundle with a
// version taken from its contents. The version only changes when the bundle does.
const version = createHash("sha256").update(readFileSync(BUNDLE)).digest("hex").slice(0, 12);
const SCRIPT_SRC = /(src="assets\/js\/roboboogie\.min\.js\?)[^"]*(")/;
const index = readFileSync(INDEX, "utf8");
if (!SCRIPT_SRC.test(index)) {
  throw new Error("Couldn't find the roboboogie.min.js script tag in build/index.html");
}
writeFileSync(INDEX, index.replace(SCRIPT_SRC, `$1${version}$2`));

console.log(`Built build/assets/js/roboboogie.min.js (version ${version})`);
