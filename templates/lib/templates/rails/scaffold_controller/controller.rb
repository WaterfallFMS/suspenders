<% if namespaced? -%>
require_dependency "<%= namespaced_file_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  decorates_assigned :<%= singular_table_name %>
  before_action :set_<%= singular_table_name %>,     only: [:show, :edit, :update, :destroy]
  before_action :set_new_<%= singular_table_name %>, only: [:new, :create]

  # GET <%= route_url %>
  def index
    @<%= plural_table_name %> = policy_scope(<%= class_name %>).decorate
  end

  # GET <%= route_url %>/1
  def show
  end

  # GET <%= route_url %>/new
  def new
  end

  # GET <%= route_url %>/1/edit
  def edit
  end

  # POST <%= route_url %>
  def create
    if @<%= orm_instance.save %>
      redirect_to @<%= singular_table_name %>, notice: <%= "'#{human_name} was successfully created.'" %>
    else
      render action: 'new'
    end
  end

  # PATCH/PUT <%= route_url %>/1
  def update
    if @<%= orm_instance.update("#{singular_table_name}_params") %>
      redirect_to @<%= singular_table_name %>, notice: <%= "'#{human_name} was successfully updated.'" %>
    else
      render action: 'edit'
    end
  end

  # DELETE <%= route_url %>/1
  def destroy
    @<%= orm_instance.destroy %>
    redirect_to <%= index_helper %>_url, notice: <%= "'#{human_name} was successfully destroyed.'" %>
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    authorize @<%= singular_table_name %>
  end

  def set_new_<%= singular_table_name %>
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>
    @<%= singular_table_name %>.assign_attributes <%= "#{singular_table_name}_params" %> if params[:action] == 'create'
    authorize @<%= singular_table_name %>
  end

  # Only allow a trusted parameter "white list" through.
  def <%= "#{singular_table_name}_params" %>
    params.require(<%= ":#{singular_table_name}" %>).permit(*policy(<%= class_name %>).permitted_attributes)
  end
end
<% end -%>
