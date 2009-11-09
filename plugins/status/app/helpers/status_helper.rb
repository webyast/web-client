module StatusHelper
  def graph id, width, height, last = false, error = false
    if error
      html = "<div id='#{id}' style='width:#{width}px;height:#{height}px;float:left;border:solid 2px red;'><img src='/images/working.gif'></div>"
    else
      html = "<div id='#{id}' style='width:#{width}px;height:#{height}px;float:left;'><img src='/images/working.gif'></div>"
    end
    html += "<br style='clear: both'>" if last
    return html
  end
end
