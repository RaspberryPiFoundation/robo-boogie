# frozen_string_literal: true

# One row per saved dance. This replaces the legacy MySQL dances, users and
# dances_* join tables: a dance has one owner (a browser's random UUID), one
# robot and one soundtrack. Legacy ids are kept by the import so ordering matches.
Sequel.migration do
  change do
    create_table(:dances) do
      primary_key :id, type: :Bignum
      String :guid, text: true, null: false, unique: true
      String :owner_uuid, text: true, index: true
      Integer :robot_id
      Integer :sound_id
      String :robot_name, text: true
      # json rather than jsonb: keeps the legacy key order and string values verbatim.
      column :move, :json, null: false
      TrueClass :is_entered_into_comp, null: false, default: false
      column :created_at, :timestamptz, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, :timestamptz, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
