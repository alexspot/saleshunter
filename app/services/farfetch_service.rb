class FarfetchService

  PRODUCT_CONTAINER = '.listing-item'
  PRODUCT_ORIGINAL_PRICE = '.listing-item-content-price'
  PRODUCT_PERCENTAGE_OFF = '.listing-item-percentOff'
  PRODUCT_SALE_PRICE = '.listing-item-content-sale'
  PRODUCT_MODEL_NAME = '.listing-item-content-description'
  PRODUCT_BRAND_NAME = '.listing-item-content-brand'
  PRODUCT_URL = '.listing-item-image a'
  PRODUCT_IMAGE_URL = '.listing-item-image img'

  def initialize
    @farfetch = []
    @_cookies = {'ckm-ctx-sf' => '/ca'}
  end

  def call(sale_url)
    raw_html = get_page_in_html(sale_url)
    @_parsed_html = parse_html(raw_html)
    extract_info_to_json
  end

  private

  def get_page_in_html(sale_url)
    RestClient::Request.execute(:method => :get, :url => sale_url, :cookies => @_cookies ).body
  end

  def parse_html(html)
    Nokogiri::HTML(html)
  end

  def extract_info_to_json
    @_parsed_html.css(PRODUCT_CONTAINER).each do |product|
      brand_name = product.css(PRODUCT_BRAND_NAME).text
      model_name = product.css(PRODUCT_MODEL_NAME).text.strip
      orig_price = product.css(PRODUCT_ORIGINAL_PRICE).text
      percentage_off = product.css(PRODUCT_PERCENTAGE_OFF).text
      sale_price = product.css(PRODUCT_SALE_PRICE).text
      url = product.css(PRODUCT_URL).attr('href').text
      image = product.css(PRODUCT_IMAGE_URL).last.attr('src')
      @farfetch.push(
          brand: brand_name,
          model: model_name,
          orig_price: orig_price,
          percentage_off: percentage_off,
          sale_price: sale_price,
          url: "https://farfetch.com#{url}",
          image: image
      )
    end

    @farfetch
  end

end