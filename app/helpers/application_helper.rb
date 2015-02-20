module ApplicationHelper
  def date_format(datetime)
    I18n.l datetime, format: :common
  end
end
