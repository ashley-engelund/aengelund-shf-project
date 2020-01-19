class UserChecklistControllerError < StandardError
end
class MissingUserChecklistParameterError < UserChecklistControllerError
end
class UserChecklistNotFoundError < UserChecklistControllerError
end

#
# Note that there are NO new, create, edit, update, or destroy actions.
# A user cannot create a new checklist, nor can a user edit one or destroy one.
# Nor can an admin create a new one or edit one manually or destroy one
#
#

class UserChecklistsController < ApplicationController


  def index
    authorize_user_checklist_class

    # Get all the checklists for the user in the path. Ex: If the current user is an admin,
    # then we want to be sure to see the checklists for a specific user, not for the admin.
    @user = current_user.admin? ? User.find(params[:user_id]) : current_user

    found_lists = UserChecklist.where(user: @user) #.includes(:master_checklist)
    @user_checklists = found_lists.blank? ? [] : found_lists
  end


  def show
    set_user_checklist
    authorize_user_checklist
  end


  def show_progress
    @user = User.find(progress_params[:user_id])

    @membership_guidelines = membership_guideline_root_user_checklist(@user)
    @overall_progress = membership_guidelines_percent_complete(@user)

    @user_checklist = UserChecklist.find(progress_params[:user_checklist_id])
    authorize_user_checklist

    if @overall_progress == 100
      render :membership_guidelines_completed
    end
  end


  # @return Array[<Hash<checklist_id: [Date]>>] - a list of user_checklists that had their date_completed changed.
  #   Each item in the list is a simple Hash of { checklist_id: <id>, date_completed: <the updated date_completed>}
  #   and a success or fail with error message.
  #
  # Don't render a new page.  Just update info as needed and send
  # 'success' or 'fail' info back.
  def all_changed_by_completion_toggle
    raise 'Unsupported request' unless request.xhr?

    authorize UserChecklist

    changed_checklists = []

    user_checklist_id = params[:user_checklist_id]
    user_checklist = UserChecklist.find_by_id(user_checklist_id)

    date_completed = nil # default
    status = 'ok'
    error_text = ''

    if user_checklist
      # list of all those changed_by date_completed toggled
      # toggle the date_completed and give me the list of all those changed
      # all_changed_by_completion_toggle
      checklists_changed = user_checklist.all_changed_by_completion_toggle
      changed_checklists.concat(checklists_changed.map { |checklist_changed| hash_id_date_completed(checklist_changed) })
    else

      status = 'error' # not found
      error_text = t('.not_found', user_checklist_id: user_checklist_id)

      #raise ActiveRecord::RecordNotFound,  "UserChecklist not found! user_checklist_id = #{user_checklist_id}"
    end

    render json: { status: status, changed_checklists: changed_checklists, date_completed: date_completed, error_text: error_text }
  end


  # Set the given UserChecklist to completed (date_completed = Time.zone.now) and
  # set all of its descendants to completed, too.
  #
  # @return [Hash] - the id of the UserChecklist changed (the parent),
  #                  the new date_completed value for it,
  #                  and the new overall percent complete value (for the top-level ancestor of the user_checklist)
  #
  def set_complete_including_kids
    handle_xhr_request do
      set_uc_and_kids_date_completed(params, Time.zone.now)
    end
  end


  def set_uncomplete_including_kids
    handle_xhr_request do
      set_uc_and_kids_date_completed(params, nil)
    end
  end


  private


  def set_user_checklist
    @user_checklist = UserChecklist.includes(:user).find(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def user_checklist_params
    params.require(:user_checklist).permit(:master_checklist, :user_id,
                                           :name, :description, :list_position, :date_completed)
    params
  end


  def progress_params
    params.require(:user_checklist_id)
    params
  end


  def authorize_user_checklist
    authorize @user_checklist
  end


  def authorize_user_checklist_class
    authorize UserChecklist
  end


  # @return [Hash] - a simple hash with the checklist id and date_completed
  def hash_id_date_completed(checklist)
    # use just the Date, not the time
    date_complete = checklist.date_completed.nil? ? nil : checklist.date_completed.to_date
    { checklist_id: checklist.id, date_completed: date_complete }
  end


  def set_uc_and_kids_date_completed(action_params, new_date_completed = Time.zone.now)
    if action_params[:id].blank?
      raise MissingUserChecklistParameterError, t('.missing-checklist-param-error')

    else
      user_checklist_id = action_params[:id]
      user_checklist = UserChecklist.find(user_checklist_id)

      if user_checklist
        if new_date_completed
          user_checklist.set_complete_including_children(new_date_completed)
        else
          user_checklist.set_uncomplete_including_children
        end
        new_percent_complete = membership_guidelines_percent_complete(user_checklist.user)

        { user_checklist_id: user_checklist_id,
          date_completed: user_checklist.date_completed,
          overall_percent_complete: new_percent_complete }

      else
        raise UserChecklistNotFoundError, t('.not_found', id: user_checklist_id)

      end
    end
  end


  def membership_guidelines_percent_complete(uc_user)
    membership_guidelines = membership_guideline_root_user_checklist(uc_user)
    puts "\n  >>> membership_guidelines.percent_complete = #{membership_guidelines.percent_complete}\n"
    membership_guidelines.percent_complete
  end


  # FIXME - this should be from AppConfiguration
  def membership_guideline_root_user_checklist(uc_user)
    UserChecklist.find_by(name: 'Medlemsåtagande', user: uc_user)

  end


  def validate_and_authorize_xhr
    validate_xhr_request
    authorize_user_checklist_class
  end

end
