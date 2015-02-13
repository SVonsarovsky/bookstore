module ApplicationHelper
  def date_format(datetime)
    datetime.localtime.strftime('%d.%m.%Y, %H:%M')
  end
end
