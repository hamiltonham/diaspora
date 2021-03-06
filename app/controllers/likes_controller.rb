#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class LikesController < CommentsController

  def create
    target = current_user.find_visible_post_by_id params[:post_id]
    if post.likes.where(:diaspora_handle => current_user.diaspora_handle).any?
      render :nothing => true, :status => 409
    end

    if params[:dislike]
      text = 'dislikes this'
      @dislike = current_user.build_like(text, :on => target)
      if @dislike.save(:safe => true)
        raise 'MongoMapper failed to catch a failed save' unless @dislike.id
        Rails.logger.info("event=like_create user=#{current_user.diaspora_handle} status=success like=#{@dislike.id}")
        current_user.dispatch_like(@dislike)

        respond_to do |format|
          format.js{
            json = { :post_id => @dislike.post_id,
                                       :like_id => @dislike.id,
                                       :html => render_to_string(
                                         :partial => 'likes/like',
                                         :locals => { :hash => {
                                           :like => @dislike,
                                           :person => current_user,
                                          }}
                                        )
                                      }
            render(:json => json, :status => 201)
          }
          format.html{ render :nothing => true, :status => 201 }
        end
      else
        render :nothing => true, :status => 406
      end
    else
      text = 'likes this'
      @like = current_user.build_like(text, :on => target)
      if @like.save(:safe => true)
        raise 'MongoMapper failed to catch a failed save' unless @like.id
        Rails.logger.info("event=like_create user=#{current_user.diaspora_handle} status=success like=#{@like.id}")
        current_user.dispatch_like(@like)

        respond_to do |format|
          format.js{
            json = { :post_id => @like.post_id,
                                       :like_id => @like.id,
                                       :html => render_to_string(
                                         :partial => 'comments/comment',
                                         :locals => { :hash => {
                                           :like => @like,
                                           :person => current_user,
                                          }}
                                        )
                                      }
            render(:json => json, :status => 201)
          }
          format.html{ render :nothing => true, :status => 201 }
        end
      else
        render :nothing => true, :status => 406
      end
    end
  end

end
