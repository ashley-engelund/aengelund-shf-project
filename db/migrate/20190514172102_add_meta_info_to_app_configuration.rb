class AddMetaInfoToAppConfiguration < ActiveRecord::Migration[5.2]

  # add meta information about the site
  # including the default site image (an attachment) and the information (type, width, height) needed about it
  def change

    add_column :app_configurations, :site_name, :string, null: false, default: ''
    add_column :app_configurations, :site_meta_title, :string, null: false, default: ''
    add_column :app_configurations, :site_meta_description, :string, null: false, default: ''
    add_column :app_configurations, :site_meta_keywords, :string, null: false, default: ''

    add_column :app_configurations, :site_meta_image_width, :integer, null: false, default: 0
    add_column :app_configurations, :site_meta_image_height, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        add_attachment :app_configurations, :site_meta_image

        # initialize the data
        # This will insert a new row if one doesn't exist, otherwise it will update the LAST row (based on the id)
        # Requires Postgres 9.5 or later (for the ON CONFLICT clause)
        execute <<-SQL
          INSERT INTO app_configurations (id, site_name, site_meta_title, site_meta_description, site_meta_keywords, created_at, updated_at)
          VALUES (( CASE WHEN (Select count(*) from app_configurations) = 0 THEN 1
          ELSE (SELECT id from app_configurations ORDER BY id DESC LIMIT 1) END),
                'Sveriges Hundföretagare',
                'Hitta H-märkt hundföretag, hundinstruktör',
                'Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera.',
                'hund, hundägare, hundinstruktör, hundentreprenör, Sveriges Hundföretagare, svenskt hundföretag, etisk, H-märkt, hundkurs',
                now(), now())
          ON CONFLICT (id) DO UPDATE
          SET site_name = excluded.site_name,
              site_meta_title = excluded.site_meta_title,
              site_meta_description = excluded.site_meta_description,
              site_meta_keywords = excluded.site_meta_keywords;
        SQL

      end

      dir.down do
        remove_attachment :app_configurations, :site_meta_image
      end

    end


  end

end
