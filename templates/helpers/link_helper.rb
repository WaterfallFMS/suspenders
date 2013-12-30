module LinkHelper
  def show_link(object,link=nil)
    return unless can? :show, object

    link ||= object
    link_to 'Show', link
  end

  def new_link(object,link)
    return unless can? :new, object

    link_to "New #{object.model_name.human}", link
  end

  def edit_link(object,link)
    return unless can? :edit, object

    link_to 'Edit', link
  end

  def destroy_link(object,link=nil)
    return unless can? :destroy, object

    link ||= object
    link_to 'Destroy', link
  end
end