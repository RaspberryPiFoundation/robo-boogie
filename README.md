![Robo-Boogie](https://roboboogie.codeclub.org.uk/assets/img/logo%401x.png)

Robo-boogie is a web-based robot dancing game made for [Code Club](https://www.codeclub.org.uk) by [Hover Studio](http://hoverstud.io).

You can check the app out online at [roboboogie.codeclub.org.uk](https://roboboogie.codeclub.org.uk)

We learned a lot building the app so we've put the code up here in the hopes it might interesting/helpful to somebody!

## How it fits together

- `build/` is the frontend, a Backbone app. It's already built and committed, and is served as-is.
- `dev/` is the frontend's source: JavaScript, templates and Sass. It isn't served.
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

Shared links such as `/#watch/<guid>`, `/#iframe/<guid>` and `/#dance/<guid>` are frontend routes; the frontend then loads the dance from the API. The API keeps the paths and response shapes of the app's original PHP API, so the frontend and existing links work unchanged.

| Request | Used for | Response |
|---|---|---|
| `GET /api/index.php/users/user/<uuid>?uuid=<uuid>` | Every page load | `{"uuid": …, "dances": [{"guid", "robot_id", "robot_name"}]}` |
| `PUT /api/index.php/users/user/<uuid>` | A browser's first visit | Same as above |
| `GET /api/index.php/dances/dance/<guid>` | Watching or editing a dance | `[{…dance}]`, or `{"danceFound": false}` |
| `POST` or `PUT /api/index.php/dances/dance/[<guid>]` | Saving a dance | The dance's guid, as a JSON string |

There are no accounts. Each browser makes up a random UUID and keeps it in `localStorage`, and a dance belongs to the UUID that saved it. Only that UUID, sent in the request body, can update the dance.

The users endpoint also sets an `rb_owner` cookie. A dance's `uuid` field is only filled in when that cookie matches the owner. The frontend compares it with its own UUID to decide whether to offer "Edit dance", so the owner's UUID never reaches anyone else.

## Changing the frontend

`dev/` is the frontend's source and `build/` is what gets served. Both are committed.

The JavaScript and its templates, in `dev/assets/js/`, are bundled into `build/assets/js/roboboogie.min.js` with [r.js](https://requirejs.org/docs/optimization.html). You'll need the Node version named in `.tool-versions`. After changing anything in `dev/assets/js/`:

    cd dev
    npm ci
    npm run build

This rebuilds the bundle and updates its `?…` version in `build/index.html`, so browsers fetch the new bundle instead of a copy cached for up to a day. Commit the changes in `dev/` and `build/` together.

The build doesn't cover anything else yet, so other changes need making in both places:

- `index.html`: change both `dev/index.html` and `build/index.html`. They differ only in how they load the scripts and in the `?…` versions.
- Styles: the Sass in `dev/assets/sass/` isn't compiled by the build. Today's Dart Sass writes some colours and rules differently from the Ruby Sass that produced `build/assets/css/main.css` in 2015, so switching to it would need the whole site checked by eye. For now, make a small style fix in both `dev/assets/sass/` and `build/assets/css/main.css`, and bump the `?…` version on `main.css` in `build/index.html`.
- Images, fonts and data: copy them into `build/assets/`.

### Robots and sounds

- Robots are defined in `build/assets/data/robots.json`. The API accepts any robot `id` listed there.
- Sound loops live in `build/assets/music/loops/` and are listed in `build/assets/data/soundtracks.json`. The API maps each `sound_id` to a loop in `LegacyFormat::SOUNDTRACK_FILES`, so a new sound needs adding there too.

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
