module LuckyWeb::FormHelpers
  def label_for(field : LuckyRecord::Field)
    label field.name.to_s.humanize
  end
end
