class IgnoreExceptionSinceSidekiqWillRetry < StandardError
  def intialize(exception)
    super(exception.message)
    @cause = exception
  end

  def cause = @cause
end