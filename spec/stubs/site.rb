define Site do
  has_many :sections, [:find, :build, :root] => stub_section
  has_many :themes, [:find, :build, :root] => stub_theme
  has_many :users, :build => stub_user
  has_many :users_and_superusers, stub_users
        
  has_many :comments, [:find, :build] => stub_comment, :paginate => stub_comments
  has_many [:approved_comments, :unapproved_comments], stub_comments
        
  has_many :cached_pages, :find => stub_cached_page, 
                          :paginate => stub_cached_pages, 
                          :delete_all => nil, 
                          :total_entries => 2
                         
  methods  :id => 1,
           :name => 'site-1',
           :host => 'test.host',
           :perma_host => 'test-host',
           :title => 'site title' ,
           :subtitle => 'site subtitle',
           :email => 'foo@bar.baz' ,
           :timezone => 'timezone',
           :articles_per_page => 15,
           :comment_filter => 'comment_filter',
           :theme_names => ['theme-1'],
           :current_themes => [],
           :current_theme? => true,
           :valid? => true,
           :save => true,
           :update_attributes => true,
           :destroy => true,
           :unapproved_comments => [], # wtf
           :activities => [],
           :current_theme_template_paths => [],
           :current_theme_layout_paths => [],
           :has_attribute? => true,
           :required_role_for => :admin
        
  instance :default          
end

scenario :site do
  @site = stub_site
  @sites = [stub_site, stub_site] # TODO lookup :all is broken
  
  # Site.stub!(:new).and_return @site # TODO baaaad idea
  Site.stub!(:find).and_return @site  
  Site.stub!(:find_by_host).and_return @site
  Site.stub!(:find_or_initialize_by_host).and_return @site
  Site.stub!(:paginate).and_return @sites 
  Site.stub!(:multi_sites_enabled).and_return true
  
end