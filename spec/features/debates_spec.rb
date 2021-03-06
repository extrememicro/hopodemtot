# coding: utf-8
require 'rails_helper'

feature 'Debates' do
  before do
    Setting['feature.debates.search'] = true
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.debates'] = nil
    expect{ visit debates_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario 'Index' do
    debates = [create(:debate), create(:debate), create(:debate)]

    visit debates_path

    expect(page).to have_selector('#debates .debate', count: 3)
    debates.each do |debate|
      within('#debates') do
        expect(page).to have_css("a[href='#{debate_path(debate)}']", text: debate.title)
      end
    end
  end

  scenario 'Paginated Index' do
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:debate) }

    visit debates_path

    expect(page).to have_selector('#debates .debate', count: per_page)

    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_content("2")
      expect(page).to_not have_content("3")
      click_link "Next", exact: false
    end

    expect(page).to have_selector('#debates .debate', count: 2)
  end

  scenario 'Show' do
    debate = create(:debate)

    visit debate_path(debate)

    expect(page).to have_content debate.title
    expect(page).to have_content "Debate description"
    expect(page).to have_content "Debate instructions"
    expect(page).to have_content debate.author.name
    expect(page).to have_content I18n.l(debate.created_at.to_date)
    expect(page).to have_selector(avatar(debate.author.name))
    expect(page.html).to include "<title>#{debate.title}</title>"

    within('.social-share-button') do
      expect(page.all('a').count).to be(3) # Twitter, Facebook, Google+
    end
  end

  scenario 'Show: "Back" link directs to previous page', :js do
    debate = create(:debate, title: 'Test Debate 1')

    visit debates_path(order: :hot_score, page: 1)
    first(:link, debate.title).click
    link_text = find_link('Go back')[:href]

    expect(link_text).to include(debates_path order: :hot_score, page: 1)
  end

  scenario 'Create', :js do
    author = create(:user, :official)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'A title for a debate'
    fill_in_editor 'debate_description', with: 'This is very important because...'
    check 'debate_terms_of_service'

    click_button 'Start a debate'

    expect(page).to have_content 'A title for a debate'
    expect(page).to have_content 'Debate created successfully.'
    expect(page).to have_content 'This is very important because...'
    expect(page).to have_content author.name
    expect(page).to have_content I18n.l(Debate.last.created_at.to_date)
  end

  scenario 'Failed creation goes back to new showing featured tags', :js do
    featured_tag = create(:tag, :featured)
    tag = create(:tag)
    login_as(create(:user, :official))

    visit new_debate_path
    fill_in 'debate_title', with: ""
    fill_in_editor 'debate_description', with: 'Very important issue...'
    check 'debate_terms_of_service'

    click_button "Start a debate"

    expect(page).to_not have_content "Debate created successfully."
    expect(page).to have_content "error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  scenario 'Errors on create' do
    author = create(:user, :official)
    login_as(author)

    visit new_debate_path
    click_button 'Start a debate'
    expect(page).to have_content error_message
  end

  scenario 'JS injection is prevented but safe html is respected', :js do
    author = create(:user, :official)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'Testing an attack'
    fill_in_editor 'debate_description', with: '<p>This is <script>alert(\"an attack\");</script></p>'
    check 'debate_terms_of_service'

    click_button 'Start a debate'

    expect(page).to have_content 'Debate created successfully.'
    expect(page).to have_content 'Testing an attack'
    expect(page.html).to include '<p>This is alert("an attack");</p>'
    expect(page.html).to_not include '<script>alert("an attack");</script>'
    expect(page.html).to_not include '&lt;p&gt;This is'
  end

  scenario 'Autolinking is applied to description', :js do
    author = create(:user, :official)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'Testing auto link'
    fill_in_editor 'debate_description', with: '<p>This is a link www.example.org</p>'
    check 'debate_terms_of_service'

    click_button 'Start a debate'

    expect(page).to have_content 'Debate created successfully.'
    expect(page).to have_content 'Testing auto link'
    expect(page).to have_link('www.example.org', href: 'http://www.example.org')
  end

  scenario 'JS injection is prevented but autolinking is respected', :js do
    author = create(:user, :official)
    login_as(author)

    visit new_debate_path
    fill_in 'debate_title', with: 'Testing auto link'
    fill_in_editor 'debate_description', with: "<script>alert('hey')</script> http://example.org"
    check 'debate_terms_of_service'

    click_button 'Start a debate'

    expect(page).to have_content 'Debate created successfully.'
    expect(page).to have_content 'Testing auto link'
    expect(page).to have_link('http://example.org', href: 'http://example.org')
    expect(page.html).to_not include "<script>alert('hey')</script>"
  end

  context 'Tagging debates' do
    let(:author) { create(:user, :official) }

    background do
      login_as(author)
    end

    scenario 'using featured tags', :js do
      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        create(:tag, :featured, name: tag_name)
      end

      visit new_debate_path

      fill_in 'debate_title', with: 'A super test'
      fill_in_editor 'debate_description', with: 'A super test'
      check 'debate_terms_of_service'

      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        find('.js-add-tag-link', text: tag_name).click
      end

      click_button 'Start a debate'

      expect(page).to have_content 'Debate created successfully.'
      ['Medio Ambiente', 'Ciencia'].each do |tag_name|
        expect(page).to have_content tag_name
      end
    end

    scenario 'using dangerous strings', :js do
      visit new_debate_path

      fill_in 'debate_title', with: 'A test of dangerous strings'
      fill_in_editor 'debate_description', with: 'A description suitable for this test'
      check 'debate_terms_of_service'

      fill_in 'debate_tag_list', with: 'user_id=1, &a=3, <script>alert("hey");</script>'

      click_button 'Start a debate'

      expect(page).to have_content 'Debate created successfully.'
      expect(page).to have_content 'user_id1'
      expect(page).to have_content 'a3'
      expect(page).to have_content 'scriptalert("hey");script'
      expect(page.html).to_not include 'user_id=1, &a=3, <script>alert("hey");</script>'
    end
  end

  scenario 'Update should not be posible if logged user is not the author' do
    debate = create(:debate)
    expect(debate).to be_editable
    login_as(create(:user, :official))

    visit edit_debate_path(debate)
    expect(current_path).not_to eq(edit_debate_path(debate))
    expect(page).to have_content "You do not have permission to carry out the action 'edit' on debate."
  end

  scenario 'Update should not be posible if debate is not editable' do
    debate = create(:debate)
    Setting["max_votes_for_debate_edit"] = 2
    3.times { create(:vote, votable: debate) }

    expect(debate).to_not be_editable
    login_as(debate.author)

    visit edit_debate_path(debate)

    expect(current_path).not_to eq(edit_debate_path(debate))
    expect(page).to have_content 'You do not have permission to'
  end

  scenario 'Update should be posible for the author of an editable debate', :js do
    debate = create(:debate)
    login_as(debate.author)

    visit edit_debate_path(debate)
    expect(current_path).to eq(edit_debate_path(debate))

    fill_in 'debate_title', with: "End child poverty"
    fill_in_editor 'debate_description', with: "Let's do something to end child poverty"

    click_button "Save changes"

    expect(page).to have_content "Debate updated successfully."
    expect(page).to have_content "End child poverty"
    expect(page).to have_content "Let's do something to end child poverty"
  end

  scenario 'Errors on update' do
    debate = create(:debate)
    login_as(debate.author)

    visit edit_debate_path(debate)
    fill_in 'debate_title', with: ""
    click_button "Save changes"

    expect(page).to have_content error_message
  end

  scenario 'Failed update goes back to edit showing featured tags' do
    debate       = create(:debate)
    featured_tag = create(:tag, :featured)
    tag = create(:tag)
    login_as(debate.author)

    visit edit_debate_path(debate)
    expect(current_path).to eq(edit_debate_path(debate))

    fill_in 'debate_title', with: ""
    click_button "Save changes"

    expect(page).to_not have_content "Debate updated successfully."
    expect(page).to have_content "error"
    within(".tags") do
      expect(page).to have_content featured_tag.name
      expect(page).to_not have_content tag.name
    end
  end

  describe 'Limiting tags shown' do
    scenario 'Index page shows up to 5 tags per debate' do
      tag_list = ["Hacienda", "Economía", "Medio Ambiente", "Corrupción", "Fiestas populares", "Prensa"]
      create :debate, tag_list: tag_list

      visit debates_path

      within('.debate .tags') do
        expect(page).to have_content '1+'
      end
    end

    scenario 'Index page shows 3 tags with no plus link' do
      tag_list = ["Medio Ambiente", "Corrupción", "Fiestas populares"]
      create :debate, tag_list: tag_list

      visit debates_path

      within('.debate .tags') do
        tag_list.each do |tag|
          expect(page).to have_content tag
        end
        expect(page).not_to have_content '+'
      end
    end
  end

  scenario "Flagging", :js do
    user = create(:user)
    debate = create(:debate)

    login_as(user)
    visit debate_path(debate)

    within "#debate_#{debate.id}" do
      page.find("#flag-expand-debate-#{debate.id}").click
      page.find("#flag-debate-#{debate.id}").click

      expect(page).to have_css("#unflag-expand-debate-#{debate.id}")
    end

    expect(Flag.flagged?(user, debate)).to be
  end

  scenario "Unflagging", :js do
    user = create(:user)
    debate = create(:debate)
    Flag.flag(user, debate)

    login_as(user)
    visit debate_path(debate)

    within "#debate_#{debate.id}" do
      page.find("#unflag-expand-debate-#{debate.id}").click
      page.find("#unflag-debate-#{debate.id}").click

      expect(page).to have_css("#flag-expand-debate-#{debate.id}")
    end

    expect(Flag.flagged?(user, debate)).to_not be
  end

  feature 'Debate index order filters' do

    scenario 'Default order is hot_score', :js do
      create(:debate, title: 'Best').update_column(:hot_score, 10)
      create(:debate, title: 'Worst').update_column(:hot_score, 2)
      create(:debate, title: 'Medium').update_column(:hot_score, 5)

      visit debates_path

      expect('Best').to appear_before('Medium')
      expect('Medium').to appear_before('Worst')
    end

    scenario 'Debates are ordered by confidence_score', :js do
      create(:debate, title: 'Best').update_column(:confidence_score, 10)
      create(:debate, title: 'Worst').update_column(:confidence_score, 2)
      create(:debate, title: 'Medium').update_column(:confidence_score, 5)

      visit debates_path
      click_link 'highest rated'

      expect(page.find('.debate', match: :first)).to have_content('Best')

      within '#debates' do
        expect('Best').to appear_before('Medium')
        expect('Medium').to appear_before('Worst')
      end

      expect(current_url).to include('order=confidence_score')
      expect(current_url).to include('page=1')
    end

    scenario 'Debates are ordered by newest', :js do
      create(:debate, title: 'Best',   created_at: Time.now).update_column(:confidence_score, 1)
      create(:debate, title: 'Medium', created_at: Time.now - 1.hour).update_column(:confidence_score, 2)
      create(:debate, title: 'Worst',  created_at: Time.now - 1.day).update_column(:confidence_score, 3)

      visit debates_path(order: "confidence_score")
      click_link 'newest'

      expect(page.find('.debate', match: :first)).to have_content('Best')

      within '#debates' do
        expect('Best').to appear_before('Medium')
        expect('Medium').to appear_before('Worst')
      end

      expect(current_url).to include('order=created_at')
      expect(current_url).to include('page=1')
    end
  end

  context "Search" do

    context "Basic search" do

      scenario 'Search by text' do
        debate1 = create(:debate, title: "Get Schwifty")
        debate2 = create(:debate, title: "Schwifty Hello")
        debate3 = create(:debate, title: "Do not show me")

        visit debates_path

        within "#search_form" do
          fill_in "search", with: "Schwifty"
          click_button "Search"
        end

        expect(page).to have_content("2 debates")

        within("#debates") do
          expect(page).to have_content(debate1.title)
          expect(page).to have_content(debate2.title)
          expect(page).to_not have_content(debate3.title)
        end
      end

      scenario "Maintain search criteria" do
        visit debates_path

        within "#search_form" do
          fill_in "search", with: "Schwifty"
          click_button "Search"
        end

        expect(page).to have_selector("input[name='search'][value='Schwifty']")
      end

    end

    context "Advanced search" do

      scenario "Search by text", :js do
        debate1 = create(:debate, title: "Get Schwifty")
        debate2 = create(:debate, title: "Schwifty Hello")
        debate3 = create(:debate, title: "Do not show me")

        visit debates_path

        click_link "Advanced search"
        fill_in "Write the text", with: "Schwifty"
        click_button "Filter"

        expect(page).to have_content("2 debates")

        within("#debates") do
          expect(page).to have_content(debate1.title)
          expect(page).to have_content(debate2.title)
          expect(page).to_not have_content(debate3.title)
        end
      end

      context "Search by author type" do

        scenario "Public employee", :js do
          ana = create :user, official_level: 1
          john = create :user, official_level: 2

          debate1 = create(:debate, author: ana)
          debate2 = create(:debate, author: ana)
          debate3 = create(:debate, author: john)

          visit debates_path

          click_link "Advanced search"
          select "Public employee", from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("2 debates")

          within("#debates") do
            expect(page).to have_content(debate1.title)
            expect(page).to have_content(debate2.title)
            expect(page).to_not have_content(debate3.title)
          end
        end

        scenario "Municipal Organization", :js do
          ana = create :user, official_level: 2
          john = create :user, official_level: 3

          debate1 = create(:debate, author: ana)
          debate2 = create(:debate, author: ana)
          debate3 = create(:debate, author: john)

          visit debates_path

          click_link "Advanced search"
          select "Municipal Organization", from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("2 debates")

          within("#debates") do
            expect(page).to have_content(debate1.title)
            expect(page).to have_content(debate2.title)
            expect(page).to_not have_content(debate3.title)
          end
        end

        scenario "General director", :js do
          ana = create :user, official_level: 3
          john = create :user, official_level: 4

          debate1 = create(:debate, author: ana)
          debate2 = create(:debate, author: ana)
          debate3 = create(:debate, author: john)

          visit debates_path

          click_link "Advanced search"
          select "General director", from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("2 debates")

          within("#debates") do
            expect(page).to have_content(debate1.title)
            expect(page).to have_content(debate2.title)
            expect(page).to_not have_content(debate3.title)
          end
        end

        scenario "City councillor", :js do
          ana = create :user, official_level: 4
          john = create :user, official_level: 5

          debate1 = create(:debate, author: ana)
          debate2 = create(:debate, author: ana)
          debate3 = create(:debate, author: john)

          visit debates_path

          click_link "Advanced search"
          select "City councillor", from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("2 debates")

          within("#debates") do
            expect(page).to have_content(debate1.title)
            expect(page).to have_content(debate2.title)
            expect(page).to_not have_content(debate3.title)
          end
        end

        scenario "Mayoress", :js do
          ana = create :user, official_level: 5
          john = create :user, official_level: 4

          debate1 = create(:debate, author: ana)
          debate2 = create(:debate, author: ana)
          debate3 = create(:debate, author: john)

          visit debates_path

          click_link "Advanced search"
          select "Mayoress", from: "advanced_search_official_level"
          click_button "Filter"

          expect(page).to have_content("2 debates")

          within("#debates") do
            expect(page).to have_content(debate1.title)
            expect(page).to have_content(debate2.title)
            expect(page).to_not have_content(debate3.title)
          end
        end

      end

      context "Search by date" do

        context "Predefined date ranges" do

          scenario "Last day", :js do
            debate1 = create(:debate, created_at: 1.minute.ago)
            debate2 = create(:debate, created_at: 1.hour.ago)
            debate3 = create(:debate, created_at: 2.days.ago)

            visit debates_path

            click_link "Advanced search"
            select "Last 24 hours", from: "js-advanced-search-date-min"
            click_button "Filter"

            expect(page).to have_content("2 debates")

            within("#debates") do
              expect(page).to have_content(debate1.title)
              expect(page).to have_content(debate2.title)
              expect(page).to_not have_content(debate3.title)
            end
          end

          scenario "Last week", :js do
            debate1 = create(:debate, created_at: 1.day.ago)
            debate2 = create(:debate, created_at: 5.days.ago)
            debate3 = create(:debate, created_at: 8.days.ago)

            visit debates_path

            click_link "Advanced search"
            select "Last week", from: "js-advanced-search-date-min"
            click_button "Filter"

            expect(page).to have_content("2 debates")

            within("#debates") do
              expect(page).to have_content(debate1.title)
              expect(page).to have_content(debate2.title)
              expect(page).to_not have_content(debate3.title)
            end
          end

          scenario "Last month", :js do
            debate1 = create(:debate, created_at: 10.days.ago)
            debate2 = create(:debate, created_at: 20.days.ago)
            debate3 = create(:debate, created_at: 33.days.ago)

            visit debates_path

            click_link "Advanced search"
            select "Last month", from: "js-advanced-search-date-min"
            click_button "Filter"

            expect(page).to have_content("2 debates")

            within("#debates") do
              expect(page).to have_content(debate1.title)
              expect(page).to have_content(debate2.title)
              expect(page).to_not have_content(debate3.title)
            end
          end

          scenario "Last year", :js do
            debate1 = create(:debate, created_at: 300.days.ago)
            debate2 = create(:debate, created_at: 350.days.ago)
            debate3 = create(:debate, created_at: 370.days.ago)

            visit debates_path

            click_link "Advanced search"
            select "Last year", from: "js-advanced-search-date-min"
            click_button "Filter"

            expect(page).to have_content("2 debates")

            within("#debates") do
              expect(page).to have_content(debate1.title)
              expect(page).to have_content(debate2.title)
              expect(page).to_not have_content(debate3.title)
            end
          end

        end

        scenario "Search by custom date range", :js do
          debate1 = create(:debate, created_at: 2.days.ago)
          debate2 = create(:debate, created_at: 3.days.ago)
          debate3 = create(:debate, created_at: 9.days.ago)

          visit debates_path

          click_link "Advanced search"
          select "Customized", from: "js-advanced-search-date-min"
          fill_in "advanced_search_date_min", with: 7.days.ago
          fill_in "advanced_search_date_max", with: 1.days.ago
          click_button "Filter"

          expect(page).to have_content("2 debates")

          within("#debates") do
            expect(page).to have_content(debate1.title)
            expect(page).to have_content(debate2.title)
            expect(page).to_not have_content(debate3.title)
          end
        end

        scenario "Search by multiple filters", :js do
          ana  = create :user, official_level: 1
          john = create :user, official_level: 1

          debate1 = create(:debate, title: "Get Schwifty",   author: ana,  created_at: 1.minute.ago)
          debate2 = create(:debate, title: "Hello Schwifty", author: john, created_at: 2.days.ago)
          debate3 = create(:debate, title: "Save the forest")

          visit debates_path

          click_link "Advanced search"
          fill_in "Write the text", with: "Schwifty"
          select "Public employee", from: "advanced_search_official_level"
          select "Last 24 hours",   from: "js-advanced-search-date-min"

          click_button "Filter"

          expect(page).to have_content("1 debate")

          within("#debates") do
            expect(page).to have_content(debate1.title)
          end
        end

        scenario "Maintain advanced search criteria", :js do
          visit debates_path
          click_link "Advanced search"

          fill_in "Write the text", with: "Schwifty"
          select "Public employee", from: "advanced_search_official_level"
          select "Last 24 hours", from: "js-advanced-search-date-min"

          click_button "Filter"

          within "#js-advanced-search" do
            expect(page).to have_selector("input[name='search'][value='Schwifty']")
            expect(page).to have_select('advanced_search[official_level]', selected: 'Public employee')
            expect(page).to have_select('advanced_search[date_min]', selected: 'Last 24 hours')
          end
        end

        scenario "Maintain custom date search criteria", :js do
          visit debates_path
          click_link "Advanced search"

          select "Customized", from: "js-advanced-search-date-min"
          fill_in "advanced_search_date_min", with: 7.days.ago
          fill_in "advanced_search_date_max", with: 1.days.ago
          click_button "Filter"

          within "#js-advanced-search" do
            expect(page).to have_select('advanced_search[date_min]', selected: 'Customized')
            expect(page).to have_selector("input[name='advanced_search[date_min]'][value*='#{7.days.ago.strftime('%Y-%m-%d')}']")
            expect(page).to have_selector("input[name='advanced_search[date_max]'][value*='#{1.day.ago.strftime('%Y-%m-%d')}']")
          end
        end

      end
    end

    pending "Order by relevance by default", :js do
      debate1 = create(:debate, title: "Show you got",      cached_votes_up: 10)
      debate2 = create(:debate, title: "Show what you got", cached_votes_up: 1)
      debate3 = create(:debate, title: "Show you got",      cached_votes_up: 100)

      visit debates_path
      fill_in "search", with: "Show what you got"
      click_button "Search"

      expect(page).to have_selector("a.active", text: "relevance")

      within("#debates") do
        expect(all(".debate")[0].text).to match "Show what you got"
        expect(all(".debate")[1].text).to match "Show you got"
        expect(all(".debate")[2].text).to match "Show you got"
      end
    end

    pending "Reorder results maintaing search", :js do
      debate1 = create(:debate, title: "Show you got",      cached_votes_up: 10,  created_at: 1.week.ago)
      debate2 = create(:debate, title: "Show what you got", cached_votes_up: 1,   created_at: 1.month.ago)
      debate3 = create(:debate, title: "Show you got",      cached_votes_up: 100, created_at: Time.now)
      debate4 = create(:debate, title: "Do not display",    cached_votes_up: 1,   created_at: 1.week.ago)

      visit debates_path
      fill_in "search", with: "Show what you got"
      click_button "Search"
      click_link 'newest'
      expect(page).to have_selector("a.active", text: "newest")

      within("#debates") do
        expect(all(".debate")[0].text).to match "Show you got"
        expect(all(".debate")[1].text).to match "Show you got"
        expect(all(".debate")[2].text).to match "Show what you got"
        expect(page).to_not have_content "Do not display"
      end
    end

    scenario 'After a search do not show featured debates' do
      featured_debates = create_featured_debates
      debate = create(:debate, title: "Abcdefghi")

      visit debates_path
      within "#search_form" do
        fill_in "search", with: debate.title
        click_button "Search"
      end

      expect(page).to_not have_selector('#debates .debate-featured')
      expect(page).to_not have_selector('#featured-debates')
    end

  end

  scenario 'Index tag does not show featured debates' do
    featured_debates = create_featured_debates
    debates = create(:debate, tag_list: "123")

    visit debates_path(tag: "123")

    expect(page).to_not have_selector('#debates .debate-featured')
    expect(page).to_not have_selector('#featured-debates')
  end

  scenario 'Conflictive' do
    good_debate = create(:debate)
    conflictive_debate = create(:debate, :conflictive)

    visit debate_path(conflictive_debate)
    expect(page).to have_content "This debate has been flagged as inappropriate by several users."

    visit debate_path(good_debate)
    expect(page).to_not have_content "This debate has been flagged as inappropriate by several users."
  end

  scenario 'Erased author' do
    user = create(:user)
    debate = create(:debate, author: user)
    user.erase

    visit debates_path
    expect(page).to have_content('User deleted')

    visit debate_path(debate)
    expect(page).to have_content('User deleted')
  end
end
