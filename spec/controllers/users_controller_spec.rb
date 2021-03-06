require 'rails_helper'

describe UsersController, :type => :controller do
  render_views

  let(:user) { FactoryGirl.create(:user, admin: false) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET index' do
    context 'as admin' do
      it 'renders a list of all users' do
        allow_any_instance_of(User).to receive(:admin?).and_return(true)
        get :index
        expect(response).to render_template 'index'
      end
    end

    context 'as normal user' do
      it 'redirects to incoming_events#index' do
        get :index
        expect(response).to redirect_to incoming_events_path
        expect(flash[:alert]).to eql "Not authorized"
      end
    end
  end

  describe 'GET new' do
    context 'as admin' do
      it "renders the 'new' template" do
        allow_any_instance_of(User).to receive(:admin?).and_return(true)
        get :new
        expect(response).to render_template 'new'
      end
    end

    context 'as normal user' do
      it 'redirects to users#show' do
        get :new
        expect(response).to redirect_to user_path(user)
        expect(flash[:alert]).to eql "Not authorized"
      end
    end
  end

  describe 'GET edit' do
    context 'as admin' do
      it "renders the 'edit' template" do
        allow_any_instance_of(User).to receive(:admin?).and_return(true)
        other_user = FactoryGirl.create(:user)
        get :edit, params: { id: other_user.id }
        expect(response).to render_template 'edit'
        expect(assigns(:user)).to eql other_user
      end
    end

    context 'as normal user' do
      it 'renders the current users "edit" template' do
        get :edit, params: { id: 'nonexistent_id' }
        expect(response).to render_template 'edit'
        expect(assigns(:user)).to eql user
      end
    end
  end

  describe 'POST create' do
    context 'as admin' do

      let(:attributes) { FactoryGirl.attributes_for(:user) }

      before do
        allow_any_instance_of(User).to receive(:admin?).and_return(true)
      end

      it 'creates a new record from valid params' do
        expect do
          post :create, params: { user: attributes }
        end.to change{User.count}.by(1)
        expect(response).to redirect_to users_path
      end

      it "renders 'new' template for invalid params" do
        expect do
          post :create, params: { user: {email:""} }
        end.not_to change{User.count}
        expect(response).to render_template 'new'
      end

      it 'sends an email invitation if checked' do
        email = attributes[:email]
        perform_enqueued_jobs do
          expect { post :create, params: { user: { email: email }, send_invitation: '1' } }.to \
            change { ActionMailer::Base.deliveries.size }.by(1)
        end
        expect(assigns(:user).password_reset_token).not_to be_nil
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to include email
      end
    end

    context 'as normal user' do
      it 'redirects to root_path' do
        post :create
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eql "Not authorized"
      end
    end
  end

  describe 'PATCH update' do
    context 'as admin' do
      before do
        allow_any_instance_of(User).to receive(:admin?).and_return(true)
      end

      it 'successfully updates other user and redirects' do
        other_user = FactoryGirl.create(:user)
        allow_any_instance_of(User).to receive(:valid?).and_return(true)
        patch :update, params: { id: other_user.to_param, user: { email: '' } }
        expect(flash[:notice]).not_to be_blank
        expect(response).to redirect_to user_path(other_user)
      end

      it "fails to update other user and renders 'edit' template" do
        other_user = FactoryGirl.create(:user)
        allow_any_instance_of(User).to receive(:valid?).and_return(false)
        patch :update, params: { id: other_user.to_param, user: { email: '' } }
        expect(flash[:notice]).to be_blank
        expect(response).to render_template 'edit'
      end
    end

    context 'as a normal user' do
      it 'updates current user' do
        allow_any_instance_of(User).to receive(:valid?).and_return(true)
        expect do
          patch :update, params: { id: user.to_param, user: { email: 'foo@bar.com' } }
        end.to change{ user.reload.email }
        expect(flash[:notice]).not_to be_blank
        expect(response).to redirect_to user_path(user)
      end

      it 'tries to update other user but silently updates current user instead' do
        allow_any_instance_of(User).to receive(:valid?).and_return(true)
        expect do
          patch :update, params: { id: 'does-not-matter', user: { email: 'foo@bar.com' } }
        end.to change{ user.reload.email }
      end

      it "fails to update current user and renders 'edit' template" do
        allow_any_instance_of(User).to receive(:valid?).and_return(false)
        patch :update, params: { id: user.to_param, user: { email: '' } }
        expect(flash[:notice]).to be_blank
        expect(response).to render_template 'edit'
      end
    end
  end

  describe 'DELETE destroy' do
    context 'as admin' do
      it 'destroys other user' do
        other_user = FactoryGirl.create(:user)
        allow_any_instance_of(User).to receive(:admin?).and_return(true)
        expect do
          delete :destroy, params: { id: other_user.to_param }
        end.to change{User.count}.by(-1)
        expect(flash[:notice]).not_to be_blank
        expect(response).to redirect_to users_path
      end
    end

    context 'as normal user' do
      it 'redirects to users#index' do
        allow_any_instance_of(User).to receive(:valid?).and_return(false)
        expect do
          delete :destroy, params: { id: 'does-not-matter' }
        end.not_to change{User.count}
        expect(flash[:alert]).to eql 'Not authorized'
        expect(response).to redirect_to users_path
      end
    end
  end
end
