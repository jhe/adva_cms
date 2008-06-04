require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Install:" do
  include SpecViewHelper
  
  before :each do
    scenario :site, :section, :user
    assigns[:site] = @site
    assigns[:section] = @section
    
    @install_path = '/admin/install'
  end
  
  describe "the :install view" do
    it "should display a form posting to /admin/install" do
      render "admin/install/index"
      response.should have_tag('form[action=?][method=?]', '/admin/install', 'post')
    end
    
    it "should render form fields for creating a new site" do
      render "admin/install/index"
      response.should have_tag('input[type=?][name=?]', 'text', 'site[name]')
      response.should have_tag('input[type=?][name=?]', 'text', 'site[title]')
    end
    
    it "should render form fields for creating a new root section" do
      render "admin/install/index"
      response.should have_tag('input[type=?][name=?]', 'radio', 'section[type]')
      response.should have_tag('input[type=?][name=?]', 'text', 'section[title]')
    end
  end
  
  describe "the :confirmation view" do
    before :each do
      assigns[:user] = @user

      @edit_admin_user_path = 'admin/users/1/edit'
      @admin_site_path = 'admin/sites/1'
      
      template.stub!(:edit_admin_user_path).and_return @edit_admin_user_path
      template.stub!(:admin_site_path).and_return @admin_site_path
    end
    
    it "should display a link to the current user's profile" do
      render "admin/install/confirmation"
      response.should have_tag('a[href=?]', @edit_admin_user_path)
    end
    
    it "should display a link to the sites admin section" do
      render "admin/install/confirmation"
      response.should have_tag('a[href=?]', @admin_site_path)
    end
  end
end