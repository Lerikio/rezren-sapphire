class DhcpConf
	attr_accessor :computers

	@computers = []

	def initialize(computers)
		@computers = computers
	end

	def output
		out = ""
		@computers.each do |computer|
			#Au format :
			#host NOMHOTE {
			#	hardware ethernet ADRESSEMAC;
			#	fixed-address IP;
			#}
			out = out + "host #{computer.name} {\n\thardware ethernet #{computer.mac_address};\n\tfixed-address #{computer.ip_address};\n}"
		end
		out
	end

end