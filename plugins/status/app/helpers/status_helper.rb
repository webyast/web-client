module StatusHelper
  def graph id, width, height
    html = "<div id='#{id}' style='width:#{width}px;height:#{height}px;float:left;'><img src='/images/working.gif'></div>"
    html += "<br style='clear: both'>"
    return html
  end

  def limits_reached group
    group.single_graphs.each do |single_graph|
      single_graph.lines.each do |line|
        return true if line.limits.reached == "true"
      end    
    end
    return false
  end

  def graph_id group, headline
    id = group + "_" + headline
    id = id.dump
    id.tr!(' /','_')
    id
  end

end
