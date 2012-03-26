require 'action_controller'
require 'rqrcode'
require 'rqrcode-rails3/size_calculator.rb'
require 'rqrcode-rails3/renderers/svg.rb'

module RQRCode
  Mime::Type.register "image/svg+xml", :svg unless Mime::Type.lookup_by_extension(:svg)
  Mime::Type.register "image/png",     :png unless Mime::Type.lookup_by_extension(:png)

  extend SizeCalculator

  ActionController::Renderers.add :qrcode do |string, options|
    format = self.request.format.symbol

    self.svg = svg(string, options)

    data = \
    if format == :png
                 image = MiniMagick::Image.read(svg) { |i| i.format "svg" }
                 image.format "png"
                 image.to_blob
    else
      svg
    end

    self.response_body = render_to_string(:text => data, :template => nil)
  end

  def self.svg(string, options)
    size   = options[:size]  || RQRCode.minimum_qr_size_from_string(string)
    level  = options[:level] || :h

    qrcode = RQRCode::QRCode.new(string, :size => size, :level => level)

    RQRCode::Renderers::SVG::render(qrcode, options)
  end
end
