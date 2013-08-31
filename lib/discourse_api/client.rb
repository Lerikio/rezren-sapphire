class DiscourseApi::Client < DiscourseApi::Resource

  def initialize(host, port=80)
    @host = host
    @port = port
  end

  post :topic_invite_user => "/t/:topic_id/invite", :require => [:email, :topic_id]
  get :topics_latest => "/latest.json"
  get :topics_hot => "/hot.json"
  get :categories => "/categories.json"

  def create_user(args)
    #On récupère les infos parce que quelqu'un a trouvé bien de rendre la création d'un utilisateur compliquée
    parsed_path = DiscourseApi::ParsedPath.new("/users/hp.json", {})
    hp_json = perform_get(parsed_path, {}).body
    return false unless hp_json
    hp_infos = ActiveSupport::JSON.decode(hp_json)
    args[:challenge] = hp_infos["challenge"].reverse
    args[:password_confirmation] = hp_infos["value"]
    parsed_path = DiscourseApi::ParsedPath.new("/users", {:require => [:name, :email, :password, :username]})
    perform_post(parsed_path, args)
  end
end