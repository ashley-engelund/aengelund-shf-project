#--------------------------
#
# @class AppConfigurationSeeder
#
# @desc Responsibility: put initial data into the db for an AppConfiguration
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-05-16
#
# @file app_configuration_seeder
#
#--------------------------


class AppConfigurationSeeder

  SITE_DEFAULT_IMAGE = 'Sveriges_hundforetagare_banner_sajt.jpg'

  def self.seed

    puts "\nSeeding AppConfiguration..."

    new_config = AdminOnly::AppConfiguration.new(site_name: 'Sveriges Hundföretagare',
                                                    site_meta_title: 'Hitta H-märkt hundföretag, hundinstruktör',
                                                    site_meta_description: 'Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera.',
                                                    site_meta_keywords: 'hund, hundägare, hundinstruktör, hundentreprenör, Sveriges Hundföretagare, svenskt hundföretag, etisk, H-märkt, hundkurs',
                                                    )

    meta_image_file = File.open(File.join(__dir__, SITE_DEFAULT_IMAGE) )
    new_config.site_meta_image = meta_image_file
    meta_image_file.close

    new_config.save

  end

end
