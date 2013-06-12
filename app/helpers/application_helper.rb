module ApplicationHelper
  def status?(object)
    if object.declined?
      content_tag(:div, nil, class: 'icon-ban-circle', title: 'Declined')
    elsif object.accepted?
      content_tag(:div, nil, class: 'icon-ok', title: 'Accepted')
    else
      content_tag(:div, nil, class: 'icon-question-sign', title: 'No Response')
    end
  end
  
  def pretty_datetime(object, options={})
    options[:ampm] ? object.strftime("%m/%d/%Y %I:%M:%S %p") : object.strftime("%m/%d/%Y %H:%M:%S")
  end
    
end
