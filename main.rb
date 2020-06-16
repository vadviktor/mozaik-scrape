require 'fileutils'

require 'selenium-webdriver'
require 'mini_magick'

class MozawebScrape
  USERNAME = 'vad.viktor@gmail.com'.freeze
  PASSWORD = 'hunt1CLOO.relt'.freeze
  LOGIN_URL = 'https://www.mozaweb.hu/user.php?cmd=login'.freeze
  BOOK_URL_TEMPLATE = 'https://www.mozaweb.hu/mblite.php?cmd=open&bid=MS-%d&page=1'
  # BOOK_IDS = %w[1662U 1621U 1641 1631 1622 1633 1412 1632 1643 1642]
  BOOK_IDS = %w[1641 1631 1622 1633 1412 1632 1643 1642]

  CSS = {
    next_page_arrow: 'body > div.mblite_layout > div.mblite_container.onepage > a.pager_next',
    next_page_link: 'body > div.mblite_layout > div.mblite_menu_bottom > div.mblite_functions > div > ul > div > li:nth-child(5) > a',
    logged_in_username: '#header a.login.logged-in span.login-name'
  }.freeze

  ELEMENT_NAME = {
    login_name_input: 'loginname',
    password_input: 'password',
    login_form: 'loginform'
  }.freeze

  def initialize
    @wait = Selenium::WebDriver::Wait.new(interval: 1, message: 'waited timed out')
    @driver = Selenium::WebDriver.for :chrome
    @driver.manage.window.rect = Selenium::WebDriver::Rectangle.new 0, 0, 1000, 2000
  end

  def execute
    login
    BOOK_IDS.each do |id|
      scrape sprintf(BOOK_URL_TEMPLATE, id), id
    end
  rescue StandardError => e
    puts e.message
    puts e.backtrace.join "\n"
  ensure
    @driver.close
  end

  private

  def scrape(book_url, directory)
    puts directory
    @driver.get book_url
    @wait.until do
      @driver.find_element(css: CSS[:next_page_arrow])
    end

    FileUtils.mkdir_p File.absolute_path(directory)

    page_num = 0
    loop do
      sleep 1
      break unless @driver.find_element(css: CSS[:next_page_arrow]).displayed?
      page_num += 1
      take_screenshot page_num, directory
      next_page
    end
  end

  def take_screenshot(page_num, directory)
    page_css = "body > div.mblite_layout > div.mblite_container.onepage > div.page_second.clearfix > div"
    page = @driver.find_element(css: page_css)
    rect = page.rect
    image_num = page_num.to_s.rjust(3, '0')
    image_path = File.join(directory, "#{image_num}.png")
    @driver.save_screenshot image_path
    image = MiniMagick::Image.open image_path
    image.crop "#{rect.width}x#{rect.height}+#{rect.x}+#{rect.y}"
    image.write image_path
  end

  def next_page
    @driver.find_element(css: CSS[:next_page_link]).click
  end

  def login
    @driver.get LOGIN_URL
    login_form = @driver.find_element name: ELEMENT_NAME[:login_form]

    login_name = login_form.find_element name: ELEMENT_NAME[:login_name_input]
    login_name.send_keys USERNAME

    login_password = login_form.find_element name: ELEMENT_NAME[:password_input]
    login_password.send_keys PASSWORD

    login_form.submit

    logged_in_username = @wait.until do
      @driver.find_element(css: CSS[:logged_in_username])
    end

    puts logged_in_username.text
  end
end

MozawebScrape.new.execute
