class Account < ApplicationRecord
  DEFAULT_PERMISSIONS_BITMASK = 0

  has_one :access_token, :class_name => "Doorkeeper::AccessToken", :foreign_key => :resource_owner_id
  has_many :phone_calls
  has_many :incoming_phone_numbers
  has_many :recordings, :through => :phone_calls, :source => :recordings

  bitmask :permissions,
          :as => [
            :manage_inbound_phone_calls,
            :manage_call_data_records,
            :manage_phone_call_events,
            :manage_aws_sns_messages,
          ],
          :null => false

  alias_attribute :sid, :id
  before_validation :set_default_permissions_bitmask, :on => :create

  include AASM

  aasm :column => :status do
    state :enabled, :initial => true
    state :disabled

    event :enable do
      transitions :from => :disabled, :to => :enabled
    end

    event :disable do
      transitions :from => :enabled, :to => :disabled
    end
  end

  def auth_token
    access_token && access_token.token
  end

  def build_usage_record_collection(params = {})
    Usage::Record::Collection.new(params.merge("account" => self))
  end

  private

  def set_default_permissions_bitmask
    self.permissions_bitmask = DEFAULT_PERMISSIONS_BITMASK if permissions.empty?
  end
end
