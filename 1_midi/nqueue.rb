class NoteQueue

  def initialize
    @queues = {}
  end

  def enqueue(note)
    if @queues.has_key?(note.data1) then
      @queues[note.data1] << note  # Enqueue this note onto the queue for that note
    else
      @queues[note.data1] = []
    end
  end

  def dequeue(note)
    if @queues.has_key?(note.data1) then
      @queues[note.data1].pop
    else
      nil
    end
  end
end