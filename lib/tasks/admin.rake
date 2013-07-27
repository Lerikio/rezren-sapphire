desc "Cree un administrateur"
task "admin:create" => :environment do
  require 'highline/import'
  begin
    admin = Admin.new
    admin.username = ask("Username:")
    begin
      password = ask("Password:") {|q| q.echo = false}
      password_confirmation = ask("Repeat password:") {|q| q.echo = false}
    end while password != password_confirmation
    admin.password = password
    saved = admin.save!
    if !saved
      puts admin.errors.full_messages.join("\n")
      next
    end
  end while !saved
end