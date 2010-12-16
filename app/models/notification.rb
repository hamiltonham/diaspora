#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification
  include MongoMapper::Document


  key :object_id, ObjectId
  key :kind, String

  belongs_to :user
  belongs_to :person

  timestamps!

  attr_accessible :object_id, :kind, :user_id, :person_id

  def for(user, opts={})
    query = opts.merge(:user_id => user)
    self.all(opts)
  end
end
