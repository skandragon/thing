require 'diff/lcs'

class Differ
  class Comparison
    attr_reader :sequences

    def initialize
      @state = ' '
      @buffer = ''
      @sequences = []
    end

    def match(element)
      append_state(' ', element.old_element)
    end

    def discard_a(element)
      append_state('-', element.old_element)
    end

    def discard_b(element)
      append_state('+', element.new_element)
    end

    def finalize
      dump_buffer('e')
    end

    private

    def append_state(new_state, character)
      if @state != new_state
        dump_buffer(new_state)
      end
      @buffer += character
    end

    def dump_buffer(new_state)
      return if @buffer.empty?
      @sequences << [@state, @buffer]
      @state = new_state
      @buffer = ''
    end
  end

  def initialize(seq1, seq2)
    seq1 ||= ''
    seq2 ||= ''

    seq1 = seq1.join(', ') if seq1.is_a?Array
    seq2 = seq2.join(', ') if seq2.is_a?Array

    @comparison = Comparison.new
    Diff::LCS.traverse_sequences(seq1, seq2, @comparison)
    @comparison.finalize
  end

  def sequences
    @comparison.sequences
  end
end
