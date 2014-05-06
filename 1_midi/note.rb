class Note

  def initialize(ev1, ev2)
    # Check these are the same note
    raise if ev1.data1 != ev2.data1

    if ev1.code == NOTE_ON then
      @on = ev1
      @off = ev2
    else
      @on = ev2
      @off = ev1
    end

  end

  def to_s
    "ev 1 : #{@on.to_s}, ev2 : #{@off}"
  end

  def to_csv
    "#{letter},#{octave},#{velocity},#{time_on},#{time_off},#{duration},#{note_number}"
  end

  private
    def letter
      note_names(@on.data1 % 12)
    end

    def octave
      @on.data1 / 12
    end

    def velocity
      @on.data2
    end

    def duration
      @off.time - @on.time
    end

    def time_on
      @on.time
    end

    def time_off
      @off.time
    end

    def note_number
      @on.data1
    end

    def note_names(mod_12)
      note_names = {
        0 => 'C',
        1 => 'C#',
        2 => 'D',
        3 => 'D#',
        4 => 'E',
        5 => 'F',
        6 => 'F#',
        7 => 'G',
        8 => 'G#',
        9 => 'A',
        10 => 'A#',
        11 => 'B'
      }

      note_names[mod_12]
    end

end
