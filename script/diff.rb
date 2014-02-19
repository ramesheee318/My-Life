class Diff
  require 'xhtmldiff'  
  include REXML
  
  def self.show_diff(xhtml_1,xhtml_2)
    hd_xhtml_1 = HashableElementDelegator.new(Document.new(xhtml_1).root)
    hd_xhtml_2 = HashableElementDelegator.new(Document.new(xhtml_2).root)    
    xhtml_diff = XHTMLDiff.new(Document.new("<div id='diff'></div>").root)
    Diff::LCS.traverse_balanced(hd_xhtml_1, hd_xhtml_2, xhtml_diff)
    xhtml_diff.output.to_s    
  end
end