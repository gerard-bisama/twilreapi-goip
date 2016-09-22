class Api::Admin::BaseController < Api::BaseController
  before_action :authorize_admin!

  private

  def respond_with_resource
    respond_with(:api, :admin, resource)
  end

  def authorize_admin!
    deny_access! if !current_account.permissions?(permission_name)
  end
end