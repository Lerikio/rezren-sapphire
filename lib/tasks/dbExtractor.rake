# encoding : UTF-8

namespace :db_extractor do
        require 'highline/import'

        desc "Extraction de bdd pour gestapo"
        task :gestapo => :environment do
                list = ""
		flist = ""
                Computer.not_archived.each do |c|
			if c.adherent != nil && c.adherent.room != nil && c.adherent.credit.actif?
				list += c.mac_address + "\t" + c.adherent.room.full_address + "\n"
			end
			flist = list.gsub(":", "")
                end
                
                File.open("#{Rails.root}/tmp/BDD_Gestapo",'w+') do |f|
                        f.write(flist)
                end
        end
end
