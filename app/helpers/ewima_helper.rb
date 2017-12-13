module EwimaHelper
  def repeat_html_code(times, code)
    repeated_code = code
    (1..times).each do |item|
      repeated_code = repeated_code + code
    end
    return repeated_code
  end
end
