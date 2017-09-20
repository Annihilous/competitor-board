require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validations' do
    it 'is valid if required fields are present' do
      user = build(:user)
      expect(user).to be_valid
      expect(user.errors).to be_empty
    end

    [ #required field
      :email,
    ].each do |required_field|
      it "is invalid if #{required_field} is not present" do
        user = build(:user)
        user.send("#{required_field}=", '')
        expect(user).not_to be_valid
        expect(user.errors).to have_key(required_field)
      end

      it "is invalid if #{required_field} is set to nil" do
        user = build(:user)
        user.send("#{required_field}=", nil)
        expect(user).not_to be_valid
        expect(user.errors).to have_key(required_field)
      end
    end

    [   #unique field  #value
      [ :email,        'user@mail.com' ],
    ].each do |test_case|
      unique_field, value = test_case

      it "is invalid if #{unique_field} is not unique" do
        user_1 = build(:user)
        user_1.send("#{unique_field}=", value)
        user_1.save

        user_2 = build(:user)
        user_2.send("#{unique_field}=", user_1.send(unique_field))

        expect(user_2).not_to be_valid
        expect(user_2.errors).to have_key(unique_field)
      end
    end
  end

  describe '#create' do
    it 'queues a welcome email' do
      expect { create(:user) }
        .to have_enqueued_job.on_queue('mailers')
    end

    it 'ensures the presence of a secure_id' do
      user = create(:user, secure_id: nil)
      user.reload

      expect(user.secure_id).not_to eq(nil)
    end
  end

  context 'given a User' do
    before(:each) do
      @user = create(:user)
    end

    describe 'send_welcome_email' do
      it 'queues a welcome email' do
        expect { @user.send_welcome_email }
          .to have_enqueued_job.on_queue('mailers')
      end

      it 'creates an ActionMailer::DeliveryJob' do
        expect(@user.send_welcome_email.class).to eq(ActionMailer::DeliveryJob)
      end
    end
  end
end
