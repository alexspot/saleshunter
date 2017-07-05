class AsosService

  PRODUCT_CONTAINER = '.product-container.interactions'
  PRODUCT_ORIGINAL_PRICE = '.price-previous .price'
  PRODUCT_SALE_PRICE = '.price-current .price'
  PRODUCT_MODEL_NAME = '.name'
  PRODUCT_IMAGE_URL = '.product-img'
  PRODUCT_URL = '.product-link.product'
  url = "http://us.asos.com/men/sale/shoes-sneakers/cat/?cid=1935&refine=attribute_900:1608|brand:18&currentpricerange=5-285&pgesize=204"

  def initialize
    @asos = []
    # @_cookies = {'ckm-ctx-sf' => '/ca'}
  end

  def call(sale_url)
    raw_html = get_page_in_html(sale_url)
    @_parsed_html = parse_html(raw_html)
    extract_info_to_json
  end

  private

  def get_page_in_html(sale_url)
    RestClient::Request.execute(:method => :get, :url => sale_url).body
  end

  def parse_html(html)
    Nokogiri::HTML(html)
  end

  def get_model_name(text)
    text[/^(adidas Originals|Asics|Reebok|Puma|Saucony) (.+) Sneakers/, 2]
  end

  def get_brand_name(text)
    text[/^(adidas Originals|Asics|Reebok|Puma|Saucony)/, 1]
  end

  def calculate_discount(orig_price, sale_price)
    (sale_price.gsub('$', '').to_i * 100) / orig_price.gsub('$', '').to_i
  end

  def extract_info_to_json
    @_parsed_html.css(PRODUCT_CONTAINER).each do |product|
      orig_price = product.css(PRODUCT_ORIGINAL_PRICE).text
      next if orig_price == ''
      model_brand_text = product.css(PRODUCT_MODEL_NAME).text.strip
      sale_price = product.css(PRODUCT_SALE_PRICE).text
      url = product.css(PRODUCT_URL).attr('href').text
      image = product.css(PRODUCT_IMAGE_URL).attr('src').text
      @asos.push(
          brand: get_brand_name(model_brand_text),
          model: get_model_name(model_brand_text),
          orig_price: orig_price,
          percentage_off: "#{calculate_discount(orig_price, sale_price)}%",
          sale_price: sale_price,
          url: url,
          image: image
      )
    end

    @asos
  end

end