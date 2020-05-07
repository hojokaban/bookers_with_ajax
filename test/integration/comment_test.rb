require 'test_helper'

class CommentTest < ActionDispatch::IntegrationTest
	include Warden::Test::Helpers

	def setup
		@user = users(:luffy)
		@book = books(:book1)
		@comment = book_comments(:comment)

		login_as(@user, :scope => :user)
	end

	test "comment interface" do

		#books/index

		get books_path
		assert_match "1 comment", response.body, count: 1
		assert_match "0 comments", response.body, count: 1

		#books/show

		get book_path(@book)
		assert_match @comment.content, response.body
		assert_match "1 comment", response.body
		assert_select "form"
		assert_select "a", text:"Delete", count: 0

		#comment create fails
=begin
		assert_no_difference 'BookComment.count' do
			post comment_path, params: {book_comment:{content:"  ",
										book_id: @book.id}}
			end
			assert_template 'books/show'
			assert_select "div#error_explanation"
		#comment create succeeds

		assert_difference 'BookComment.count', 1 do
			post comment_path, params: {book_comment:{content:"comment",
										book_id: @book.id}}
			end
			follow_redirect!
			assert_not flash.empty?
=end
		#comment destroy by user

		#@comment_new = BookComment.find_by(content:"comment")
		#assert_select "a", text:"Delete"
		#assert_difference 'BookComment.count', -1 do
		#	delete comments_path(@comment_new)
		#end
		#assert_redirected_to book_path(@book)
		#follow_redirect!
		#assert_not flash.empty?

		#comment of other_user's destroy

		assert_select "a", text:"Delete", count: 0
		#assert_no_difference 'BookComment.count' do
		#	delete comments_path(@comment)
		#end
		#assert_not flash.empty?

	end

	test "comments should appear in a correct book" do
		get book_path(books(:book2))
		assert_no_match @comment.content, response.body
	end

	test "should comment with Ajax" do
		assert_no_difference 'BookComment.count' do
			post comment_path, params: {book_comment:{content:"",
													book_id: @book.id}}, xhr: true
		end
		#assert_select "div#error_explanation"
		assert flash.empty?
		assert_difference 'BookComment.count', 1 do
			post comment_path, params: {book_comment:{content:"comment",
													book_id: @book.id}}, xhr: true
		end
		assert_not flash.empty?
		assert_match BookComment.last.content, response.body
		assert_match "2 comments", response.body
		assert_difference 'BookComment.count', -1 do
			delete comments_path(BookComment.last), xhr: true
		end
		assert_not flash.empty?
		assert_match "1 comment", response.body
	end
end
