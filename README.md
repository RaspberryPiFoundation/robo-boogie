![Robo-Boogie](https://roboboogie.codeclub.org.uk/assets/img/logo%401x.png)

Robo-boogie is a web-based robot dancing game made for [Code Club](https://www.codeclub.org.uk) by Hover Studio.

You can check the app out online at [roboboogie.codeclub.org.uk](https://roboboogie.codeclub.org.uk)

We learned a lot building the app so we've put the code up here in the hopes it might interesting/helpful to somebody!

## How it fits together

- `dev/` is the frontend's source, a Backbone app: JavaScript, templates, Sass, images, sounds and data. It isn't served.
- `build/` is the built frontend, made from `dev/` by `npm run build`. It's committed and served as-is.
- `app.rb` is a small [Sinatra](https://sinatrarb.com) app. It serves `build/`, plus the JSON API that saves dances in Postgres.
- `lib/robo_boogie/legacy_format.rb` defines the JSON shapes the frontend expects.
- `db/migrate/` holds the database schema as [Sequel](https://sequel.jeremyevans.net) migrations.
- `test/` holds the tests.

## Running locally

You'll need a local Postgres and the Ruby version named in `.ruby-version`. `.tool-versions` declares the same version for [asdf](https://asdf-vm.com), so change both when upgrading Ruby.

    bundle install
    createdb roboboogie_dev
    DATABASE_URL=postgres:///roboboogie_dev bundle exec rake db:migrate
    DATABASE_URL=postgres:///roboboogie_dev bundle exec puma -C config/puma.rb

The app is then at http://localhost:9292.

The tests need their own database, because they empty it on every run:

    createdb roboboogie_test
    TEST_DATABASE_URL=postgres:///roboboogie_test bundle exec rake test

## The API

Shared links such as `/#watch/<guid>`, `/#iframe/<guid>` and `/#dance/<guid>` are frontend routes; the frontend then loads the dance from the API. The API keeps the response shapes of the app's original PHP API, so the frontend and existing links work unchanged.

| Request | Used for | Response |
|---|---|---|
| `GET /api/users/<uuid>?uuid=<uuid>` | Every page load | `{"uuid": …, "dances": [{"guid", "robot_id", "robot_name"}]}` |
| `PUT /api/users/<uuid>` | A browser's first visit | Same as above |
| `GET /api/dances/<guid>` | Watching or editing a dance | `[{…dance}]`, or `{"danceFound": false}` |
| `POST /api/dances` | Saving a new dance | The new dance's guid, as a JSON string |
| `PUT /api/dances/<guid>` | Saving changes to a dance | The dance's guid, as a JSON string |

There are no accounts. Each browser makes up a random UUID and keeps it in `localStorage`, and a dance belongs to the UUID that saved it. Only that UUID, sent in the request body, can update the dance.

The users endpoint also sets an `rb_owner` cookie. A dance's `uuid` field is only filled in when that cookie matches the owner. The frontend compares it with its own UUID to decide whether to offer "Edit dance", so the owner's UUID never reaches anyone else.

## Changing the frontend

Make every change in `dev/`, then rebuild `build/` from it. Don't edit `build/` by hand: each build replaces the whole folder. You'll need the Node version named in `.tool-versions`.

    cd dev
    npm ci
    npm run build

Then commit the changes in `dev/` and `build/` together. The build (`dev/build.mjs`):

- bundles the JavaScript and templates in `dev/assets/js/` into `roboboogie.min.js` with [r.js](https://requirejs.org/docs/optimization.html)
- compiles the Sass in `dev/assets/sass/` into `main.css` with [Dart Sass](https://sass-lang.com/dart-sass/)
- makes `index.html` from `dev/index.html`, giving each CSS and JavaScript file a `?…` version taken from its contents, so browsers only fetch a file again when it changes (static files are cached for a day)
- copies the images, fonts, sounds and data

Images are copied as they are, so optimise a new image (for example with [ImageOptim](https://imageoptim.com)) before adding it to `dev/assets/img/`.

The Sass dates from 2013 and uses features that Dart Sass has deprecated, such as `@import`, `darken()` and `/` for division. The build hides those warnings. Sass 1.x still supports them, but `/` for division goes in Sass 2 and `@import` in Sass 3, so they'll need replacing before either upgrade. Until then, Dependabot doesn't propose new major versions of Sass.

### Robots and sounds

- Robots are defined in `dev/assets/data/robots.json`. The API accepts any robot `id` listed in the built copy of that file.
- Sound loops live in `dev/assets/music/loops/` and are listed in `dev/assets/data/soundtracks.json`. The API maps each `sound_id` to a loop in `LegacyFormat::SOUNDTRACK_FILES`, so a new sound needs adding there too.

## Deploying

The app is set up for Heroku with Heroku Postgres. On each deploy, the `Procfile` runs database migrations in Heroku's release phase and then starts Puma.

GitHub Actions runs the tests on every pull request and every push to `main` (`.github/workflows/ci.yml`). In the Heroku app's GitHub integration, turn on automatic deploys from `main` with "Wait for CI to pass before deploy", so only tested commits go live.

## Keeping it up to date

Dependabot opens weekly pull requests to update gems, GitHub Actions and the frontend's build tool. It waits a week after each release, except for security fixes.

## Thanks

- Clare Sutcliffe, for asking us to do this!
- Timothy Winchester, for his illustrated Robots
- Tef Thomas, for help getting the thing up and running
- Calum Gunn, for helping us integrate the iFrame dances
- Guy Kogus, for advice on hard maths
- Tom Judd, for animation advice and tips

Also you should check out the accompanying promo animation by our sister company [Animade](http://animade.tv) over on [Code Club's Youtube Channel](http://www.youtube.com/watch?v=sGtaIJTPbWU).
