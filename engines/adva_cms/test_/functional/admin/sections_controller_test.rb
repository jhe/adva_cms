require File.dirname(__FILE__) + "/../../test_helper"

# TODO
# check pagecaching

# With.aspects << :access_control

class AdminArticlesControllerTest < ActionController::TestCase
  tests Admin::SectionsController

  def setup
    super
    login_as_superuser!
  end
  
  def default_params
    { :site_id => @site.id }
  end
   
  describe "routing" do
    with_options :controller => 'admin/sections', :site_id => "1" do |r|
      r.it_maps :get,    "/admin/sites/1/sections",        :action => 'index'
      r.it_maps :get,    "/admin/sites/1/sections/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "/admin/sites/1/sections/new",    :action => 'new'
      r.it_maps :post,   "/admin/sites/1/sections",        :action => 'create'
      r.it_maps :get,    "/admin/sites/1/sections/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "/admin/sites/1/sections/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "/admin/sites/1/sections/1",      :action => 'destroy', :id => '1'
    end
  end
  
  describe "GET to :new" do
    action { get :new, default_params }
    
    with :an_empty_site do
      it_guards_permissions :create, :section
      
      with :access_granted do
        it_assigns :site, :section
        it_renders_template :new
      end
    end
  end
  
  describe "POST to :create" do
    action do 
      Section.with_observers :section_sweeper do
        post :create, default_params.merge(@params)
      end
    end
    
    with :an_empty_site do
      with :valid_section_params do
        it_guards_permissions :create, :section
        
        with :access_granted do
          it_assigns :site, :section
          it_redirects_to { @controller.admin_section_contents_path(assigns(:section)) }
          it_assigns_flash_cookie :notice => :not_nil
          it_sweeps_page_cache :by_site => :site
  
          it "associates the new Section to the current site" do
            assigns(:section).site.should == @site
          end
        end
      
        with :invalid_section_params do
          it_assigns :site, :section
          it_renders_template :new
          it_assigns_flash_cookie :error => :not_nil
        end
      end
    end
  end
  
  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @section.id) }
    
    with :an_empty_section do
      it_guards_permissions :update, :section
      
      with :access_granted do
        it_assigns :site, :section
        it_renders_template :edit
      end
    end
  end
  
  describe "PUT to :update" do
    action do
      Section.with_observers :section_sweeper do
        params = default_params.merge(@params).merge(:id => @section.id)
        params[:section][:title] = "#{@section.title} was changed" unless params[:section][:title].blank?
        put :update, params
      end
    end
  
    with :an_empty_section do
      with :valid_section_params do
        it_guards_permissions :update, :section
      
        with :access_granted do
          it_assigns :section
          it_updates :section
          it_redirects_to { edit_admin_section_path(@site, @section) }
          it_assigns_flash_cookie :notice => :not_nil
          # it_triggers_event :section_updated
          it_sweeps_page_cache :by_section => :section
        end
      end
  
      with :invalid_section_params do
        with :access_granted do
          it_renders_template :edit
          it_assigns_flash_cookie :error => :not_nil
        end
      end
    end
  end
  
  describe "PUT to :update_all" do
    action do 
      params = {:sections => {@section.id => {'parent_id' => @another_section.id}}}
      put :update_all, default_params.merge(params) 
    end
    
    with :an_empty_section do
      before do
        @another_section = Section.make :site => @site
        @old_path = @section.path
      end
      
      it_guards_permissions :update, :section
      
      with :access_granted do
        it "updates the site's sections with the section params" do
          @section.reload.parent_id.should != @another_section.id
        end
      
        it "updates the section's paths" do
          @section.reload.path.should == "#{@another_section.path}/#{@section.permalink}"
        end
        
        # FIXME expire cache by site
      end
    end
  end
  
  describe "DELETE to :destroy" do
    with :an_empty_section do
      action do 
        Section.with_observers :section_sweeper do
          delete :destroy, default_params.merge(:id => @section.id)
        end
      end
      
      it_guards_permissions :destroy, :section
      
      with :access_granted do
        it_assigns :site, :section
        it_destroys :section
        # it_triggers_event :section_deleted
        # it_redirects_to { admin_site_path(@site) } # FIXME actually is new_admin_section_path?
        it_sweeps_page_cache :by_site => :site
        it_assigns_flash_cookie :notice => :not_nil
      end
    end
  end
end
