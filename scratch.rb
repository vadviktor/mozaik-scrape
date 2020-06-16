require "selenium-webdriver"

driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(interval: 1, message: "waited timed out")

username = "vad.viktor@gmail.com"
password = "hunt1CLOO.relt"
login_url = "https://www.mozaweb.hu/user.php?cmd=login"
book_url = "https://www.mozaweb.hu/mblite.php?cmd=open&bid=MS-2500U&page=1"

css = {
  next_page_arrow: "body > div.mblite_layout > div.mblite_container.onepage > a.pager_next",
  next_page_link: "body > div.mblite_layout > div.mblite_menu_bottom > div.mblite_functions > div > ul > div > li:nth-child(5) > a",
  logged_in_username: "#header a.login.logged-in span.login-name"
}

elements = {
  login_name_input: "loginname",
  password_input: "password",
  login_form: "loginform"
}

driver.get login_url
login_form = driver.find_element name: elements[:login_form]

login_name = login_form.find_element name: elements[:login_name_input]
login_name.send_keys username

login_password = login_form.find_element name: elements[:password_input]
login_password.send_keys password

login_form.submit

wait.until { driver.find_element(css: css[:logged_in_username]) }

driver.get book_url

########################################################

require 'mini_magick'

driver.manage.window.rect = Selenium::WebDriver::Rectangle.new 0,0,1000,2000
page_css = "body > div.mblite_layout > div.mblite_container.onepage > div.page_second.clearfix > div"
page = driver.find_element(css: page_css)
rect = page.rect

image_path = File.join(File.dirname( __FILE__), 'test.png')
driver.save_screenshot image_path
image = MiniMagick::Image.open image_path
image.crop "#{rect.width}x#{rect.height}+#{rect.x}+#{rect.y}"
image.write image_path

css = "body > div.mblite_layout > div.mblite_menu_bottom > div.mblite_functions > div > ul > div > li:nth-child(5) > a"
driver.find_element(css: css).click
