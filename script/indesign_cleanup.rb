#!/usr/bin/env ruby
require 'bundler/setup'
require 'ruby-debug'
require 'nokogiri' # gem 'nokogiri' 
require 'css_parser' # gem 'css_parser'





# Monkey patch CssParser
class CssParser::Parser
  include Enumerable

  alias_method :each, :each_selector
end

# Monkey patch CssParser - End
class IndesignCleanup
  # Helper methods - Start
  def self.prepare_css_doc(html_doc, base_dir)
    parser = CssParser::Parser.new
    html_doc.xpath('//link[@rel="stylesheet"]').each do |stylesheet_url|
      stylesheet_file= URI.decode("#{base_dir}/#{stylesheet_url['href']}")
      parser.load_file!(stylesheet_file)
    end
    return parser
  end

  def self.wrap_nodes(html_doc, css_doc, css_rule, wrapper, only_spans=true)
    selectors= css_doc.select do |selector, declarations, specificity|
      declarations.match(css_rule)
    end.map do |selector, declarations, specificity|
      selector
    end

    if only_spans
      selectors= selectors.select do |s|
        s.start_with?('span.')
      end
    end

    unless selectors.empty?
      html_doc.css(selectors.join(', ')).wrap(wrapper)
    end
  end

  # Helper methods - End
  def self.parasing_html(html_file,logger)
    # Main code

   if !html_file
      STDERR.puts "Usage: #{html_file}".red
      logger.info("\033[32m #{html_file}")
      exit 1
    end

    base_dir= File.dirname(html_file)
    html_doc= Nokogiri::HTML(File.read(html_file), nil, 'UTF-8')
    css_doc= prepare_css_doc(html_doc, base_dir)

    wraps= [
      ["font-weight: bold;", "<b></b>"],
      ["font-style: italic;", "<i></i>"]
    ]

    wraps.each do |css_rule, wrapper|
      wrap_nodes(html_doc, css_doc, css_rule, wrapper)
    end

    wraps.clear
    # puts html_doc.to_xhtml(:encoding => 'UTF-8')
    return html_doc.to_xhtml(:encoding => 'UTF-8')

  end

end