module DifferHelper
  def html_diff(seq1, seq2)
    ret = ''.html_safe
    sequences = Differ.new(seq1, seq2).sequences
    sequences.each do |sequence|
      type, string = sequence
      case type
      when ' '
        tag = 'span'
      when '+'
        tag = 'ins'
      when '-'
        tag = 'del'
      else
        tag = 'span'
      end
      ret += content_tag(tag, string)
    end

    content_tag('span', ret, class: 'differ')
  end
end
