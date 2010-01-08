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

  def graph_id group, headline=nil
    id = group 
    id += "_" + headline if headline
    id.delete!('\"')
    id.tr!(' /','_')
    id
  end

  def evaluate_next_graph group, single_graphs, index
    return nil if index+1 > single_graphs.size
    graph_div_id = graph_id(group, single_graphs[index].headline)
    remote_function(:update => graph_div_id,
                    :url => { :action => "evaluate_values", :group_id => group, :graph_id => single_graphs[index].headline},
                    :complete => evaluate_next_graph(group, single_graphs, index+1))
  end

end
