class WorkGroupsController < ApplicationController
  def new
    @work_group = params[:work_group] ? WorkGroup.new(work_group_params) : WorkGroup.new
    @notice = params[:notice]
    @worksheet_urls = WorksheetTemplate.where(user: User.first_teacher).pluck(:image_url).select do |url|
      url.include?('res.cloudinary.com/naokimi')
    end
    return unless params[:no_model_fields]

    @emails =          custom_params[:emails]
    @urls =            custom_params[:worksheet_url]
    @delivery_method = custom_params[:delivery_method] # TODO: fix passing of params for this
    @start_time =      custom_params[:start_time]
    @start_date =      custom_params[:start_date]
  end

  def create
    return redirect_with_params('Please input at least 2 email addresses') if custom_params[:emails].split(' ').size < 2

    begin
      @users_and_work_groups = vars_for_mailer
      case custom_params[:delivery_method]
      when 'send email'
        @users_and_work_groups[:users].each do |user|
          DemoMailer.with(user: user, work_group: @users_and_work_groups[:work_group]).invite.deliver_later
        end
        redirect_to new_work_group_path(notice: 'Invitations sent')
      when 'generate links' then redirect_to new_work_group_path(notice: custom_links)
      else redirect_with_params('Please select a delivery method')
      end
    rescue StandardError => e
      redirect_with_params(e.message)
    end
  end

  private

  def work_group_params
    # params.require(:work_group).permit(:turn_time)
  end

  def custom_params
    params.require(:no_model_fields).permit(:emails, :worksheet_url, :start_time, :start_date, :delivery_method)
  end

  def redirect_with_params(message)
    redirect_to new_work_group_path(work_group: work_group_params, no_model_fields: custom_params, notice: message)
  end

  def vars_for_mailer
    if custom_params[:start_date] && custom_params[:start_time]
      start_time = (custom_params[:start_date] + ' ' + custom_params[:start_time]).in_time_zone
    end

    WorkGroupDemoPrepper.new(
      custom_params[:emails],
      custom_params[:worksheet_url],
      start_time,
      '1'
    ).call
  end

  def custom_links
    work_group = @users_and_work_groups[:work_group]
    @users_and_work_groups[:users].map do |user|
      short_url = work_group.minified_url(user)
      short_url + '---' + user.email
    end
  end
end
