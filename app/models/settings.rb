
# Permet de stocker des préférences de l'application

class Settings < RailsSettings::CachedSettings
	attr_accessible :var
end
