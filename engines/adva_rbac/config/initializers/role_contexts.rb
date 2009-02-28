ActionController::Dispatcher.to_prepare do
  # FIXME move the theme role contexts to adva_theme
  Site.acts_as_role_context    :actions => ["manage themes", "manage assets"]
  Section.acts_as_role_context :actions => ["create article", "update article", "delete article"], :parent => Site
  Content.acts_as_role_context :parent => Section

  CalendarEvent.acts_as_role_context :parent => Section
  Board.acts_as_role_context :parent => Section
  Topic.acts_as_role_context :parent => Section
  Photo.acts_as_role_context :parent => Section

  Comment.acts_as_role_context # :parent => Content
  Rbac::Context::Comment.parent_accessor = :commentable
end