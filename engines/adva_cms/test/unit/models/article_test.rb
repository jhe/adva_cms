require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ArticleTest < ActiveSupport::TestCase
  def setup
    super
    @page = Page.first
    @article = @page.articles.published(:limit => 1).first
  end
  
  test "sanitizes the attributes excerpt, excerpt_html, body and body_html" do
    Article.should filter_attributes(:except => [:excerpt, :excerpt_html, :body, :body_html, :cached_tag_list])
  end
  
  test "has many comments" do
    Article.should have_many_comments
  end
  
  test "sets the position before create" do
    Article.before_create.should include(:set_position)
  end

  # validations
  
  # FIXME implement!
  # test "validates presence of an author (through belongs_to_author)" do
  #   @article.should validate_presence_of(:author)
  # end
  # 
  # test "validates that the author is valid (through belongs_to_author)" do
  #   @article.author = User.new
  #   @article.valid?.should be_false
  # end
  
  test "validates the uniqueness of the permalink per section" do
    @article = Article.new
    @article.should validate_uniqueness_of(:permalink, :scope => :section_id)
  end

  # CLASS METHODS
  
  # find_by_permalink
  
  test "#find_by_permalink finds articles within passed time span" do
    article = Article.find_by_permalink '2008', '1', '1', 'a-page-article'
    article.permalink.should == 'a-page-article'
    article.published_at.to_date.should == Time.utc('2008', '1', '1').to_date
  end
  
  test "#find_by_permalink finds a record when the passed date scope matches the article's published date" do
    date = [:year, :month, :day].map {|key| @article.published_at.send(key).to_s }
    @page.articles.find_by_permalink(*date << @article.permalink).should == @article
  end
  
  test "#find_by_permalink does not find a record when the passed date scope does not match the article's published date" do
    date = [:year, :month, :day].map {|key| @article.published_at.send(key).to_s }
    date[2] = date[2].to_i + 1
    @page.articles.find_by_permalink(*date << @article.permalink).should be_nil
  end
  
  test "#find_by_permalink finds a record when no date scope is passed" do
    Article.find_by_permalink(@article.permalink).should == @article
  end
  
  # INSTANCE METHODS
  
  # full_permalink
  
  test '#full_permalink returns a hash with the year, month, day and permalink' do
    @article.section = Blog.new
    @article.full_permalink.should == { :year      => @article.published_at.year, 
                                        :month     => @article.published_at.month, 
                                        :day       => @article.published_at.day, 
                                        :permalink => @article.permalink }
  end

  test '#full_permalink raises an exception when the article does not belong to a Blog' do
    lambda{ @article.full_permalink }.should raise_error
  end
  
  # FIXME not true right now, investigate if we want this at all
  # test '#full_permalink raises an exception when the article is not published' do
  #   @article.reload
  #   @article.published_at = nil
  #   lambda{ @article.full_permalink }.should raise_error
  # end
  
  # primary?
  
  test "#primary? returns true when the article is its section's primary article" do
    @page.articles.primary.primary?.should be_true
  end

  test "#primary? returns false when the article is not section's primary article" do
    @page.articles.build.primary?.should be_false
  end

  # has_excerpt
  test '#has_excerpt returns true when the excerpt is not blank' do
    @article.excerpt = 'excerpt'
    @article.has_excerpt?.should be_true
  end

  test '#has_excerpt returns false when the excerpt is nil' do
    @article.excerpt = nil
    @article.has_excerpt?.should be_false
  end

  test '#has_excerpt returns false when the excerpt is an empty string' do
    @article.excerpt = ''
    @article.has_excerpt?.should be_false
  end
  
  # accept_comments?
  
  test "accepts comments when comments never expire" do
    # FIXME wtf, srsly. use CONSTANTS instead of integers. that's what they are for.
    @article.comment_age = 0
    @article.published_at = 1.days.ago
    @article.accept_comments?.should be_true
  end

  test "accepts comments when comments are allowed and not expired" do
    @article.comment_age = 3
    @article.published_at = 1.days.ago
    @article.accept_comments?.should be_true
  end

  test "does not accept comments when comments are allowed but expired" do
    @article.comment_age = 1
    @article.published_at = 1.days.ago
    @article.accept_comments?.should be_false
  end

  test "does not accept comments when comments are not allowed" do
    @article.comment_age = -1
    @article.published_at = 1.days.ago
    @article.accept_comments?.should be_false
  end

  test "does not accept comments when the article is not published" do
    @article.comment_age = 0
    @article.published_at = nil
    @article.accept_comments?.should be_false
  end
  
  # FIXME test the actual model instead
  
  # # previous
  # 
  # test "#previous finds the previous published article in the article's section" do
  #   options = {:conditions => ["published_at < ?", @article.published_at], :order=>:published_at}
  #   mock(Article).published(options)
  #   @article.previous
  # end
  # 
  # # next
  # 
  # test "#next finds the next published article in the article's section" do
  #   options = {:conditions => ["published_at > ?", @article.published_at], :order=>:published_at}
  #   mock(Article).find_published(:first, options)
  #   @article.next
  # end

  # set_position

  test "#set_position sorts the article to the bottom of the list (sets to max(position) + 1)" do
    article = @page.articles.create! :title => 'title', :body => 'body', :author => User.first
    article.position.should == @page.articles.maximum(:position).to_i
  end

  # filtering
  
  test "it allows using insecure html in article body and excerpt" do
    @article.body = 'p{position:absolute; top:50px; left:10px; width:150px; height:150px}. insecure css'
    @article.filter = 'textile_filter'
    @article.save(false)
    @article.body_html.should == %(<p style="position:absolute; top:50px; left:10px; width:150px; height:150px;">insecure css</p>)
  end
end
