require 'spec_helper'

describe SessionsController do
  let(:user) { FactoryGirl.create(:user, admin: false) }

  context "as logged in user" do
		before do
  		controller.stub(:current_user).and_return(user)
		end

  	describe "GET 'new'" do
    	it "redirects to root URL" do
      	get 'new'
        expect(response).to be_redirect
        expect(response).to redirect_to root_path
    	end
  	end

    describe "POST 'create'" do
      it "redirects to root URL" do
        post 'create', user: { email: user.email, password: user.password }
        expect(response).to redirect_to root_path
      end
    end
	end

  context "as not logged in user" do
    before do
      controller.stub(:current_user).and_return nil
    end

    describe "GET 'new'" do
      it "is successful" do
        get 'new'
        expect(response).to be_success
        expect(response).to render_template 'new'
      end
    end

    describe "POST 'create'" do
      context "authenticated" do
        context "with remember me option" do
          it "sets cookies permanent" do
            post 'create', email: user.email, password: user.password, remember_me: true
            expect(cookies.permanent[:auth_token]).to eq user.auth_token
          end
        end

        context "without remember me option" do
          it "sets cookies auth_token" do
            post 'create', email: user.email, password: user.password
            expect(cookies[:auth_token]).to eq user.auth_token
          end
        end
      end

      it "redirects to root URL and displays a success message" do
        post 'create', email: user.email, password: user.password
        expect(response).to redirect_to incoming_events_path
        expect(flash[:notice]).to eq 'Logged in!'
      end
    end

    context "not authenticated" do
      it "redirects to root URL and displays an error message" do
        post 'create', email: 'wrong', password: 'login'
        expect(cookies[:auth_token]).to be_nil
        expect(cookies.permanent[:auth_token]).to be_nil
        expect(response).to redirect_to root_path
        expect(flash[:error]).to eq 'Email or password is invalid.'
      end
    end
  end

  describe "DELETE 'destroy'" do
    before { cookies[:auth_token] = user.auth_token }

    it "deletes the auth token from the cookies hash, redirects to root and displays a success message" do
      delete 'destroy'
      expect(cookies[:auth_token]).to be_nil
      expect(response).to redirect_to root_path
      expect(flash[:notice]).to eq 'Logged out!'
    end
  end
end
