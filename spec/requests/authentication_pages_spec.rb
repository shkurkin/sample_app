require 'spec_helper'

describe "Authentication" do
	subject { page }

	describe "signin page" do
		before { visit signin_path }

		it { should have_selector('h1', text: 'Sign in') }
		it { should have_selector('title', text: 'Sign in') }
		it { should_not have_link('Profile') }
		it { should_not have_link('Settings') }
	end

	describe "signin" do
		before { visit signin_path }

		describe "With invalid information" do
			before { click_button "Sign in" }

			it { should have_selector('title', text: 'Sign in') }
			it { should have_selector('div.alert.alert-error', text: 'Invalid') }
		
			describe "after visiting another page" do
				before { click_link "Home" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "With valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }

			it { should have_selector('title', text: user.name) }

			it { should have_link('Users', href: users_path) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Settings', href: edit_user_path(user)) }
			it { should have_link('Sign out', href: signout_path) }

			it { should_not have_link('Sign in', href: signin_path) }

			describe "New action should redirect to root URL" do
				before { get new_user_path }
				specify { response.should redirect_to(root_url) }
			end

			describe "Create action should redirect to root URL" do
				before { post users_path }
				specify { response.should redirect_to(root_url) }
			end
		end
	end  

	describe "authorization" do
		describe "for non-signed-in users" do
			let(:user) { FactoryGirl.create(:user) }

			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					fill_in "Email", with: user.email
					fill_in "Password", with: user.password
					click_button "Sign in"
				end

				describe "after signing in" do

					it "should render the desired protected page" do
						page.should have_selector('title', text: 'Edit user')
					end

					describe "friendly forwarding only works the first time" do
						before do
						 click_link "Sign out" 
						 sign_in(user)
						end

						it { should have_selector('title', text: user.name) }
					end
				end
			end

			describe "in the Users controller" do

				describe "visiting the edit page" do
					before { visit edit_user_path(user) }
					it { should have_selector('title', text: 'Sign in') }
				end

				describe "submitting to the update action" do
					before { put user_path(user) }
					specify { response.should redirect_to(signin_path) }
				end

				describe "visiting the user index" do
					before { visit users_path }
					it { should have_selector('title', text: 'Sign in') }
				end

				describe "visiting the user index" do
					before { visit users_path }
					it { should have_selector('title', text: 'Sign in') }
				end

				describe "visiting the following page" do
					before { visit following_user_path(user) }
					it { should have_selector('title', text: 'Sign in') }
				end

				describe "visiting the followers page" do
					before { visit followers_user_path(user) }
					it { should have_selector('title', text: 'Sign in') }
				end
			end

			describe "in the Microposts controller" do

				describe "submitting to the create action" do
					before { post microposts_path }
					specify { response.should redirect_to(signin_path) }
				end

				describe "submitting to the destroy action" do
					before { delete micropost_path(FactoryGirl.create(:micropost)) }
					specify { response.should redirect_to(signin_path) }
				end
			end

			describe "in the Relationships controller" do
				describe "submitting to the create action" do
					before { post relationships_path }
					specify { response.should redirect_to(signin_path) }
				end

				describe "submitting to the destroy action" do
					before { delete relationship_path(1) }
					specify { response.should redirect_to(signin_path) }
				end
			end
		end

		describe "as wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
			before { sign_in user }

			describe "visiting User#edit page" do
				before { visit edit_user_path(wrong_user) }
				it { should_not have_selector('title', text: full_title('Edit user')) }
			end

			describe "submitting a PUT request to the Users#update action" do
				before { put user_path(wrong_user) }
				specify { response.should redirect_to(root_url) }
			end
		end

		describe "as non-admin user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }

			before { sign_in non_admin }

			describe "submitting a DELETE request to the Users#destroy action" do
				before { delete user_path(user) }
				specify { response.should redirect_to(root_url) }
			end
		end
	end

	describe "accessible attributes" do
		let(:user) {FactoryGirl.create(:user) }

		it "should not allow access to admin" do
			expect do
				User.new(email: user.email, name: user.name, password: user.password,
						 password_confirmation: user.password_confirmation, admin: true )
			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end
end
