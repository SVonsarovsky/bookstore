module ApplicationHelper
  def order_status(state)
    state == 'in queue' ? 'waiting for processing' : state
  end
  def date_format(datetime)
    datetime.strftime('%d.%m.%Y, %H:%M')
  end
end
