require 'test_helper'

class PostTest < ActiveSupport::TestCase

  def setup
    @user = User.new(username: "Fake_user", email: "foo@example.com")
    @user.save
    @post = Post.new(url: "http://www.google.com", user_id: @user.id)
    @post.save
  end

  def test_post_is_valid
    assert @post.valid?
  end

  def test_url_cannot_be_blank
    @post.url = " 	"
    refute @post.valid?

    @post.url = nil
    refute @post.valid?
  end

  def test_url_cannot_be_too_long
    @post.url = "http://example.com/" + "a" * 243
    refute @post.valid?
  end

  def test_user_can_have_multiple_posts
    new_post = @post.dup
    new_post.save
    assert_equal(2, @user.posts.length)
  end

  def test_ar_enforces_user_existence
    @post.user_id = 999
    refute @post.valid?
  end

  def test_db_enforces_user_existence
    @post.user_id = 999
    assert_raise_with_partial_message ActiveRecord::InvalidForeignKey,
      /^PG::ForeignKeyViolation.*insert or update on table "posts" violates foreign key constraint "user_id"/ do
     @post.update_attribute(:user_id, 999)
   end
  end

  def test_ar_forbids_destroying_user_with_existing_posts
    assert_equal(false, @user.destroy)
  end

  def test_db_forbids_deleting_user_with_existing_posts
    assert_raise_with_partial_message ActiveRecord::InvalidForeignKey,
      /^PG::ForeignKeyViolation.*update or delete on table "users" violates foreign key constraint "user_id" on table "posts"/ do
     @user.delete
   end
  end

  def test_ar_forbids_null_user_id
    @post.user_id = nil
    refute @post.valid?
  end

  def test_db_forbids_null_user_id
    assert_raise_with_partial_message ActiveRecord::StatementInvalid,
      /^PG::NotNullViolation.*null value in column "user_id" violates not-null constraint/ do
     @post.update_attribute(:user_id, nil)
   end
  end

end
