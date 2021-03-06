ActiveRecord::Base.send :include, ActiveRecord::HasManyComments
ActionController::Base.send :include, ActionController::ActsAsCommentable

# wtf ...
ActiveSupport::Dependencies.autoloaded_constants -= %w(ActionController::ActsAsCommentable ActiveRecord::HasManyComments)

require 'format'

register_javascript_expansion :admin   => %w( adva_comments/admin/comments )
register_stylesheet_expansion :default => %w( adva_comments/comments )
