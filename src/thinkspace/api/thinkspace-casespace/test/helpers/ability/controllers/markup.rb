module Test; module Ability; module Controllers; module Thinkspace  module Markup; module Api

  class CommentsController
    def setup_fetch(route); route.view_action; end
    def before_save(route)
      comment = route.model
      user    = route.dictionary_user
      if comment.present? && user.present?
        comment.commenterable = user
      end
    end
    def after_save_fetch(route, options)
      auth    = route.get_params_auth
      comment = route.model
      if comment.present?
        commentable = comment.commentable
        return if commentable.blank?
        auth[:commentable_type] = route.model_to_path(commentable)
        auth[:commentable_id]   = commentable.id
      end
    end
  end

  class LibrariesController
    def after_save_remove_comment_tag(route, options); after_save_add_comment_tag(route, options); end
    def after_save_add_comment_tag(route, options)
      lc_class        = ::Thinkspace::Markup::LibraryComment
      library_comment = route.dictionary_model(lc_class)
      route.set_params(:comment_id, library_comment.id)  if library_comment.present?
    end
  end

end; end; end; end; end; end
