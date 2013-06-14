module ApplicationHelper
  
  def question_mark(title)
    content_tag(:div, nil, class: 'icon-question-sign', title: title)
  end
  
  def check_mark(title)
    content_tag(:div, nil, class: 'icon-ok', title: title)
  end
  
  def decline(title)
    content_tag(:div, nil, class: 'icon-ban-circle', title: title)
  end
  
  def status?(object)
    if object.declined?
      decline('Declined')
    elsif object.accepted?
      check_mark('Accepted')
    else
      question_mark('No Response')
    end
  end
  
  def pretty_datetime(object, options={})
    options[:ampm] ? object.strftime("%a %m/%d/%Y %I:%M %p %Z") : object.strftime("%m/%d/%Y %H:%M:%S")
  end
  
  def colorize_points(points)
    if points < 0
      content_tag(:span, prettify_points(points), class: 'red')
    elsif points > 0
      content_tag(:span, prettify_points(points), class: 'green')      
    else
      prettify_points(points)
    end
  end
  
  def prettify_points(points)
    sprintf('%g', points)
  end
    
end
