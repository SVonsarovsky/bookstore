module ApplicationHelper
  def date_format(datetime)
    datetime.strftime('%d.%m.%Y, %H:%M')
  end
end
