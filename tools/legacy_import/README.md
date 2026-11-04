# Legacy data import

These tools move saved dances from the old PHP app's MySQL database into the new app's Postgres. The new app can then serve every existing `#watch/`, `#iframe/` and `#dance/` link.

- `import.rb` restores a `mysqldump` into a temporary MySQL (in Docker), then copies the dances into any Postgres you point it at.
- `verify.rb` compares dances served by the old PHP API with the new app.

Run both from the repository root. They need Docker running and the app's gems installed (`bundle install`).

## 1. Take a dump on the old server

`roboboogie.codeclub.org.uk` is proxied by Cloudflare, which doesn't pass SSH through. Connect to the server's own IP, which Cloudflare's DNS settings show for the `roboboogie` record.

On the server:

    mysqldump --single-transaction --hex-blob --default-character-set=utf8 \
      -u <user> -p production | gzip > ~/roboboogie-$(date +%F-%H%M).sql.gz

The database user and password are in the app's `build/api/application/config/database.php` on the server. Then copy the dump to your machine:

    scp deploy@<server-ip>:roboboogie-*.sql.gz .

The dump holds every owner's UUID, which works as a password for editing their dances. Keep it private and out of git (`*.sql.gz` is ignored). Keep one dump permanently as the archive of the old database.

## 2. Dry run into a local database

    createdb roboboogie_import
    bundle exec ruby tools/legacy_import/import.rb roboboogie-<date>.sql.gz \
      --database-url postgres:///roboboogie_import

It prints how many dances it read and kept, any unusual rows and what it did with them, and the size of the data. Use the size to choose the Heroku Postgres plan. It also writes `legacy-import-report.json`, which `verify.rb` uses.

Unusual rows are handled the way the PHP API behaved, so a link that worked before still shows the same dance:

| Row | What happens |
|---|---|
| No guid | Skipped (no link could ever reach it) |
| Guid shared with a lower id | Skipped (the PHP API always showed the lower id) |
| Move that isn't a JSON object | Imported with an empty move (the PHP API returned one) |
| Several robot, soundtrack or owner links | The first link is used |
| No owner, robot or soundtrack | Imported without it, as before |

## 3. Import into Heroku

Deploy the app first, so Heroku's release phase has created the table. Then:

    bundle exec ruby tools/legacy_import/import.rb roboboogie-<date>.sql.gz \
      --database-url "$(heroku config:get DATABASE_URL -a <app>)"

Import before anyone saves a test dance on the new app. A test dance could take an id the import needs, and the import stops and says so.

## 4. Verify

While `roboboogie.codeclub.org.uk` still points at the old server:

    bundle exec ruby tools/legacy_import/verify.rb \
      --legacy https://roboboogie.codeclub.org.uk --new https://<app>.herokuapp.com \
      --database-url "$(heroku config:get DATABASE_URL -a <app>)"

This compares 200 random dances plus every unusual one, and 50 owners' lists of dances. It exits non-zero if anything differs. Owner UUIDs and `robot_still` aren't compared: the new app only shows an owner their own UUID, and doesn't keep the old robot images.

## 5. Cutover

1. Take a fresh dump and import it. Only dances that changed since the last import are updated.
2. Point the `roboboogie` DNS record at Heroku.
3. Straight away, take another dump and import it. This catches anything saved on the old server just before the switch.
4. Import once more the next day, then stop the old server.

Each import is safe to repeat. A dance only changes if the dump's copy is newer, so edits made on the new app are kept.

## What isn't imported

These stay in the archived dump:

- visitors who never saved a dance (the new app needs no record of them)
- `votes`, from the old competition
- `robot_still` images, which the app no longer shows

## Test fixture

`test/fixtures/legacy_dump.sql` is a genuine MySQL 5.5 dump, made with the command above from `test/fixtures/legacy_seed.sql`. It has one row for each unusual case. To regenerate it:

    docker run -d --rm --platform linux/amd64 --name fixture-mysql55 \
      -e MYSQL_ROOT_PASSWORD=fixture -e MYSQL_DATABASE=production mysql:5.5
    # wait until this succeeds:
    docker exec -e MYSQL_PWD=fixture fixture-mysql55 mysql -h127.0.0.1 -uroot -e 'SELECT 1'
    docker exec -i -e MYSQL_PWD=fixture fixture-mysql55 \
      mysql -h127.0.0.1 -uroot --default-character-set=utf8 production < test/fixtures/legacy_seed.sql
    docker exec -e MYSQL_PWD=fixture fixture-mysql55 mysqldump --single-transaction --hex-blob \
      --default-character-set=utf8 -h127.0.0.1 -uroot production > test/fixtures/legacy_dump.sql
    docker rm -f fixture-mysql55

`DOCKER_TESTS=1 TEST_DATABASE_URL=… bundle exec rake test` runs the import on it end to end.
