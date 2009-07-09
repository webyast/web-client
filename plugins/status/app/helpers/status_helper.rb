module StatusHelper
  def graph id, width, height, last = false
    html = "<div id='#{id}' style='width:#{width}px;height:#{height}px;float:left'><img src='/images/spinner.gif'></div>"
    html += "<br style='clear: both'>" if last
    return html
  end
end
