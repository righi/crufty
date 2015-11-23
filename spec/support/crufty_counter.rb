class CruftyCounter
  attr_reader :count, :stale_at, :expires_at

  def initialize(stale_at, expires_at)
    @count = 0
    @stale_at = stale_at
    @expires_at = expires_at
  end

  def increment
    crufty(best_by: stale_at, expires: expires_at) do
      @count += 1
    end
  end
end