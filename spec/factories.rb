FactoryGirl.define do
  factory :account do |n|
    trait :with_access_token do
      after(:build) do |account|
        account.access_token ||= build(:access_token, :resource_owner_id => account.id)
      end
    end
  end

  factory :phone_call do
    account
    with_normalized_to
    from     "2442"
    voice_url "https://rapidpro.ngrok.com/handle/33/"

    trait :with_normalized_to do
      to "+85512334667"
    end

    trait :with_denormalized_to do
      to "855 12 334 667"
    end

    trait :with_normalized_voice_method do
      voice_method "GET"
    end

    trait :with_denormalized_voice_method do
      voice_method "get"
    end

    trait :with_status_callback_url do
      status_callback_url "https://rapidpro.ngrok.com/handle/33/"
    end

    trait :with_status_callback_method do
      status_callback_method "POST"
    end

    trait :from_account_with_access_token do
      association :account, :factory => [:account, :with_access_token]
    end

    trait :with_optional_attributes do
      from_account_with_access_token
      with_normalized_voice_method
      with_status_callback_url
      with_status_callback_method
    end
  end

  factory :access_token, :class => Doorkeeper::AccessToken
end

